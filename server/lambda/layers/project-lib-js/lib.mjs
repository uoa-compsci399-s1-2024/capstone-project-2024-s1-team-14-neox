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

// See https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html#apigateway-enable-cors-proxy
export function addCorsHeaders(response)
{
  if (response.headers === undefined) {
    response.headers = {};
  }
  response.headers["Access-Control-Allow-Origin"] = process.env.CORS_ALLOW_ORIGIN;
  response.headers["Access-Control-Allow-Methods"] = 'OPTIONS, GET, POST, PUT, PATCH, DELETE';
  response.headers["Access-Control-Allow-Headers"] = 'Origin, Content-Type, Accept, Authorization';
  response.headers["Access-Control-Allow-Credentials"] = 'true';
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

export const ID_LEN = 9;
const MIN_ID_INT = 0;
const MAX_ID_INT_EXCLUSIVE = Math.pow(10, ID_LEN);
export function generateID()
{
  const n = randomInt(MIN_ID_INT, MAX_ID_INT_EXCLUSIVE);
  const strN = n + "";
  return strN.padStart(ID_LEN, "0");
}

export const PERSONAL_INFO_CHILD_GENDER_OPTIONS = [
  "male",
  "female",
  "other",
];

// NOTE: If a user's groups are modified after a given token has been issued
//       then the token is stale BUT these functions don't check for that.
// NOTE: This is a security vulnerability IFF a user is removed from a privileged group after the user is fully set up.
// BUT: The project doesn't require groups to be changeable.
//      There are well-defined roles for specific people: parents and
//      researchers are disjoint sets while researchers are a subset
//      of admins (since Phil and John will be in both researchers and
//      admins).
function getUserGroups(event)
{
  return event.requestContext.authorizer.claims["cognito:groups"].split(",");
}
export function calledByAdmin(event)
{
  return getUserGroups(event).includes("admins");
}
export function calledByResearcher(event)
{
  return getUserGroups(event).includes("researchers");
}
export function calledByParent(event)
{
  return getUserGroups(event).includes("parents");
}

export function getDBUserIdFromEvent(event)
{
  return event.requestContext.authorizer.claims.email;
}
export function getCognitoUsernameFromEvent(event)
{
  return event.requestContext.authorizer.claims["cognito:username"];
}

export const AUTH_NONE = -1;
export const AUTH_ALL = 2048;
export const AUTH_ADMIN = 1;
export const AUTH_SELF = 2;  // uses `config.targetUserID`
export const AUTH_PARENT_ANY = 4;
export const AUTH_PARENT_OFCHILD = 8;  // uses `config.childID`
// ...reserved...
export const AUTH_RESEARCHER_ANY = 64;
export const AUTH_RESEARCHER_OFSTUDY = 128;  // uses `config.studyID`
export const AUTH_RESEARCHER_OFSAMESTUDYASCHILD = 256;  // uses `config.childID`
// ... any more granular (and one-off) permissions will be implemented by the caller

// config is an object with the props (used only if needed):
// - `childID`
// - `studyID`
// - `targetUserID` (needed for AUTH_SELF)
// This function returns an integer matching the flag value matched (eg, AUTH_PARENT_ANY).
// If `AUTH_ALL` is on, then this function is a no-op.
// If none were matched, then `AUTH_NONE` is returned.
export async function authenticateUser(event, db, flags, config)
{
  console.log(`caller: ${getDBUserIdFromEvent(event)}`);
  // NOTE: we compare result of bitwise AND using strict equality
  // (===) since strict equality returns bool rather than a number.
  if ((flags & AUTH_ALL) === AUTH_ALL) {
    if (calledByAdmin(event) || calledByResearcher(event) || calledByParent(event)) {
      console.log("auth: everyone OK");
      return AUTH_ALL;
    } else {
      console.log("auth: everyone FAILED (user is not in a group)");
      return AUTH_NONE;
    }
  }

  if ((flags & AUTH_ADMIN) === AUTH_ADMIN) {
    if (calledByAdmin(event)) {
      console.log("auth: admin OK");
      return AUTH_ADMIN;
    }
  }

  if ((flags & AUTH_SELF) === AUTH_SELF) {
    const callerID = getDBUserIdFromEvent(event);
    if (callerID === config.targetUserID) {
      console.log("auth: self-target OK");
      return AUTH_SELF;
    }
  }

  if ((flags & AUTH_PARENT_ANY) === AUTH_PARENT_ANY) {
    if (calledByParent(event)) {
      console.log("auth: any parent OK");
      return AUTH_PARENT_ANY;
    }
  }
  if (((flags & AUTH_PARENT_OFCHILD) === AUTH_PARENT_OFCHILD) && calledByParent(event)) {
    const parentID = getDBUserIdFromEvent(event);
    console.log(`checking if parent is parent of child (parentID: ${parentID}) (childID: ${config.childID})`);
    const child_parentres = await db.query("SELECT parent_id FROM children WHERE id = $1", [config.childID]);
    if (child_parentres.rows.length === 1 && child_parentres.rows[0].parent_id === parentID) {
      console.log("auth: parent of this child OK");
      return AUTH_PARENT_OFCHILD;
    }
  }

  if ((flags & AUTH_RESEARCHER_ANY) === AUTH_RESEARCHER_ANY) {
    if (calledByResearcher(event)) {
      console.log("auth: any researcher OK");
      return AUTH_RESEARCHER_ANY;
    }
  }
  if ((flags & AUTH_RESEARCHER_OFSTUDY) === AUTH_RESEARCHER_OFSTUDY) {
    const researcherID = getDBUserIdFromEvent(event);
    // also uses studyID
    console.log(`checking if researcher is part of study (researcherID: ${researcherID}) (studyID: ${config.studyID})`);
    const res = await db.query(`SELECT * FROM study_researchers
                                WHERE upper(study_id) = upper($1)
                                  AND participant_id = $2`,
                               [config.studyID, researcherID]);
    if (res.rows.length === 1) {
      return AUTH_RESEARCHER_OFSTUDY;
    }
  }
  if ((flags & AUTH_RESEARCHER_OFSAMESTUDYASCHILD) === AUTH_RESEARCHER_OFSAMESTUDYASCHILD) {
    const researcherID = getDBUserIdFromEvent(event);
    // also uses childID
    console.log(`checking if the researcher and child have studies in common (researcherID: ${researcherID}) (childID: ${config.childID})`);
    const commonStudies = await db.query(`SELECT sr.study_id AS id
                                          FROM study_researchers AS sr, study_children AS sc
                                          WHERE sr.study_id = sc.study_id
                                            AND sr.participant_id = $1
                                            AND sc.participant_id = $2`,
                                         [researcherID, config.childID]);
    if (commonStudies.rows.length > 0) {
      return AUTH_RESEARCHER_OFSAMESTUDYASCHILD;
    }
  }

  console.log("auth: FAILED");
  return AUTH_NONE;
}
