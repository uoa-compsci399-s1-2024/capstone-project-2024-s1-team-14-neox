import {
  connectToDB,
  PERSONAL_INFO_CHILD_GENDER_OPTIONS,
} from "/opt/nodejs/lib.mjs";
import pg from "pg";

let db = await connectToDB();

const CREATE_TABLES_TEXT = `
-- NOTE: THERE SHOULD BE EXTERNAL AND INTERNAL IDs

DROP TABLE IF EXISTS samples;
DROP TABLE IF EXISTS children;
DROP TABLE IF EXISTS parents;

CREATE TABLE parents (
       -- id INTEGER NOT NULL PRIMARY KEY,
       id VARCHAR(50) NOT NULL PRIMARY KEY,
       -- don't care about parents' birthdate
       family_name TEXT,
       given_name TEXT,
       middle_name TEXT,
       nickname TEXT,
       email TEXT
);

CREATE TYPE gender AS ENUM (${PERSONAL_INFO_CHILD_GENDER_OPTIONS.map(pg.escapeLiteral).join(', ')});
CREATE TABLE children (
       id VARCHAR(50) NOT NULL PRIMARY KEY,
       parent_id VARCHAR(50) NOT NULL,
       birthdate DATE,
       family_name TEXT,
       given_name TEXT,
       middle_name TEXT,
       nickname TEXT,
       gender GENDER,
       FOREIGN KEY (parent_id) REFERENCES parents (id)
);

CREATE TABLE samples (
       -- id INTEGER NOT NULL PRIMARY KEY,
       -- Use timestamptz alias for TIMESTAMP WITH TIMEZONE because there were syntax errors when I sent the query to the DB in RDS
       "timestamp" TIMESTAMPTZ NOT NULL,
       child_id VARCHAR(50) NOT NULL,
       uv INTEGER NOT NULL,
       CONSTRAINT uv_range CHECK (uv >= 0),
       light INTEGER NOT NULL,
       CONSTRAINT light_range CHECK (light >= 0),
       PRIMARY KEY (child_id, "timestamp"),
       FOREIGN KEY (child_id) REFERENCES children (id)
);
`;
export const handler = async (event) => {
  await db.query(CREATE_TABLES_TEXT);
};
