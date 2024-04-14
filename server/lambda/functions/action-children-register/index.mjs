import {
  addCorsHeaders,
  connectToDB,
  generateID,
  TEMP_PARENT_ID,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  let tentativeChildID = generateID();
  // TODO: retry child IDs if there are conflicts in DB.
  try {
    await db.query(
      "INSERT INTO children (id,parent_id) VALUES ($1,$2)",
      [tentativeChildID,TEMP_PARENT_ID]
    );
  } catch (e) {
    throw e;
  }
  const finalChildID = tentativeChildID;
  console.log(`made child row with id ${finalChildID}`);
  const response = {
    statusCode: 200,
    body: JSON.stringify(
      {
        data: {
          id: finalChildID,
        }
      }
    ),
  };
  addCorsHeaders(response);
  return response;
};
