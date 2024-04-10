// Use this code snippet in your app.
// If you need more information about configurations or implementing the sample code, visit the AWS docs:
// https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started.html

import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import fs from "node:fs";
import process from "node:process";
import pg from 'pg';

export const SECRETS_MANAGER_CLIENT = new SecretsManagerClient({
  region: process.env.AWS_REGION,
});

async function getDBCredentials(smClient)
{
  let response;

  try {
    response = await smClient.send(
      new GetSecretValueCommand({
        SecretId: process.env.DB_SECRET_ARN,
        VersionStage: "AWSCURRENT", // VersionStage defaults to AWSCURRENT if unspecified
      })
    );
  } catch (error) {
    // For a list of exceptions thrown, see
    // https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    // If this fails, the caller code can't do anything with the DB so
    // it's better to just crash.
    throw error;
  }

  return JSON.parse(response.SecretString);
}


export async function connectToDB()
{
  const creds = await getDBCredentials(SECRETS_MANAGER_CLIENT);
  const config = {
    host: process.env.PGHOST,
    port: process.env.PGPORT,
    database: creds.username,
    user: creds.username,
    password: creds.password,
    ssl: {
      ca: [fs.readFileSync(process.env.SSL_CERT_FILE)]
    },
  };
  const db = new pg.Client(config);
  console.log(`connecting to database at ${config.host} on port ${config.port}`);
  try {
    await db.connect();
  } catch (e) {
    throw e;
  }
  console.log("connection success");
  return db;
}
