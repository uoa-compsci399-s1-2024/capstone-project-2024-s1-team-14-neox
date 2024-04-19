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

let db = await connectToDB();

const REQUIRED_FIELDS = [
  "timestamp",
  "uv",
  "light",
];

export const handler = async (event) => {
  const contentTypeError = validateContentType(event.headers, event.resource);
  if (contentTypeError !== null) {
    const errorResp = {
      statusCode: 400,
      body: JSON.stringify({errors: [contentTypeError]}),
    };
    addCorsHeaders(errorResp);
    return errorResp;
  }
  // NOTE: for now, not checking child IDs
  // NOTE: for now, not checking payload fields to see if they match column names of DB
  let sampleMapping;
  try {
    sampleMapping = JSON.parse(event.body);
  } catch (e) {
    console.error(e);
    const errorResp = {
      statusCode: 400,
      body: JSON.stringify({
        errors: [
          {
            response: event.resource,
            status: 400,
            message: "missing request body",
          }
        ]
      }),
    };
    addCorsHeaders(errorResp);
    return errorResp;
  }
  let childID;
  let errors = [];
  for (childID in sampleMapping) {
    let resolvedResource = `${event.resource}/${childID}`;
    let currSamples = sampleMapping[childID];
    for (let i=0; i<currSamples.length; i++) {
      let missingfields = false;
      for (let j=0; j<REQUIRED_FIELDS.length; j++) {
        if (currSamples[i][REQUIRED_FIELDS[j]] == null) {
          errors.push({
            resource: `${resolvedResource}?index=${i}&field=${REQUIRED_FIELDS[j]}`,
            status: 400,
            message: `${REQUIRED_FIELDS[j]} missing from sample`,
          });
          console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
          missingfields = true;
          continue;
        }
        if (currSamples[i].child_id !== undefined && currSamples[i].child_id !== childID) {
          errors.push({
            resource: `${resolvedResource}?index=${i}&field=child_id`,
            status: 400,
            message: `child IDs don't match in sample (${currSamples[i].child_id}) and in containing object (${childID})`,
          });
          console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
          missingfields = true;
          continue;
        }
      }
      if (missingfields) {
        continue;  // to next sample
      }

      if (!isMatch(currSamples[i].timestamp, DATETIME_FORMAT_UTC) ||
          !isMatch(currSamples[i].timestamp, DATETIME_FORMAT_WITHOFFSET)) {
        errors.push({
          resource: `${resolvedResource}?index=${i}&field=timestamp`,
          status: 400,
          message: `timestamp must be in full ISO8601 datetime format with offset OR in UTC`,
        });
        console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
        continue;
      }

      // structuredClone is new to JS but available in Node
      let logSample = structuredClone(currSamples[i]);
      delete logSample.child_id;  // if present
      delete logSample.timestamp;
      console.log(`adding sample for child ID "${childID}" with timestamp "${currSamples[i].timestamp}": ${JSON.stringify(logSample)}`);
      // TODO check if child exists
      // Don't need to add BEGIN and COMMIT (plus ROLLBACK) statements because this is atomic.
      try {
        await db.query(
          "INSERT INTO samples (\"timestamp\",child_id,uv,light) VALUES ($1,$2,$3,$4)",
          [currSamples[i].timestamp,
           childID,
           currSamples[i].uv,
           currSamples[i].light],
        );
      } catch (e) {
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
