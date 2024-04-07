import {
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
        await db.query(
          "INSERT INTO samples (tstamp,child_id,uv_index,lux) VALUES ($1,$2,$3,$4)",
          [currSamples[i].tstamp,
           childID,
           currSamples[i].uv_index,
           currSamples[i].lux],
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
  return response;
};
