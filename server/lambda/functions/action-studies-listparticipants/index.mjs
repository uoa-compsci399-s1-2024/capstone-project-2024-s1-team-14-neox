import {
  addCorsHeaders,
  connectToDB,
  authenticateUser,
  AUTH_NONE,
  AUTH_ADMIN,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  const studyID = decodeURIComponent(event.pathParameters.studyID);
  const resolvedResource = event.resource.replace("{studyID}", encodeURIComponent(studyID));
  console.log(`studyID: ${studyID}`);

  const auth = await authenticateUser(event, db, AUTH_ADMIN);
  if (auth === AUTH_NONE) {
    const unauthResp = {
      statusCode: 403,
      body: JSON.stringify({
        errors: [{
          resource: resolvedResource,
          status: 403,
          message: "not authorised",
        }]
      }),
    };
    addCorsHeaders(unauthResp);
    return unauthResp;
  }

  let res;
  try {
    res = await db.query("SELECT id FROM studies WHERE upper(id) = upper($1)", [studyID]);
  } catch (e) {
    console.error(e);
    const dbErrResp = {
      statusCode: 500,
      body: JSON.stringify({
        errors: [{
          resource: resolvedResource,
          status: 500,
          message: "internal server error",
        }]
      }),
    };
    addCorsHeaders(dbErrResp);
    return dbErrResp;
  }
  if (res.rows.length === 0) {
    console.log("no such study");
    const noSuchStudyErrResp = {
      statusCode: 404,
      body: JSON.stringify({
        errors: [{
          resource: resolvedResource,
          status: 404,
          message: "study doesn't exist",
        }]
      }),
    };
    addCorsHeaders(noSuchStudyErrResp);
    return noSuchStudyErrResp
  }

  const studyResearchers = (await db.query(`SELECT participant_id AS id
                                            FROM study_researchers
                                            WHERE upper(study_id) = upper($1)`,
                                           [studyID])).rows;
  const studyChildren = (await db.query(`SELECT c.id AS id, c.parent_id AS parent_id
                                         FROM study_children AS sc, children AS c
                                         WHERE upper(sc.study_id) = upper($1)
                                           AND sc.participant_id = c.id`,
                                        [studyID])).rows;
  // dedupe parent IDs and rename field to `id`
  const studyParents = (Array.from(new Set(studyChildren.map(sc => sc.parent_id)))
                        .map(id => ({"id": id})));
  console.log(`researchers: ${JSON.stringify(studyResearchers)}`);
  console.log(`children: ${JSON.stringify(studyChildren)}`);
  console.log(`parents: ${JSON.stringify(studyParents)}`);
  const goodResp = {
    statusCode: 200,
    body: JSON.stringify({
      data: {
        researchers: studyResearchers,
        children: studyChildren,
        parents: studyParents,
      },
    }),
  };
  addCorsHeaders(goodResp);
  return goodResp;
};
