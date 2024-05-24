import {
  addCorsHeaders,
  connectToDB,
  DATETIME_OUTPUT_FORMAT,
  authenticateUser,
  AUTH_NONE,
  AUTH_PARENT_OFCHILD,
  AUTH_RESEARCHER_OFSTUDY,
  AUTH_RESEARCHER_OFSAMESTUDYASCHILD,
} from "/opt/nodejs/lib.mjs";
import {
  format,
} from "date-fns";

let db = await connectToDB();

const SUBJECT_CHILD = "child";
const SUBJECT_STUDY = "study";

function unauth_message(subjectID)
{
  switch (subjectID) {
  case SUBJECT_CHILD:
    return "not authorised or child doesn't exist";
  case SUBJECT_STUDY:
    // researcher IDs don't really need to be protected
    return "not authorised";
  }
}

function make_handler(subjectID)
{
  return (async (event) => {
    const subjectIDName = (() => {
      switch (subjectID) {
      case SUBJECT_CHILD:
        return "childID";
      case SUBJECT_STUDY:
        return "studyID";
      }
    })();
    const subjectIDValue = decodeURIComponent(event.pathParameters[subjectIDName]);
    const resolvedResource = event.resource.replace("{" + subjectIDName + "}", encodeURIComponent(subjectIDValue));

    const auth = await (async () => {
      switch (subjectID) {
      case SUBJECT_CHILD:
        return await authenticateUser(event, db, AUTH_PARENT_OFCHILD | AUTH_RESEARCHER_OFSAMESTUDYASCHILD, {"childID": subjectIDValue});
      case SUBJECT_STUDY:
        return await authenticateUser(event, db, AUTH_RESEARCHER_OFSTUDY, {"studyID": subjectIDValue});
      }
    })();
    if (auth === AUTH_NONE) {
      const unauthErrResp = {
        statusCode: 403,
        body: JSON.stringify({
          errors: [{
            resource: resolvedResource,
            status: 403,
            message: unauth_message(subjectID),
          }],
        }),
      };
      addCorsHeaders(unauthErrResp);
      return unauthErrResp;
    }

    let res;
    switch (subjectID) {
    case SUBJECT_CHILD:
      res = await db.query("SELECT * FROM samples WHERE child_id = $1", [subjectIDValue]);
      if (res.rows.length === 0 &&
          (await db.query("SELECT * FROM children WHERE id = $1", [subjectIDValue])).rows.length === 0) {
        const unauthOrNoSuchChildErrResp = {
          // we want to protect child IDs
          statusCode: 403,
          body: JSON.stringify({
            errors: [{
              resource: resolvedResource,
              status: 403,
              message: unauth_message(subjectID),
            }],
          }),
        };
        addCorsHeaders(unauthOrNoSuchChildErrResp);
        return unauthOrNoSuchChildErrResp;
      }
      break;
    case SUBJECT_STUDY:
      res = await db.query(`SELECT smp.*,
                                   c.gender,
                                   extract(year from age(c.birthdate)) AS "age"
                            FROM samples as smp, study_children as sc, children as c
                            WHERE upper(sc.study_id) = upper($1)
                              AND c.id = sc.participant_id AND sc.participant_id = smp.child_id`,
                           [subjectIDValue]);
      if (res.rows.length === 0 &&
          (await db.query("SELECT * FROM studies WHERE upper(id) = upper($1)", [subjectIDValue])).rows.length === 0) {
        const noSuchStudyErrResp = {
          statusCode: 404,
          body: JSON.stringify({
            errors: [{
              resource: resolvedResource,
              status: 404,
              message: "study doesn't exist",
            }],
          }),
        };
        addCorsHeaders(noSuchStudyErrResp);
        return noSuchStudyErrResp;
      }
      break;
    }
    for (let i=0; i<res.rows.length; i++) {
      res.rows[i].timestamp = format(res.rows[i].timestamp, DATETIME_OUTPUT_FORMAT);
    }
    console.log(`returning ${res.rows.length} samples`);
    const goodResp = {
      statusCode: 200,
      body: JSON.stringify({
        data: res.rows,
      });
    }
    addCorsHeaders(goodResp);
    return goodResp;
  });
}

export const handler_child = make_handler(SUBJECT_CHILD);
export const handler_study = make_handler(SUBJECT_STUDY);
