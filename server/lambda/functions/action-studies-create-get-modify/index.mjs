import {
  addCorsHeaders,
  connectToDB,
  authenticateUser,
  AUTH_NONE,
  AUTH_ADMIN,
  AUTH_ALL,
} from "/opt/nodejs/lib.mjs";
import assert from "node:assert/strict";
import {
  format,
  isMatch,
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
  {"name": "start_date"  , "required": true},
  {"name": "end_date"    , "required": true},
];
const STUDY_DATE_FORMAT = "yyyy-MM-dd";

const ACTION_CREATE = "create";
const ACTION_FETCH = "fetch";
const ACTION_MODIFY = "modify";

const STUDYID_REGEX = /^[A-Za-z0-9]+$/;

function readParams(event)
{
  return {
    studyID: event.pathParameters.studyID,
    resolvedResource: event.resource.replace("{studyID}", encodeURIComponent(event.pathParameters.studyID)),
  };
}

function make_handler(actionID)
{
  return (async (event) => {
    console.log(`action: ${actionID}`);
    console.log(`http method: ${event.httpMethod.toUpperCase()}`)
    const p = readParams(event);
    console.log(`studyID: ${p.studyID}`);

    // We check studyid format in JS and only upon creation so that
    // the format can change without having to recreate the DB tables.
    if (actionID === ACTION_CREATE) {
      if (!(p.studyID.match(STUDYID_REGEX))) {
        const badStudyIdErrResp = {
          statusCode: 400,
          body: JSON.stringify({
            errors: [{
              resource: p.resolvedResource,
              status: 400,
              message: `invalid study id, it must match the regular expression: ${STUDYID_REGEX}`,
            }]
          }),
        };
        addCorsHeaders(badStudyIdErrResp);
        return badStudyIdErrResp;
      }
    }

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

    switch (actionID) {
    case ACTION_FETCH: {
      let res;
      try {
        res = await db.query("SELECT * FROM studies WHERE upper(id) = upper($1)", [p.studyID]);
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
      addCorsHeaders(goodResp);
      return goodResp;
    }
    case ACTION_CREATE:
    case ACTION_MODIFY: {
      let fields = JSON.parse(event.body);
      console.log(`got fields: ${JSON.stringify(fields)}`);

      let errors = [];

      // ensure all fields provided actually exist
      for (let fname in fields) {
        if (!(STUDY_METADATA_FIELDS.map(mf => mf.name).includes(fname))) {
          errors.push({
            resource: `${p.resolvedResource}?fieldname=${fname}`,
            status: 400,
            message: "bad field name"
          });
        }
      }

      // check if all required fields are present
      if (actionID === ACTION_CREATE ||
          // don't need all fields if just doing PATCH
          (actionID === ACTION_MODIFY && event.httpMethod.toUpperCase() === "PUT")) {
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
      let paramNum = 2;
      // the order in the sql param list (needed since object key iteration order is indeterminate)
      const sqlFields = [];
      if (actionID === ACTION_MODIFY && event.httpMethod.toUpperCase() === "PUT") {
        const missingOptionalFields = [];
        for (mf of STUDY_METADATA_FIELDS) {
          if (fields[mf.name] === undefined) {
            fields[mf.name] = null;
            missingOptionalFields.push(mf.name);
          }
        }
        console.log("adding missing (null) fields so that the action to replace study info resets missing fields to null");
        console.log(`missing fields: ${JSON.stringify(missingOptionalFields)}`);
      }
      for (let fname in fields) {
        sqlFields.push({
          "column": pg.escapeIdentifier(fname),
          "value": fields[fname],
          "paramNum": paramNum,
        });
        paramNum++;
      }
      try {
        switch (actionID) {
        case ACTION_CREATE: {
          await db.query(`INSERT INTO studies (id, ${sqlFields.map(sf => sf.column).join(',')})
                          VALUES (upper($1), ${sqlFields.map(sf => '$' + sf.paramNum).join(',')})`,
                         [p.studyID].concat(sqlFields.map(sf => sf.value)));
          break;
        }
        case ACTION_MODIFY: {
          let res = await db.query(`UPDATE studies
                                    SET ${sqlFields.map(sf => sf.column + ' = ' + '$' + sf.paramNum).join(', ')}
                                    WHERE upper(id) = upper($1) RETURNING`,
                                   [p.studyID].concat(sqlFields.map(sf => sf.value)));
          if (res.rows.length === 0) {
            dbError = {
              resource: p.resolvedResource,
              status: 404,
              message: "study doesn't exist",
            };
          }
          break;
        }
        }
      } catch (e) {
        if (e.code === UNIQUE_VIOLATION && e.constraint === "studies_pkey") {
          assert(actionID === ACTION_CREATE);
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

export const handler_create = make_handler(ACTION_CREATE);
export const handler_fetch = make_handler(ACTION_FETCH);
export const handler_modify = make_handler(ACTION_MODIFY);
