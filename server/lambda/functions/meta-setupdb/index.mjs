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
DROP TABLE IF EXISTS studies;
DROP TABLE IF EXISTS study_children;
DROP TABLE IF EXISTS study_researchers;
DROP TABLE IF EXISTS children;
DROP TABLE IF EXISTS users;
DROP TYPE IF EXISTS gender;

-- We put all users in one table since a user may be admin AND researcher, derived from Cognito groups
CREATE TABLE users (
       id TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE studies (
       id TEXT NOT NULL PRIMARY KEY,
       min_date DATE NOT NULL,
       max_date DATE NOT NULL,
       name TEXT,
       description TEXT,
       CONSTRAINT date_interval CHECK (min_date <= max_date)
);
CREATE TABLE study_children (
       study_id TEXT NOT NULL,
       child_id TEXT NOT NULL,
       PRIMARY KEY (study_id, child_id),
       FOREIGN KEY (study_id) REFERENCES studies (id),
       FOREIGN KEY (child_id) REFERENCES children (id)
);
CREATE TABLE study_researchers (
       study_id TEXT NOT NULL,
       researcher_id TEXT NOT NULL,
       PRIMARY KEY (study_id, researcher_id),
       FOREIGN KEY (study_id) REFERENCES studies (id),
       FOREIGN KEY (researcher_id) REFERENCES users (id)
);

CREATE TYPE gender AS ENUM (${PERSONAL_INFO_CHILD_GENDER_OPTIONS.map(pg.escapeLiteral).join(', ')});
CREATE TABLE children (
       id CHAR(${ID_LEN}) NOT NULL PRIMARY KEY,
       parent_id TEXT NOT NULL,
       birthdate DATE,
       family_name TEXT,
       given_name TEXT,
       middle_name TEXT,
       nickname TEXT,
       gender GENDER,
       FOREIGN KEY (parent_id) REFERENCES users (id)
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
