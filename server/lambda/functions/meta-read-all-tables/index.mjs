import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  const res_parents = await db.query("SELECT * FROM parents");
  const res_children = await db.query("SELECT * FROM children");
  const res_samples = await db.query("SELECT * FROM samples");
  console.log("parents:");
  console.dir(res_parents.rows);
  console.log("children:");
  console.dir(res_children.rows);
  console.log("samples:");
  console.dir(res_samples.rows);
};
