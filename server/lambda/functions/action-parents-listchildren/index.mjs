import {
  addCorsHeaders,
  connectToDB,
  getDBUserIdFromEvent,
  authenticateUser,
  AUTH_NONE,
  AUTH_PARENT_ANY,
  AUTH_SELF,
  AUTH_ADMIN,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  const parentID = decodeURIComponent(event.pathParameters.parentID);
  const resolvedResource = event.resource.replace("{parentID}", encodeURIComponent(parentID));
  console.log(`caller parentID: ${getDBUserIdFromEvent(event)}`);
  console.log(`path parentID: ${parentID}`);

  const auth = await authenticateUser(event, db, AUTH_PARENT_ANY | AUTH_ADMIN);
  if (auth === AUTH_NONE || (auth === AUTH_PARENT_ANY &&
                             (await authenticateUser(event, db, AUTH_SELF, {targetUserID: parentID})) === AUTH_NONE)) {
    const unauthResp = {
      statusCode: 403,
      body: JSON.stringify({
        errors: [{
          resource: resolvedResource,
          status: 403,
          message: "parent ID doesn't exist or user is not authorised to view their children",
        }]
      }),
    };
    addCorsHeaders(unauthResp);
    return unauthResp;
  }

  let res;
  try {
    res = await db.query("SELECT id FROM children WHERE parent_id = $1", [parentID]);
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

  const goodResp = {
    statusCode: 200,
    body: JSON.stringify({
      data: res.rows,
    }),
  };
  addCorsHeaders(goodResp);
  console.log(`returning ${res.rows.length} children`);
  return goodResp;
};
