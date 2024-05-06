import {
  addCorsHeaders,
  connectToDB,
  validateContentType,
  DATETIME_FORMAT_UTC,
  DATETIME_FORMAT_WITHOFFSET,
} from "/opt/nodejs/lib.mjs";
import {
  isMatch,
} from "date-fns";
import pg from "pg";
import {
  CHECK_VIOLATION,
  FOREIGN_KEY_VIOLATION,
  INVALID_TEXT_REPRESENTATION,
  UNIQUE_VIOLATION,
} from "pg-error-constants";

let db = await connectToDB();

const REQUIRED_FIELDS = [
  "timestamp",
  "uv",
  "light",
  "accel_x",
  "accel_y",
  "accel_z",
  "col_red",
  "col_green",
  "col_blue",
  "col_clear",
  "col_temp",
];
// Any samples which cause exceptions upon inserting to DB are handled
// much slower than successes (because exceptions are expensive).
//
// From testing, we see 1000 samples which have timestamps already
// seen for a given child processed well within the 29s API Gateway
// timeout AND the 30s lambda timeout we've set.  It was almost 20s.
const MAX_SAMPLES = 1000;

export const handler = async (event) => {
  const childID = event.pathParameters.childID;
  const resolvedResource = event.resource.replace("{childID}", encodeURIComponent(childID));
  console.log(`got child ID ${childID}`);

  const maybeEarlyErrorResp = {
    statusCode: 400,
  };
  addCorsHeaders(maybeEarlyErrorResp);

  const contentTypeError = validateContentType(event.headers, resolvedResource);
  if (contentTypeError !== null) {
    maybeEarlyErrorResp.body = JSON.stringify({errors: [contentTypeError]});
    return maybeEarlyErrorResp;
  }

  let reqBody;
  try {
    reqBody = JSON.parse(event.body);
  } catch (e) {
    console.error(e);
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: resolvedResource,
          status: 400,
          message: "missing or empty request body",
        }
      ],
    });
    return maybeEarlyErrorResp;
  }
  if (reqBody == null) {
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: resolvedResource,
          status: 400,
          message: "missing or empty request body",
        }
      ],
    });
    return maybeEarlyErrorResp;
  }
  if (reqBody.samples === undefined) {
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: resolvedResource,
          status: 400,
          message: "missing `samples` property in request body",
        }
      ],
    });
    return maybeEarlyErrorResp
  }
  if (!Array.isArray(reqBody.samples)) {
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: resolvedResource,
          status: 400,
          message: "samples property in request body must be an array",
        }
      ]
    });
    return maybeEarlyErrorResp;
  }
  const samples = reqBody.samples;
  console.log(`got ${samples.length} samples`);
  if (samples.length > MAX_SAMPLES) {
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: resolvedResource,
          status: 400,
          message: "too many samples, try again with less"
        }
      ]
    });
    return maybeEarlyErrorResp;
  }

  let errors = [];
  for (let i=0; i<samples.length; i++) {
    let badfields = false;

    // check if all samples fields are present
    for (let j=0; j<REQUIRED_FIELDS.length; j++) {
      if (samples[i][REQUIRED_FIELDS[j]] == null) {
        errors.push({
          resource: `${resolvedResource}?index=${i}&field=${REQUIRED_FIELDS[j]}`,
          status: 400,
          message: `${REQUIRED_FIELDS[j]} missing from sample`,
        });
        console.error(`index=${i}: ${errors[errors.length-1].message}`);
        badfields = true;
        continue;
      }
    }

    // check if child ID in sample (if present) and in path agree with each other
    if (samples[i].child_id !== undefined && samples[i].child_id !== childID) {
      errors.push({
        resource: `${resolvedResource}?index=${i}&field=child_id`,
        status: 400,
        message: `child IDs don't match in sample (${samples[i].child_id}) and in path (${childID})`,
      });
      console.error(`index=${i}: ${errors[errors.length-1].message}`);
      badfields = true;
    }

    // check if timestamp is in correct format
    if (samples[i].timestamp !== undefined &&
         (!isMatch(samples[i].timestamp, DATETIME_FORMAT_UTC) ||
          !isMatch(samples[i].timestamp, DATETIME_FORMAT_WITHOFFSET))) {
      errors.push({
        resource: `${resolvedResource}?index=${i}&field=timestamp`,
        status: 400,
        message: `timestamp must be in full ISO8601 datetime format with offset OR in UTC`,
      });
      console.error(`index=${i}: ${errors[errors.length-1].message}`);
      continue;
    }

    if (badfields) {
      continue;  // to next sample
    }

    // structuredClone is new to JS but available in Node
    let logSample = structuredClone(samples[i]);
    delete logSample.child_id;  // if present
    delete logSample.timestamp;
    console.log(`sample ${i+1}/${samples.length}: adding sample with timestamp "${samples[i].timestamp}": ${JSON.stringify(logSample)}`);
    const escapedIdentifiersList = REQUIRED_FIELDS.map(f => pg.escapeIdentifier(f)).join(',');
    const queryFieldNumbers = Array(REQUIRED_FIELDS.length).fill().map((_,i) => 1 + 1+i);
    // Don't need to add BEGIN and COMMIT (plus ROLLBACK) statements because this is atomic.
    try {
      await db.query(
        `INSERT INTO samples (child_id,
                              ${escapedIdentifiersList})
         VALUES ($1,
                 ${queryFieldNumbers.map(n => '$' + n).join(',')})`,
        [childID].concat(REQUIRED_FIELDS.map(f => samples[i][f])));
    } catch (e) {
      if (e.code === UNIQUE_VIOLATION && e.constraint === "samples_pkey") {
        errors.push({
          resource: `${resolvedResource}?index=${i}&field=timestamp`,
          status: 409,
          message: `sample timestamp already seen`,
        });
        console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
        continue;
      } else if (e.code === FOREIGN_KEY_VIOLATION && e.constraint === "samples_child_id_fkey") {
        // FIXME: Handle permissions.
        errors.push({
          resource: resolvedResource,
          status: 403,
          message: `child ID doesn't exist or user is not authorised to add samples to the child`,
        });
        console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
        break;
      } else if (e.code === INVALID_TEXT_REPRESENTATION) {
        const m = e.where.match(/\$(?<param>[0-9]+)/);
        if (!m) {
          console.error("can't parse parameter number from postgresql error");
          throw e;
        }

        // We assume that queryFieldNumbers is a contiguous interval of integers
        if (!(queryFieldNumbers[0] <= m.groups.param && m.groups.param <= queryFieldNumbers[queryFieldNumbers.length-1])) {
          console.error(`unhandled parameter number ${m.groups.param}`);
          throw e;
        }
        // Now we map the number from `queryFieldNumbers` to an actual field name
        const badField = REQUIRED_FIELDS[m.groups.param - queryFieldNumbers[0]];
        errors.push({
          resource: `${resolvedResource}?index=${i}&field=${badField}`,
          status: 400,
          message: "failed to parse value",
        });
        console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
        continue;
      } else if (e.code === CHECK_VIOLATION) {
        const m = e.constraint.match(/(?<field>[a-z_]+)_range/);
        if (!m) {
          console.error("can't parse field from CHECK_VIOLATION postgresql error");
          throw e;
        }
        switch (m.groups.field) {
        case 'light':
        case 'uv':
        case 'col_red':
        case 'col_green':
        case 'col_blue':
        case 'col_clear':
        case 'col_temp':
          break;
        default:
          console.error(`invalid field "${m.groups.field}"`);
          throw e;
        }
        errors.push({
          resource: `${resolvedResource}?index=${i}&field=${m.groups.field}`,
          status: 400,
          message: "field value out of range",
        });
        console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
        continue;
      } else {
        throw e;
      }
    }
  }

  const response = {};
  if (errors.length > 0) {
    response.statusCode = 207;
    response.body = JSON.stringify({
      "errors": errors,
    });
  } else {
    response.statusCode = 204;
  }
  addCorsHeaders(response);
  return response;
};
