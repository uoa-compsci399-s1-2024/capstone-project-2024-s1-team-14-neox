import {
  addCorsHeaders,
  connectToDB,
  validateContentType,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

const REQUIRED_FIELDS = [
  "timestamp".
  "uv",
  "light,"
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
  let sampleMapping = JSON.parse(event.body);
  let childID;
  let errors = [];
  try {
    await db.query("BEGIN");
    for (childID in sampleMapping) {
      let resolvedResource = `${event.resource}/${childID}`;
      let currSamples = sampleMapping[childID];
      for (let i=0; i<currSamples.length; i++) {
        for (let j=0; j<REQUIRED_FIELDS.length; j++) {
          if (currSamples[i][REQUIRED_FIELDS[j]] == null) {
            errors.push({
              resource: `${resolvedResource}?index=${i}&field=${REQUIRED_FIELDS[j]}`,
              status: 400,
              message: `${REQUIRED_FIELDS[j]} missing from sample`,
            });
            console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
            continue;
          }
          if (currSamples[i].child_id !== undefined && currSamples[i].child_id !== childID) {
            errors.push({
              resource: `${resolvedResource}?index=${i}&field=child_id`,
              status: 400,
              message: `child IDs don't match in sample (${currSamples[i].child_id}) and in containing object (${childID})`,
            });
            console.error(`${childID}:index=${i}: ${errors[errors.length-1].message}`);
            continue;
          }
        }

        // structuredClone is new to JS but available in Node
        let logSample = structuredClone(currSamples[i]);
        delete logSample.child_id;  // if present
        delete logSample.timestamp;
        console.log(`adding sample for child ID "${childID}" with timestamp "${currSamples[i].timestamp}": ${JSON.stringify(logSample)}`);
        // TODO check if child exists
        await db.query(
          "INSERT INTO samples (\"timestamp\",child_id,uv,light) VALUES ($1,$2,$3,$4)",
          [currSamples[i].timestamp,
           childID,
           currSamples[i].uv,
           currSamples[i].light],
        );
      }
      await db.query("COMMIT");
    }
  } catch (e) {
    await db.query("ROLLBACK");
    throw e;
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
