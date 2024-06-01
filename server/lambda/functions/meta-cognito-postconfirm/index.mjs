import {
  connectToDB,
} from "/opt/nodejs/lib.mjs";
import assert from "node:assert/strict";
import process from "node:process";
import {
  CognitoIdentityProviderClient,
  AdminAddUserToGroupCommand,
  AdminRemoveUserFromGroupCommand,
} from "@aws-sdk/client-cognito-identity-provider";

let db = await connectToDB();
const cognitoClient = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION
});

async function addUserToDB(email)
{
  // ASSUMING COGNITO AND DB ARE IN SYNC: any emails that get to this
  // lambda should have been verified by Cognito as a non-duplicate, so there should be an empty slot in the table.
  await db.query("BEGIN");
  await db.query("INSERT INTO users (id) VALUES ($1)", [email]);
  console.log("successfully inserted into DB (pre-commit)");
}
async function addUserToParentsGroup(username)
{
  console.log("trying to add user to parents group");
  await cognitoClient.send(new AdminAddUserToGroupCommand({
    UserPoolId: process.env.USERPOOL_ID,
    GroupName: process.env.GROUPNAME_PARENTS,
    Username: username,
  }));
}
async function removeUserFromParentsGroup(username)
{
  await cognitoClient.send(new AdminRemoveUserFromGroupCommand({
    UserPoolId: process.env.USERPOOL_ID,
    GroupName: process.env.GROUPNAME_PARENTS,
    Username: username,
  }));
}

export const handler = async (event) => {
  if (event.triggerSource !== "PostConfirmation_ConfirmSignUp") {
    console.log(`got non-signup postconfirm... skipping: ${event.triggerSource}`);
    return event;
  }

  let email = event.request.userAttributes.email;
  assert(email != null, "missing email from user attributes--this should never happen!");
  console.log(`got confirmation of user with email ${email}`);

  const promises = new Array(2);
  const dbPromiseIndex = 0;
  const cognitoPromiseIndex = 1;
  promises[dbPromiseIndex] = addUserToDB(email);
  promises[cognitoPromiseIndex] = addUserToParentsGroup(event.userName);

  // the order of promise completion doesn't matter
  const results = await Promise.allSettled(promises);
  let failed = false;
  try {
    console.log("checking DB promise");
    if (results[dbPromiseIndex].status === "fulfilled") {
      await db.query("COMMIT");
      console.log("successfully committed to DB");
    } else {
      // TODO: Find a better solution.
      //
      // User is registered with cognito but the system is out of sync
      // with itself, so it's better for API calls to fail because of
      // bad permissions.  User can just re-register.  I don't know how
      // likely this error is to happen.
      console.error(results[dbPromiseIndex].reason);
      // await db.query("ROLLBACK");
      failed = true;
    }
  } catch (e) {
    console.error(e);
    failed = true;
  }
  console.log("checking Cognito promise");
  if (results[cognitoPromiseIndex].status === "rejected") {
    console.error(results[cognitoPromiseIndex].reason);
    failed = true;
  }

  if (failed) {
    console.error("couldn't add user to parents group");
    try {
      console.log("trying to roll-back DB transaction")
      await db.query("ROLLBACK");
    } catch (e) {
      console.error(e);
    }
    try {
      console.log("trying to roll-back adding user to group")
      await removeUserFromParentsGroup(event.userName);
    } catch (e) {
      console.error(e);
    }
    return event;
  }

  console.log("successfully added user to parents group");
  return event;
};
