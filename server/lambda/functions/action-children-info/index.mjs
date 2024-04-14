import {
  addCorsHeaders,
  connectToDB,
  generateID,
  TEMP_PARENT_ID,
  setPersonalInfoFields,
} from "/opt/nodejs/lib.mjs";
import assert from "node:assert/strict";

let db = await connectToDB();

async function clearPersonalInfoFields(db, childID)
{
  await db.query(`
    UPDATE children
      SET birthdate = NULL,
          family_name = NULL,
          given_name = NULL,
          middle_name = NULL,
          nickname = NULL
    WHERE id = $1`, [childID]);
}

export const handler = async (event) => {
  const childID = event.pathParameters.childID;
  // setPersonalInfoFields constructs a resource URI, so we want to avoid duplicate path parts
  const rootChildrenResource = event.resource.replace(/\/\{childID\}\/.*$/, "");
  const body = {};
  const response = {};
  console.log(`method: ${event.httpMethod}`);
  if (event.httpMethod.toUpperCase() == "GET") {
    let res;
    try {
      res = await db.query("SELECT * FROM children WHERE id = $1", [childID]);
    } catch (e) {
      throw e;
    }
    const fields = res.rows[0];
    delete fields.id;
    delete fields.parent_id;
    body.data = fields;
    response.statusCode = 200;
    response.body = JSON.stringify(body);
  } else {
    assert(event.httpMethod.toUpperCase() == "PUT" || event.httpMethod.toUpperCase() == "PATCH");
    let personal_info = JSON.parse(event.body);
    let errors;
    try {
      await db.query("BEGIN");
      if (event.httpMethod.toUpperCase() == "PUT") {
        await clearPersonalInfoFields(db, childID);
      }
      errors = await setPersonalInfoFields(
        db,
        rootChildrenResource,
        childID,
        personal_info
      );
      await db.query("COMMIT");
    } catch (e) {
      await db.query("ROLLBACK");
      if (errors === undefined) {
        // failed before we got to set any fields
        errors = [];
      }
      errors.push({
        resource: resolvedResource,
        status: 500,
        message: "internal server error"
      });
      // will be overwritten later if there were any errors at all when setting fields.
      response.statusCode = 500;
      console.error(e);
    }
    if (errors.length > 0) {
      response.statusCode = 207;
      body.errors = errors;
      response.body = JSON.stringify(body);
    } else {
      response.statusCode = 204;
    }
  }

  addCorsHeaders(response);
  return response;
};
