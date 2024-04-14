import {
  addCorsHeaders,
  connectToDB,
  generateID,
  TEMP_PARENT_ID,
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
  let errors = [];
  for (let field in personal_info) {
    // TODO: whitelist personal info fields
    try {
      await db.query("UPDATE children SET $2 = $3 WHERE id = $1",
                     [finalChildID, field, personal_info[field]]);
      console.log(`set field ${field} to "${personal_info[field]}"`);
    } catch (e) {
      console.error(e);
      errors.push({
        resource: `${event.resource}/${finalChildID}/info?field=${encodeURIComponent(field)}`,
        status: 400,
        message: "bad field"
      });
    }
  }
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
