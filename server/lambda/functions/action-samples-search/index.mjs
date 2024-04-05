import {
  setupDB,
} from "/opt/nodejs/lib.mjs";

let db = await setupDB();

console.log("connecting");
await db.connect();
console.log("connection success")

export const handler = async (event) => {
  let res = await db.query("SELECT * FROM samples");
  const response = {
    statusCode: 200,
    body: JSON.stringify(res.rows),
    headers: {
      "Content-Type": "application/json",
    }
  };
  return response;
};
