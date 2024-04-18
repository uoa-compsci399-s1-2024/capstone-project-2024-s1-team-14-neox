import {
  addCorsHeaders,
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  // NOTE: for now, not checking child IDs
  // NOTE: for now, not checking payload fields to see if they match column names of DB
  let sampleMapping = JSON.parse(event.body);
  let childID;
  try {
    await db.query("BEGIN");
    for (childID in sampleMapping) {
      let currSamples = sampleMapping[childID];
      for (let i=0; i<currSamples.length; i++) {
        console.log(`adding sample for child ID "${childID}" with timestamp "${currSamples[i].timestamp}": {uv: "${currSamples[i].uv}", light: "${currSamples[i].light}"}`);
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
  const response = {
    statusCode: 200,
  };
  addCorsHeaders(response);
  return response;
};
