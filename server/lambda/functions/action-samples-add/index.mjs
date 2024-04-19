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
import {
  FOREIGN_KEY_VIOLATION,
  UNIQUE_VIOLATION,
} from "pg-error-constants";

let db = await connectToDB();

const REQUIRED_FIELDS = [
  "timestamp",
  "uv",
  "light",
];

export const handler = async (event) => {
  const childID = event.pathParameters.childID;
  const resolvedResource = event.resource.replace("{childID}", childID);

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
          response: resolvedResource,
          status: 400,
          message: "missing request body",
        }
      ],
    });
    return maybeEarlyErrorResp;
  }
  if (reqBody.samples === undefined) {
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          response: resolvedResource,
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
          response: resolvedResource,
          status: 400,
          message: "samples property in request body must be an array",
        }
      ]
    });
    return maybeEarlyErrorResp;
  }
  const samples = reqBody.samples;

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
        console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
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
      console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
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
      console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
      continue;
    }

    if (badfields) {
      continue;  // to next sample
    }

    // structuredClone is new to JS but available in Node
    let logSample = structuredClone(samples[i]);
    delete logSample.child_id;  // if present
    delete logSample.timestamp;
    console.log(`adding sample for child ID "${childID}" with timestamp "${samples[i].timestamp}": ${JSON.stringify(logSample)}`);
    // Don't need to add BEGIN and COMMIT (plus ROLLBACK) statements because this is atomic.
    try {
      await db.query(
        "INSERT INTO samples (\"timestamp\",child_id,uv,light) VALUES ($1,$2,$3,$4)",
        [samples[i].timestamp,
         childID,
         samples[i].uv,
         samples[i].light],
      );
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
