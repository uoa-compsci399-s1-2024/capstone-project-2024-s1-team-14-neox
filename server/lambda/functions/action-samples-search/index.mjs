import {
  addCorsHeaders,
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  let res = await db.query("SELECT * FROM samples");
  const response = {
    statusCode: 200,
    body: JSON.stringify(res.rows),
    headers: {
      "Content-Type": "application/json",
    }
  };
  addCorsHeaders(response);
  return response;
};
