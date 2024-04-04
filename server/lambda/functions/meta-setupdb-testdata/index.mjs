// Use this code snippet in your app.
// If you need more information about configurations or implementing the sample code, visit the AWS docs:
// https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started.html

import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

const secret_name = "rds!db-b30fda56-acbf-4805-8307-cdaeef52cc95";

const client = new SecretsManagerClient({
  region: "ap-southeast-2",
});

let response;

try {
  response = await client.send(
    new GetSecretValueCommand({
      SecretId: secret_name,
      VersionStage: "AWSCURRENT", // VersionStage defaults to AWSCURRENT if unspecified
    })
  );
} catch (error) {
  // For a list of exceptions thrown, see
  // https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
  throw error;
}

const secret = response.SecretString;

// Your code goes here
import pg from 'pg';
const { Client } = pg;
 
const db = new Client({
  host: 'project-db.ci7bv0oxri6k.ap-southeast-2.rds.amazonaws.com',
  port: 5432,
  database: 'projectdb',
  user: secret.username,
  password: secret.password,
})
await client.connect();
const CREATE_TABLES_TEXT = `
-- NOTE: THERE SHOULD BE EXTERNAL AND INTERNAL IDs

DROP TABLE parents;
CREATE TABLE parents (
       -- id INTEGER NOT NULL PRIMARY KEY,
       ext_id VARCHAR(50) NOT NULL PRIMARY KEY,
       fname VARCHAR(100) NOT NULL,
       lname VARCHAR(100) NOT NULL
);

DROP TABLE children;
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

DROP TABLE samples;
CREATE TABLE samples (
       -- id INTEGER NOT NULL PRIMARY KEY,
       ts TIMESTAMP WITH TIMEZONE NOT NULL PRIMARY KEY,
       -- child_id INTEGER NOT NULL,
       child_ext_id INTEGER NOT NULL,
       uv_index INTEGER,
       lux INTEGER,
       -- FOREIGN KEY (child_id) REFERENCES children (id)
       FOREIGN KEY (child_ext_id) REFERENCES children (ext_id)
);

INSERT INTO parents (ext_id, fname, lname) VALUES ('1', 'John', 'Cena');
INSERT INTO children (ext_id, parent_ext_id, fname) VALUES ('1', '1', 'Bobby');
INSERT INTO samples (child_ext_id, ts, uv_index, lux) VALUES ('1', '2024-02-01+12', 2, 1500);
`;
export const handler = async (event) => {
  await db.query(CREATE_TABLES_TEXT);
  const res_parents = await db.query("SELECT * FROM parents");
  const res_children = await db.query("SELECT * FROM children");
  const res_samples = await db.query("SELECT * FROM samples");
  console.log(res_parents);
  console.log(res_children);
  console.log(res_samples);
};
