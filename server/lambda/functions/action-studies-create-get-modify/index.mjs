import {
  addCorsHeaders,
  connectToDB,
  generateID,
  authenticateUser,
  AUTH_NONE,
  AUTH_ADMIN,
  getDBUserIdFromEvent,
} from "/opt/nodejs/lib.mjs";
import assert from "node:assert/strict";
import {
  format,
  isMatch,
  RangeError,
} from "date-fns";
import pg from "pg";
import {
  CHECK_VIOLATION,
  UNIQUE_VIOLATION,
} from "pg-error-constants";

let db = await connectToDB();

// fields are only "required" (non-null and non-undefined) when first creating a study or doing PUT on the metadata
// NOTE: studyID is not a field but part of the URI
const STUDY_METADATA_FIELDS = [
  {"name": "name"        , "required": false},
  {"name": "description" , "required": false},
  {"name": "start_date"    , "required": true},
  {"name": "end_date"    , "required": true},
];
const STUDY_DATE_FORMAT = "yyyy-MM-dd";

// async function setMetadataFields(db, resource, studyID, fields)
// {
//   let errors = [];
//   for (let f in fields) {

//     try {
//       // Inefficient since we only set one field at a time but it's easier to isolate which field is bad.
//       // We can trust the value of `f` to be a valid and whitelisted column identifier.
//       await db.query(`UPDATE studies SET ${f} = $2 WHERE id = $1`,
//                      [studyID, fields[f]]);
//       console.log(`set field ${f} to "${fields[f]}"`);
//     } catch (e) {
//       console.error(e);
//       errors.push({
//         resource: `${resource}?fieldvalue=${encodeURIComponent(f)}`,
//         status: 400,
//         message: "bad field"
//       });
//     }
//   }
//   for (let i=0; i<errors.length; i++) {
//     console.error(`field setting error ${i+1}/${errors.length}: ${JSON.stringify(errors[i])}`);
//   }
//   return errors;
// }

const ACTION_CREATE = "create";
const ACTION_FETCH = "fetch";
const ACTION_MODIFY = "modify";

function readParams(event)
{
  return {
    studyID: event.pathParameters.studyID,
    resolvedResource: event.resource.replace("{studyID}", encodeURIComponent(event.pathParameters.studyID)),
  };
}

export const handler_create = make_handler(ACTION_CREATE);
function make_handler(actionId)
{
  return (async (event) => {
    const p = readParams(event);
    console.log(`studyID: ${p.studyID}`);

    const authFlags = (() => {
      switch (actionID) {
      case ACTION_CREATE:
      case ACTION_MODIFY:
        return AUTH_ADMIN;
      case ACTION_FETCH:
        return AUTH_ALL;
      }
    })();

    const auth = await authenticateUser(event, db, authFlags);
    if (auth === AUTH_NONE) {
      const errResp = {
        statusCode: 403,
        body: JSON.stringify({
          errors: [{
            resource: p.resolvedResource,
            status: 403,
            message: "not authorised",
          }]
        }),
      };
      addCorsHeaders(errResp);
      return errResp;
    }

    switch (actionId) {
    case ACTION_FETCH: {
      // TODO
      let res;
      try {
        res = await db.query("SELECT * FROM studies WHERE id = $1", [p.studyID]);
      } catch (e) {
        throw e;
      }
      if (res.rows.length === 0) {
        const noSuchStudyErrResp = {
          statusCode: 404,
          body: JSON.stringify({
            errors: [{
              resource: p.resolvedResource,
              status: 404,
              message: "study doesn't exist"
            }],
          }),
        };
        addCorsHeaders(noSuchStudyErrResp);
        return noSuchStudyErrResp;
      }

      const fields = res.rows[0];
      let deletedFields = [];
      for (let f in fields) {
        if (!(STUDY_METADATA_FIELDS.map(mf => mf.name).includes(f))) {
          delete fields[f];
          deletedFields.push(f);
        }
      }
      console.log(`${p.studyID}: deleted the following fields before sending to caller: ${deletedFields}`);
      if (fields.start_date != null) {
        fields.start_date = format(fields.start_date, STUDY_DATE_FORMAT);
      }
      if (fields.end_date != null) {
        fields.end_date = format(fields.end_date, STUDY_DATE_FORMAT);
      }
      const goodResp = {
        statusCode: 200,
        body: JSON.stringify({
          data: fields,
        }),
      };
    }
    case ACTION_CREATE:
    case ACTION_MODIFY: {
      let study_info = JSON.parse(event.body);
      console.log(`got fields: ${JSON.stringify(study_info)}`);

      let errors = [];

      // ensure all fields provided actually exist
      for (let fname in study_info) {
        if (!(STUDY_METADATA_FIELDS.map(mf => mf.name).includes(fname))) {
          errors.push({
            resource: `${p.resolvedResource}?fieldname=${fname}`,
            status: 400,
            message: "bad field name"
          });
        }
      }

      // check if all required fields are present
      if (actionId === ACTION_CREATE ||
          // don't need all fields if just doing PATCH
          (actionId === ACTION_MODIFY && event.httpMethod.toUpperCase() === "PUT")) {
        for (let f of STUDY_METADATA_FIELDS.filter(mf => mf.required).map(mf => mf.name)) {
          if (fields[f] == null) {
            errors.push({
              resource: `${p.resolvedResource}?fieldname=${f}`,
              status: 400,
              message: `${f} missing from info`,
            });
            console.error(`${errors[errors.length-1].message}`);
          }
        }
      }

      // check if date in right format
      if (fields.start_date !== undefined && !isMatch(fields.start_date, STUDY_DATE_FORMAT)) {
        errors.push({
          resource: `${p.resolvedResource}?fieldvalue=start_date`,
          status: 400,
          message: "research period must be YYYY-MM-DD dates",
        });
      }
      if (fields.end_date !== undefined && !isMatch(fields.end_date, STUDY_DATE_FORMAT)) {
        errors.push({
          resource: `${p.resolvedResource}?fieldvalue=end_date`,
          status: 400,
          message: "research period must be YYYY-MM-DD dates",
        });
      }

      if (errors.length > 0) {
        const earlyFieldErrResp = {
          statusCode: 400,
          body: JSON.stringify({
            "errors": errors
          }),
        };
        addCorsHeaders(earlyFieldErrResp);
        return earlyFieldErrResp;
      }

      let dbError = null;
      try {
        switch (actionId) {
        case ACTION_CREATE:
          const columnsList = STUDY_METADATA_FIELDS.map(mf => pg.escapeIdentifier(mf.name)).join(", ");
          // 1+i since PostgreSQL parameters start from 1
          // n + (1+i) to put fields in PostgreSQL parameters *after* `n`
          const queryFieldNumbers = Array(STUDY_METADATA_FIELDS.length).fill().map((_,i) => 1 + 1+i);
          await = db.query(`
            INSERT INTO studies (id, ${columnsList})
            VALUES ($1, ${queryFieldNumbers.map(n => '$' + n).join(',')})`);
          break;
        case ACTION_MODIFY:
          const sqlUpdateSetExpressions = [];
          let paramNum = 2;
          // the order in the sql param list (needed since object key iteration order is indeterminate)
          const fieldNameParamOrder = [];
          for (let fname in fields) {
            sqlUpdateSetExpressions.push(`${pg.escapeIdentifier(fname)} = $${paramNum}`);
            fieldNameParamOrder.push(fname);
            paramNum++;
          }
          let res = await db.query(`UPDATE studies SET ${sqlUpdateSetExpressions.join(', ')} WHERE id = $1 RETURNING`,
                                   [p.studyID].concat(fieldNameParamOrder.map(fname => fields[fname])));
          if (res.rows.length === 0) {
            dbError = {
              resource: p.resolvedResource,
              status: 404,
              message: "study doesn't exist",
            };
          }
          break;
        }
      } catch (e) {
        if (e.code === UNIQUE_VIOLATION && e.constraint === "studies_pkey") {
          assert(actionId === ACTION_CREATE);
          dbError = {
            resource: p.resolvedResource,
            status: 409,
            message: "study already exists",
          };
        } else if (e.code === CHECK_VIOLATION && e.constraint === "date_interval") {
          dbError = {
            resource: `${p.resolvedResource}?fieldvalue=start_date&fieldvalue=end_date`,
            status: 400,
            message: "start of research period must precede end of period",
          };
        } else {
          console.error(e);
          const unhandledErrResp = {
            statusCode: 500,
            body: JSON.stringify({
              errors: [{
                resource: p.resolvedResource,
                status: 500,
                message: "internal server error"
              }]
            }),
          };
          addCorsHeaders(unhandledErrResp);
          return unhandledErrResp;
        }
      }
      if (dbError != null) {
        const dbErrResp = {
          statusCode: dbError.status,
          body: JSON.stringify({
            errors: [dbError],
          }),
        };
        addCorsHeaders(dbErrResp);
        return dbErrResp;
      }

      const goodResp = {
        statusCode: 204,
      };
      addCorsHeaders(goodResp);
      return goodResp;
    }
    }
    assert(false, "an action did not return a response");
  });
}

export const handler_fetch = async (event) => {
  const childID = event.pathParameters.childID;
  const resolvedResource = event.resource.replace("{childID}", encodeURIComponent(childID));
  const body = {};
  const response = {};
  console.log(`childID: ${childID}`);
  assert(event.httpMethod.toUpperCase() === "GET");

  let res;
  try {
    res = await db.query("SELECT * FROM children WHERE id = $1", [childID]);
  } catch (e) {
    throw e;
  }

  const auth = await authenticateUser(event, db, AUTH_PARENT_OFCHILD, {"childID": childID});
  if (auth === AUTH_NONE) {
    body.errors = [{
      resource: resolvedResource,
      status: 403,
      message: `child ID doesn't exist or user is not authorised to view their personal info`,
    }];
    response.statusCode = body.errors[body.errors.length-1].status;
    response.body = JSON.stringify(body);
    addCorsHeaders(response);
    return response;
  }

  if (res.rows.length === 0){
    const err = {
      resource: resolvedResource,
      status: 403,
      message: `child ID doesn't exist or user is not authorised to view their personal info`,
    };
    console.error(`${childID}: ${err.message}`);
    body.errors = [err];
    response.statusCode = 403;
    response.body = JSON.stringify(body);
  } else {
    const fields = res.rows[0];
    let deletedFields = [];
    for (let f in fields) {
      if (!(PERSONAL_INFO_FIELDS_CHILD.includes(f))) {
        delete fields[f];
        deletedFields.push(f);
      }
    }
    console.log(`${childID}: deleted the following fields before sending to caller: ${deletedFields}`);
    if (fields.birthdate != null) {
      fields.birthdate = format(fields.birthdate, "yyyy-MM-dd");
    }
    body.data = fields;
    response.statusCode = 200;
  }

  response.body = JSON.stringify(body);
  addCorsHeaders(response);
  return response;
};

export const handler_modify = async (event) => {
  const childID = event.pathParameters.childID;
  const infoResource = event.resource.replace("{childID}", encodeURIComponent(childID));
  const body = {};
  const response = {};
  console.log(`childID: ${childID}`);
  assert(event.httpMethod.toUpperCase() === "PUT" || event.httpMethod.toUpperCase() === "PATCH");

  let personal_info = JSON.parse(event.body);
  console.log(`got fields: ${JSON.stringify(personal_info)}`);

  const auth = await authenticateUser(event, db, AUTH_PARENT_OFCHILD, {"childID": childID});
  if (auth === AUTH_NONE) {
    body.errors = [{
      resource: infoResource,
      status: 403,
      message: `child ID doesn't exist or user is not authorised to modify their personal info`,
    }];
    response.statusCode = body.errors[body.errors.length-1].status;
    response.body = JSON.stringify(body);
    addCorsHeaders(response);
    return response;
  }

  let errors;
  try {
    await db.query("BEGIN");
    if (event.httpMethod.toUpperCase() === "PUT") {
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

  response.body = JSON.stringify(body);
  addCorsHeaders(response);
  return response;
};
