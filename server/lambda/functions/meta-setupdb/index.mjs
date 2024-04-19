import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";

let db = await connectToDB();

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
       "timestamp" TIMESTAMPTZ NOT NULL,
       child_id VARCHAR(50) NOT NULL,
       uv INTEGER NOT NULL,
       light INTEGER NOT NULL,
       PRIMARY KEY (child_id, "timestamp"),
       FOREIGN KEY (child_id) REFERENCES children (id)
);
`;
export const handler = async (event) => {
  await db.query(CREATE_TABLES_TEXT);
};
