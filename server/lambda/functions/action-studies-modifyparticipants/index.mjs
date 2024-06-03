import {
  addCorsHeaders,
  connectToDB,
  authenticateUser,
  AUTH_NONE,
  AUTH_ADMIN,
  AUTH_PARENT_OFCHILD,
} from "/opt/nodejs/lib.mjs";
import assert from "node:assert/strict";
import pg from "pg";
import {
  CHECK_VIOLATION,
  UNIQUE_VIOLATION,
  FOREIGN_KEY_VIOLATION,
} from "pg-error-constants";

let db = await connectToDB();

const SUBJECT_RESEARCHERS = "researchers";
const SUBJECT_CHILDREN = "children";

const UNAUTH_OR_NO_SUCH_PARTICIPANT_MESSAGE = "not authorised or no such participant";

function make_handler(subjectID)
{
  return (async (event) => {
    console.log(`subject: ${subjectID}`);
    console.log(`http method: ${event.httpMethod.toUpperCase()}`);
    const studyID = event.pathParameters.studyID;
    const subjectIDName = (() => {
      switch (subjectID) {
      case SUBJECT_RESEARCHERS:
        return "researcherID";
      case SUBJECT_CHILDREN:
        return "childID";
      }
    })();
    const subjectIDValue = decodeURIComponent(event.pathParameters[subjectIDName]);
    const resolvedResource = (event.resource
                              .replace("{studyID}", encodeURIComponent(studyID))
                              .replace("{" + subjectIDName + "}", encodeURIComponent(subjectIDValue)));
    console.log(`studyID: ${studyID}`);
    console.log(`participantID: ${subjectIDValue}`);

    const auth = await (async () => {
      switch (subjectID) {
      case SUBJECT_RESEARCHERS:
        return await authenticateUser(event, db, AUTH_ADMIN);
      case SUBJECT_CHILDREN: {
        let authFlags = AUTH_PARENT_OFCHILD;
        if (event.httpMethod.toUpperCase() === "DELETE") {
          authFlags |= AUTH_ADMIN;
        }
        return await authenticateUser(event, db, authFlags, {"childID": subjectIDValue});
      }
      }
    })();
    if (auth === AUTH_NONE) {
      const errResp = {
        statusCode: 403,
        body: JSON.stringify({
          errors: [{
            resource: resolvedResource,
            status: 403,
            message: UNAUTH_OR_NO_SUCH_PARTICIPANT_MESSAGE,
          }]
        }),
      };
      addCorsHeaders(errResp);
      return errResp;
    }

    let dbError = null;
    try {
      switch (event.httpMethod.toUpperCase()) {
      case "PUT":
        await db.query(`INSERT INTO study_${subjectID} (study_id, participant_id) VALUES (upper($1), $2)`,
                       [studyID, subjectIDValue]);
        break;
      case "DELETE": {
        let res = await db.query(`DELETE FROM study_${subjectID}
                                  WHERE upper(study_id) = upper($1) AND participant_id = $2
                                  RETURNING *`,
                                 [studyID, subjectIDValue]);
        if (res.rows.length === 0) {
          console.log("need to differentiate between no such study or no such participant...");
          if ((await db.query("SELECT * FROM studies WHERE upper(id) = upper($1)",
                              [studyID])).rows.length === 0) {
            console.log("no such study");
            // FIXME: race condition in case a study with the same ID is made in between the DB calls
            // BUT it doesn't actually matter since it just determines the error message
            dbError = {
              resource: resolvedResource,
              status: 404,
              message: "study doesn't exist",
            };
          } else {
            console.log("either user is not part of study OR no such user");
            dbError = {
              resource: resolvedResource,
              status: 403,
              message: UNAUTH_OR_NO_SUCH_PARTICIPANT_MESSAGE,
            };
          }
        }
        break;
      }
      }
    } catch (e) {
      if (e.code === UNIQUE_VIOLATION && e.constraint === `study_${subjectID}_pkey`) {
        assert(event.httpMethod.toUpperCase() === "PUT");
        console.log("doing nothing since it's OK if we re-add the same participant to the study");
      } else if (e.code === FOREIGN_KEY_VIOLATION && e.constraint === `study_${subjectID}_study_id_fkey`) {
        assert(event.httpMethod.toUpperCase() === "PUT");
        console.log("no such study");
        dbError = {
          resource: resolvedResource,
          status: 404,
          message: "study doesn't exist",
        };
      } else if (e.code === FOREIGN_KEY_VIOLATION && e.constraint === `study_${subjectID}_participant_id_fkey`) {
        assert(event.httpMethod.toUpperCase() === "PUT");
        console.log("no such participant");
        dbError = {
          resource: resolvedResource,
          status: 403,
          message: UNAUTH_OR_NO_SUCH_PARTICIPANT_MESSAGE,
        };
      } else {
        throw e;
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
  });
}

export const handler_researchers = make_handler(SUBJECT_RESEARCHERS);
export const handler_children = make_handler(SUBJECT_CHILDREN);
