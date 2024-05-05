import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  const res_users = await db.query("SELECT * FROM users");
  const res_children = await db.query("SELECT * FROM children");
  const res_samples = await db.query("SELECT * FROM samples");
  return {
    users: res_users.rows,
    children: res_children.rows,
    samples: res_samples.rows,
  };
};
