import {
  addCorsHeaders,
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  const response = {
    headers: {
      "Content-Type": "application/json",
    },
  };
  let res;
  try {
    res = await db.query("SELECT * FROM samples");
  } catch (e) {
    console.error(e);
    response.statusCode = 500;
    response.body = JSON.stringify({
      resource: event.resource,
      status: 500,
      message: "internal server error",
    });
  }
  if (response.statusCode === undefined) {
    response.statusCode = 200;
    response.body = JSON.stringify(res.rows);
    console.log(`returning ${res.rows.length} samples`);
  }

  addCorsHeaders(response);
  return response;
};
