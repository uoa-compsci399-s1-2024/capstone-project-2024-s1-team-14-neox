// This file started as a copy of ../actions-researchers-register/index.mjs
import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";
import process from "node:process";
import {
  CognitoIdentityProviderClient,
  AdminCreateUserCommand,
  AdminAddUserToGroupCommand,
  UsernameExistsException,
} from "@aws-sdk/client-cognito-identity-provider";

let db = await connectToDB();
const cognitoClient = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

const REQUIRED_FIELDS = [
  "given_name",
  "family_name",
  "email",
];

export const handler = async (event) => {
  const fields = event;
  console.log(`got fields: ${JSON.stringify(fields)}`);

  let errors = [];
  for (let i=0; i<REQUIRED_FIELDS.length; i++) {
    if (fields[REQUIRED_FIELDS[i]] == null) {
      errors.push({
        message: `missing field: ${REQUIRED_FIELDS[i]}`,
      });
      console.error(errors[errors.length-1].message);
    }
  }
  if (errors.length > 0) {
    return errors;
  }
  if (Object.keys(fields).length > REQUIRED_FIELDS.length) {
    const err = {
      message: `too many fields, there must only be: ${REQUIRED_FIELDS.join(', ')}`,
    };
    console.error(err.message);
    return [err];
  }

  let newUser;
  console.log("creating user...");
  try {
    newUser = await cognitoClient.send(new AdminCreateUserCommand({
      UserPoolId: process.env.USERPOOL_ID,
      Username: fields.email,
      UserAttributes: REQUIRED_FIELDS.map(f => ({Name: f, Value: fields[f]})),
    }));
  } catch (e) {
    console.error(e);
    if (e instanceof UsernameExistsException) {
      throw e;
    } else {
      throw e;
    }
  }

  const admin_groups = [process.env.GROUPNAME_ADMINS,
                        process.env.GROUPNAME_RESEARCHERS];
  console.log(`adding user to groups ${JSON.stringify(admin_groups)}...`);
  try {
    await Promise.all(
      admin_groups
        .map(g => new AdminAddUserToGroupCommand({
          UserPoolId: process.env.USERPOOL_ID,
          GroupName: g,
          Username: newUser.User.Username,
        }))
        .map(cmd => cognitoClient.send(cmd)));
  } catch (e) {
    throw e;
  }

  console.log("adding new user to DB");
  try {
    await db.query("INSERT INTO users (id) VALUES ($1)", [fields.email]);
  } catch (e) {
    throw e;
  }
};

