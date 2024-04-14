import {
  addCorsHeaders,
  connectToDB,
  generateID,
  TEMP_PARENT_ID,
  setPersonalInfoFields,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  let personal_info = JSON.parse(event.body);

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
  let errors = await setPersonalInfoFields(db, event.resource, finalChildID, personal_info);
  const body = {data: finalChildID};
  const response = {};
  if (errors.length > 0) {
    response.statusCode = 207;
    body.errors = errors;
  } else {
    response.statusCode = 200;
  }
  addCorsHeaders(response);
  response.body = JSON.stringify(body);
  return response;
};
