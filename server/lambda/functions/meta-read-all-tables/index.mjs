import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  const res_parents = await db.query("SELECT * FROM parents");
  const res_children = await db.query("SELECT * FROM children");
  const res_samples = await db.query("SELECT * FROM samples");
  return {
    parents: res_parents.rows,
    children: res_children.rows,
    samples: res_samples.rows,
  };
};
