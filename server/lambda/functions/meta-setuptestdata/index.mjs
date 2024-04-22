import {
  connectToDB,
  TEMP_PARENT_ID,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

export const handler = async (event) => {
  await db.query("INSERT INTO parents (id, given_name, family_name) VALUES ($1, 'John', 'Cena')", [TEMP_PARENT_ID]);
  await db.query("INSERT INTO children (id, parent_id, nickname) VALUES ('22', $1, 'Bobby')", [TEMP_PARENT_ID]);
  await db.query("INSERT INTO samples (child_id, \"timestamp\", uv, light) VALUES ('22', '2024-02-01+12', 2, 1500)");
};
