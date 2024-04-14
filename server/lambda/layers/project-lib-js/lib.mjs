// Use this code snippet in your app.
// If you need more information about configurations or implementing the sample code, visit the AWS docs:
// https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/getting-started.html

import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
// The docs show the import this way for some reason.
const {
  randomInt,
} = await import("node:crypto");
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

export function addCorsHeaders(response)
{
  if (response.headers === undefined) {
    response.headers = {};
  }
  response.headers["Access-Control-Allow-Origin"] = "*";
}

// Based on https://www.rfc-editor.org/rfc/rfc7231#section-3.1.1.1
// We only need the type and subtype.
const CONTENT_TYPE_RE = /^\s*(?<type>[^\s]+)\/(?<subtype>[^\s]+)(\s*;.*)?$/;
const CORRECT_CONTENT_TYPE = "application";
const CORRECT_CONTENT_SUBTYPE = "json";
function checkCorrectContentType(headers)
{
  let contentType = "";
  // FIXME: Potential attacks by sending loads of headers
  for (let prop in headers) {
    if (prop.toLowerCase() === "content-type") {
      contentType = headers[prop];
      break;
    }
  }
  let m;
  if ( (m = contentType.match(CONTENT_TYPE_RE)) ) {
    return {
      contentType: contentType,
      correct: m.groups.type.toLowerCase() === CORRECT_CONTENT_TYPE &&
        m.groups.subtype.toLowerCase() === CORRECT_CONTENT_SUBTYPE,
    }
  } else {
    return {
      contentType: null,
      correct: false,
    }
  }
}

export function validateContentType(headers, resource)
{
  let res = checkCorrectContentType(headers);
  if (res.correct) {
    console.log(`content-type OK, got "${res.contentType}"`);
    return null;
  }
  let error = {
    resource: resource,
    status: 400,
  };
  if (res.contentType === null) {
    error.message = "content-type was missing or couldn't be parsed";
  }
  else {
    error.message = `content-type must be ${CORRECT_CONTENT_TYPE}/${CORRECT_CONTENT_SUBTYPE} but got "${res.contentType}" instead`;
  }
  console.error(error.message);
  return error;
}

// See formats at https://date-fns.org/v3.6.0/docs/isMatch
const ISO8601_FORMAT_DATETIME = "yyyy-MM-dd'T'HH:mm:ss";
export const DATETIME_FORMAT_UTC = `${ISO8601_FORMAT_DATETIME}XXXXX`;  // use "Z" for UTC 0
export const DATETIME_FORMAT_WITHOFFSET = `${ISO8601_FORMAT_DATETIME}xxxxx`;  // use +00:00 for UTC 0
export const DATETIME_OUTPUT_FORMAT = DATETIME_FORMAT_UTC;

const MIN_ID_INT = 0;
const MAX_ID_INT_EXCLUSIVE = 1_000_000;
export const ID_LEN = 9;
export function generateID()
{
  const n = randomInt(MIN_ID_INT, MAX_ID_INT_EXCLUSIVE);
  const strN = n + "";
  return strN.padStart(ID_LEN, "0");
}

export const TEMP_PARENT_ID = '1';

// TODO: replace with AWS Cognito calls
export async function setPersonalInfoFields(db, resource, childID, fields)
{
  let errors = [];
  for (let f in fields) {
    // TODO: whitelist (not just "everything except ID fields") personal info fields
    if (f === "id" || f === "parent_id") {
      errors.push({
        resource: `${resource}/${childID}/info?field=${encodeURIComponent(f)}`,
        status: 400,
        message: "bad field"
      });
      continue;
    }
    try {
      await db.query("UPDATE children SET $2 = $3 WHERE id = $1",
                     [childID, f, fields[f]]);
      console.log(`set field ${f} to "${fields[f]}"`);
    } catch (e) {
      console.error(e);
      errors.push({
        resource: `${resource}/${childID}/info?field=${encodeURIComponent(f)}`,
        status: 400,
        message: "bad field"
      });
    }
  }
  return errors;
}
