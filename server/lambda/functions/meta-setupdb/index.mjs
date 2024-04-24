import {
  connectToDB,
  ID_LEN,
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
       id CHAR(${ID_LEN}) NOT NULL PRIMARY KEY,
       -- don't care about parents' birthdate
       family_name TEXT,
       given_name TEXT,
       middle_name TEXT,
       nickname TEXT,
       email TEXT
);

CREATE TYPE gender AS ENUM (${PERSONAL_INFO_CHILD_GENDER_OPTIONS.map(pg.escapeLiteral).join(', ')});
CREATE TABLE children (
       id CHAR(${ID_LEN}) NOT NULL PRIMARY KEY,
       parent_id CHAR(${ID_LEN}) NOT NULL,
       birthdate DATE,
       family_name TEXT,
       given_name TEXT,
       middle_name TEXT,
       nickname TEXT,
       gender GENDER,
       FOREIGN KEY (parent_id) REFERENCES parents (id)
);

CREATE TABLE samples (
       -- Use timestamptz alias for TIMESTAMP WITH TIMEZONE because there were syntax errors when I sent the query to the DB in RDS
       "timestamp" TIMESTAMPTZ NOT NULL,
       child_id CHAR(${ID_LEN}) NOT NULL,
       uv INTEGER NOT NULL,
       CONSTRAINT uv_range CHECK (uv >= 0),
       light INTEGER NOT NULL,
       CONSTRAINT light_range CHECK (light >= 0),
       accel_x INTEGER NOT NULL,
       accel_y INTEGER NOT NULL,
       accel_z INTEGER NOT NULL,
       col_red INTEGER NOT NULL,
       col_green INTEGER NOT NULL,
       col_blue INTEGER NOT NULL,
       CONSTRAINT col_red_range CHECK (col_red BETWEEN 0 AND 255),
       CONSTRAINT col_green_range CHECK (col_green BETWEEN 0 AND 255),
       CONSTRAINT col_blue_range CHECK (col_blue BETWEEN 0 AND 255),
       col_clear INTEGER NOT NULL,
       CONSTRAINT col_clear_range CHECK (col_clear >= 0),
       col_temp INTEGER NOT NULL,
       CONSTRAINT col_temp_range CHECK (col_temp >= 0),
       PRIMARY KEY (child_id, "timestamp"),
       FOREIGN KEY (child_id) REFERENCES children (id)
);
`;
export const handler = async (event) => {
  await db.query(CREATE_TABLES_TEXT);
};
