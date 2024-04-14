import {
  addCorsHeaders,
  connectToDB,
  generateID,
  TEMP_PARENT_ID,
} from "/opt/nodejs/lib.mjs";
import assert from "node:assert/strict";

let db = await connectToDB();

// TODO: replace with AWS Cognito calls
// NOTE: empty `fields` means nothing happens
const PERSONAL_INFO_FIELDS_CHILD = [
  "birthdate",
  "family_name",
  "given_name",
  "middle_name",
  "nickname",
];

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

async function setPersonalInfoFields(db, infoResource, childID, fields)
{
  let errors = [];
  for (let f in fields) {
    // FIXME: O(n) -> O(n^2) when `fields` contains all fields AND
    // `fields` comes from client input, so it can get very large.
    if (!(PERSONAL_INFO_FIELDS_CHILD.includes(f))) {
      errors.push({
        resource: `${infoResource}?field=${encodeURIComponent(f)}`,
        status: 400,
        message: "bad field name"
      });
      continue;
    }
    try {
      // Inefficient since we only set one field at a time but it's easier to isolate which field is bad.
      // We can trust the value of `f` to be a valid and whitelisted column identifier.
      await db.query(`UPDATE children SET ${f} = $2 WHERE id = $1`,
                     [childID, fields[f]]);
      console.log(`set field ${f} to "${fields[f]}"`);
    } catch (e) {
      console.error(e);
      errors.push({
        resource: `${infoResource}?field=${encodeURIComponent(f)}`,
        status: 400,
        message: "bad field"
      });
    }
  }
  return errors;
}

export const handler = async (event) => {
  const childID = event.pathParameters.childID;
  const infoResource = event.resource.replace("{childID}", childID);
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
        infoResource,
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
        resource: infoResource,
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
    assert(response.data === undefined, "info replace/update action returned some data but it should never do it");
  }

  addCorsHeaders(response);
  return response;
};
