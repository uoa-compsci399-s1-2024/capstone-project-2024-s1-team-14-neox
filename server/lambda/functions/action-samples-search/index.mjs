import {
  addCorsHeaders,
  connectToDB,
  DATETIME_OUTPUT_FORMAT,
  authenticateUser,
  AUTH_NONE,
  AUTH_PARENT_OFCHILD,
} from "/opt/nodejs/lib.mjs";
import {
  format,
} from "date-fns";

let db = await connectToDB();

export const handler = async (event) => {
  const childID = event.pathParameters.childID;
  const samplesResource = event.resource.replace("{childID}", encodeURIComponent(childID));

  const response = {
    headers: {
      "Content-Type": "application/json",
    },
  };

  const auth = await authenticateUser(event, db, AUTH_PARENT_OFCHILD, {"childID": childID});
  if (auth === AUTH_NONE) {
    const body = {
      errors: [{
        resource: samplesResource,
        status: 403,
        message: `child ID doesn't exist or user is not authorised to view their personal info`,
      }]};
    response.statusCode = body.errors[body.errors.length-1].status;
    response.body = JSON.stringify(body);
    addCorsHeaders(response);
    return response;
  }

  let res;
  try {
    res = await db.query("SELECT * FROM samples WHERE child_id = $1", [childID]);
  } catch (e) {
    console.error(e);
    response.statusCode = 500;
    response.body = JSON.stringify({
      resource: samplesResource,
      status: 500,
      message: "internal server error",
    });
  }
  if (response.statusCode === undefined) {
    response.statusCode = 200;
    for (let i=0; i<res.rows.length; i++) {
      res.rows[i].timestamp = format(res.rows[i].timestamp, DATETIME_OUTPUT_FORMAT);
    }
    response.body = JSON.stringify(res.rows);
    console.log(`returning ${res.rows.length} samples`);
  }

  addCorsHeaders(response);
  return response;
};
