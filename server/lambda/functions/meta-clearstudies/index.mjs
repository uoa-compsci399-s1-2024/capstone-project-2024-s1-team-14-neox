import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  await db.query("DELETE FROM study_researchers");
  await db.query("DELETE FROM study_children");
  await db.query("DELETE FROM studies");
};
