import {
  addCorsHeaders,
  connectToDB,
  generateID,
  TEMP_PARENT_ID,
} from "/opt/nodejs/lib.mjs";
import assert from "node:assert/strict";

let db = await connectToDB();

// NOTE: empty `fields` means nothing happens
const PERSONAL_INFO_FIELDS_CHILD = [
  "birthdate",
  "family_name",
  "given_name",
  "middle_name",
  "nickname",
];

async function setPersonalInfoFields(db, infoResource, childID, fields)
{
  let errors = [];
  for (let f in fields) {
    // FIXME: O(n) -> O(n^2) when `fields` contains all fields.  Also,
    // `fields` comes from client input so it can get very large.
    if (!(PERSONAL_INFO_FIELDS_CHILD.includes(f))) {
      errors.push({
        resource: `${infoResource}?fieldname=${encodeURIComponent(f)}`,
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
        resource: `${infoResource}?fieldvalue=${encodeURIComponent(f)}`,
        status: 400,
        message: "bad field"
      });
    }
  }
  for (let i=0; i<errors.length; i++) {
    console.error(`field setting error ${i+1}/${errors.length}: ${JSON.stringify(errors[i])}`);
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

    if (res.rows.length === 0){
      // FIXME: Handle permissions
      const err = {
        resource: infoResource,
        status: 403,
        message: `child ID doesn't exist or user is not authorised to view their personal info`,
      };
      console.error(`${childID}: ${err.message}`);
      body.errors = [err];
      response.statusCode = 403;
      response.body = JSON.stringify(body);
    } else {
      assert(res.rows.length === 1, `${childID}: somehow saw multiple child rows with the same ID (which is primary key!)`);
      const fields = res.rows[0];
      delete fields.id;
      delete fields.parent_id;
      body.data = fields;
      response.statusCode = 200;
    }
  } else {
    assert(event.httpMethod.toUpperCase() == "PUT" || event.httpMethod.toUpperCase() == "PATCH");
    let personal_info = JSON.parse(event.body);
    let errors;
    try {
      await db.query("BEGIN");
      if (event.httpMethod.toUpperCase() == "PUT") {
        for (let i=0; i<PERSONAL_INFO_FIELDS_CHILD.length; i++) {
          await db.query(
            // We can trust PERSONAL_INFO_FIELDS_CHILD to only have valid fields.
            `UPDATE children SET ${PERSONAL_INFO_FIELDS_CHILD[i]} = NULL WHERE id = $1`,
            [childID]
          );
        }
      }
      errors = await setPersonalInfoFields(
        db,
        infoResource,
        childID,
        personal_info
      );
    } catch (e) {
      await db.query("ROLLBACK");
      response.statusCode = 500;
      body.errors = {
        resource: infoResource,
        status: 500,
        message: "internal server error"
      };
      console.error(e);
    }

    if (response.statusCode == 500) {
      // already rolled back
    } else if (errors.length > 0) {
      await db.query("ROLLBACK");
      response.statusCode = 400;
      body.errors = errors;
    } else {
      await db.query("COMMIT");
      response.statusCode = 204;
    }

    assert(response.data === undefined, "info replace/update action returned some data but it should never do it");
  }

  response.body = JSON.stringify(body);
  addCorsHeaders(response);
  return response;
};
