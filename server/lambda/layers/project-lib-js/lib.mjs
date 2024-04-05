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

export function createSecretsManagerClient()
{
  return new SecretsManagerClient({
    region: process.env.AWS_REGION
  });
}

export async function getDBCredentials(smClient)
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
    throw error;
  }

  return JSON.parse(response.SecretString);
}

export function createDBClient(credentials)
{
  return new pg.Client({
    host: process.env.PGHOST,
    port: process.env.PGPORT,
    database: credentials.username,
    user: credentials.username,
    password: credentials.password,
    ssl: {
      ca: [fs.readFileSync(process.env.SSL_CERT_FILE)]
    },
  })
}

export async function setupDB()
{
  let smClient = createSecretsManagerClient();
  let creds = await getDBCredentials(smClient);
  let db = createDBClient(creds);
  return db;
}
