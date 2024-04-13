import {
  addCorsHeaders,
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  // NOTE: for now, not checking child IDs
  // NOTE: for now, not checking payload fields to see if they match column names of DB
  let samples = JSON.parse(event.body).samples;
  let childID = event.pathParameters.childID;
  try {
    await db.query("BEGIN");
    for (let i=0; i<samples.length; i++) {
      await db.query(
        "INSERT INTO samples (tstamp,child_id,uv_index,lux) VALUES ($1,$2,$3,$4)",
        [samples[i].tstamp,
         childID,
         samples[i].uv_index,
         samples[i].lux],
      );
    }
    await db.query("COMMIT");
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
