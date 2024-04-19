import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  await db.query("INSERT INTO parents (id, fname, lname) VALUES ('1', 'John', 'Cena')");
  await db.query("INSERT INTO children (id, parent_id, fname) VALUES ('22', '1', 'Bobby')");
  await db.query("INSERT INTO samples (child_id, \"timestamp\", uv, light) VALUES ('22', '2024-02-01+12', 2, 1500)");
};
