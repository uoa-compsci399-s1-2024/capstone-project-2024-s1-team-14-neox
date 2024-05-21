import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  const res_users = await db.query("SELECT * FROM users");
  const res_children = await db.query("SELECT * FROM children");
  const res_samples = await db.query("SELECT * FROM samples");
  const res_studies = await db.query("SELECT * FROM studies");
  const res_study_researchers = await db.query("SELECT * FROM study_researchers");
  const res_study_children = await db.query("SELECT * FROM study_children");
  return {
    users: res_users.rows,
    children: res_children.rows,
    samples: res_samples.rows,
    studies: res_studies.rows,
    study_researchers: res_study_researchers.rows,
    study_children: res_study_children.rows,
  };
};
