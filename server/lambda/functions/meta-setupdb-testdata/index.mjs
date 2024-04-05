import {
  setupDB,
} from "/opt/nodejs/lib.mjs";

let db = await setupDB();

console.log("connecting");
await db.connect();
console.log("connection success")
const CREATE_TABLES_TEXT = `
-- NOTE: THERE SHOULD BE EXTERNAL AND INTERNAL IDs

DROP TABLE IF EXISTS samples;
DROP TABLE IF EXISTS children;
DROP TABLE IF EXISTS parents;

CREATE TABLE parents (
       -- id INTEGER NOT NULL PRIMARY KEY,
       id VARCHAR(50) NOT NULL PRIMARY KEY,
       fname VARCHAR(100) NOT NULL,
       lname VARCHAR(100) NOT NULL
);

CREATE TABLE children (
       id VARCHAR(50) NOT NULL PRIMARY KEY,
       parent_id VARCHAR(50) NOT NULL,
       fname VARCHAR(100),
       lname VARCHAR(100),
       FOREIGN KEY (parent_id) REFERENCES parents (id)
);

CREATE TABLE samples (
       -- id INTEGER NOT NULL PRIMARY KEY,
       -- Use timestamptz alias for TIMESTAMP WITH TIMEZONE because there were syntax errors when I sent the query to the DB in RDS
       tstamp TIMESTAMPTZ NOT NULL PRIMARY KEY,
       child_id VARCHAR(50) NOT NULL,
       uv_index INTEGER,
       lux INTEGER,
       FOREIGN KEY (child_id) REFERENCES children (id)
);

INSERT INTO parents (id, fname, lname) VALUES ('1', 'John', 'Cena');
INSERT INTO children (id, parent_id, fname) VALUES ('22', '1', 'Bobby');
INSERT INTO samples (child_id, tstamp, uv_index, lux) VALUES ('22', '2024-02-01+12', 2, 1500);
`;
export const handler = async (event) => {
  await db.query(CREATE_TABLES_TEXT);
  const res_parents = await db.query("SELECT * FROM parents");
  const res_children = await db.query("SELECT * FROM children");
  const res_samples = await db.query("SELECT * FROM samples");
  console.dir(res_parents.rows);
  console.dir(res_children.rows);
  console.dir(res_samples.rows);
};
