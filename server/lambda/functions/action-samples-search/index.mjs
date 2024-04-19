import {
  addCorsHeaders,
  connectToDB,
  DATETIME_OUTPUT_FORMAT,
} from "/opt/nodejs/lib.mjs";
import {
  format,
} from "date-fns";

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
    for (let i=0; i<res.rows.length; i++) {
      res.rows[i].timestamp = format(res.rows[i].timestamp, DATETIME_OUTPUT_FORMAT);
    }
    response.body = JSON.stringify(res.rows);
    console.log(`returning ${res.rows.length} samples`);
  }

  addCorsHeaders(response);
  return response;
};
