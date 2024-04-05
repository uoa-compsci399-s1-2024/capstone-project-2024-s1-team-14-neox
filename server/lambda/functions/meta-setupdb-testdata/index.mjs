// Use this code snippet in your app.
// If you need more information about configurations or implementing the sample code, visit the AWS docs:
// https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started.html

import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import fs from "node:fs";
import process from "node:process";

const client = new SecretsManagerClient({
  region: process.env.AWS_REGION
});

let response;

try {
  response = await client.send(
    new GetSecretValueCommand({
      SecretId: process.env.SECRET_ARN,
      VersionStage: "AWSCURRENT", // VersionStage defaults to AWSCURRENT if unspecified
    })
  );
} catch (error) {
  // For a list of exceptions thrown, see
  // https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
  throw error;
}

const secret = JSON.parse(response.SecretString);

// Your code goes here
import pg from 'pg';
const { Client } = pg;

const db = new Client({
  host: process.env.PGHOST,
  port: process.env.PGPORT,
  database: secret.username,
  user: secret.username,
  password: secret.password,
  ssl: {
    ca: [fs.readFileSync(process.env.SSL_CERT_FILE)]
  },
})
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
       ext_id VARCHAR(50) NOT NULL PRIMARY KEY,
       fname VARCHAR(100) NOT NULL,
       lname VARCHAR(100) NOT NULL
);

CREATE TABLE children (
       -- id INTEGER NOT NULL PRIMARY KEY,
       ext_id VARCHAR(50) NOT NULL PRIMARY KEY,
       -- parent_id INTEGER NOT NULL,
       parent_ext_id VARCHAR(50) NOT NULL,
       fname VARCHAR(100),
       lname VARCHAR(100),
       -- FOREIGN KEY (parent_id) REFERENCES parents (id)
       FOREIGN KEY (parent_ext_id) REFERENCES parents (ext_id)
);

CREATE TABLE samples (
       -- id INTEGER NOT NULL PRIMARY KEY,
       -- ts TIMESTAMP WITH TIMEZONE NOT NULL PRIMARY KEY,
       -- Use timestamptz alias for TIMESTAMP WITH TIMEZONE because there were syntax errors when I sent the query to the DB in RDS
       ts TIMESTAMPTZ NOT NULL PRIMARY KEY,
       -- child_id INTEGER NOT NULL,
       child_ext_id VARCHAR(50) NOT NULL,
       uv_index INTEGER,
       lux INTEGER,
       -- FOREIGN KEY (child_id) REFERENCES children (id)
       FOREIGN KEY (child_ext_id) REFERENCES children (ext_id)
);

INSERT INTO parents (ext_id, fname, lname) VALUES ('1', 'John', 'Cena');
INSERT INTO children (ext_id, parent_ext_id, fname) VALUES ('22', '1', 'Bobby');
INSERT INTO samples (child_ext_id, ts, uv_index, lux) VALUES ('22', '2024-02-01+12', 2, 1500);
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
