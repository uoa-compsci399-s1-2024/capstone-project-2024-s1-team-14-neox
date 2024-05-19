import {
  connectToDB,
  addCorsHeaders,
  authenticateUser,
  AUTH_NONE,
  AUTH_ADMIN,
  AUTH_ALL,
} from "/opt/nodejs/lib.mjs";
import {
  CognitoIdentityProviderClient,
  ListUsersInGroupCommand,
} from "@aws-sdk/client-cognito-identity-provider";

let db = await connectToDB();
const cognitoClient = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

const USER_PARENTS = process.env.GROUPNAME_PARENTS;
const USER_RESEARCHERS = process.env.GROUPNAME_RESEARCHERS;
const USER_ADMINS = process.env.GROUPNAME_ADMINS;

function make_handler(userType)
{
  return (async (event) => {
    const auth = await (async () => {
      switch (userType) {
      case USER_PARENTS:
        return await authenticateUser(event, db, AUTH_ADMIN);
      case USER_RESEARCHERS:
      case USER_ADMINS:
        return await authenticateUser(event, db, AUTH_ALL);
      }
    })();
    if (auth === AUTH_NONE) {
      const errResp = {
        statusCode: 403,
        body: JSON.stringify({
          errors: [{
            resource: event.resource,
            status: 403,
            message: "not authorised",
          }]
        }),
      };
      addCorsHeaders(errResp);
      return errResp;
    }

    let users = [];
    let nextToken;
    do {
      nextToken = null;
      let res;
      try {
        const config = {
          GroupName: userType,  // userType happens to be the Cognito group name
          UserPoolId: process.env.USERPOOL_ID,
        };
        if (nextToken != null) {
          config.NextToken = nextToken;
        }
        res = await cognitoClient.send(new ListUsersInGroupCommand(config));
      } catch (e) {
        console.error(e);
        const errResp = {
          statusCode: 500,
          body: JSON.stringify({
            errors: [{
              resource: event.resource,
              status: 500,
              message: "internal server error",
            }]
          }),
        };
        addCorsHeaders(errResp);
        return errResp;
      }
      for (let i=0; i<res.Users.length; i++) {
        users.push(res.Users[i].Attributes.find(attr => attr.Name === "email").Value);
      }
      nextToken = res.NextToken;
    } while (nextToken != null);

    const goodResp = {
      statusCode: 200,
      body: JSON.stringify({
        data: users.map(userID => ({id: userID})),
      }),
    };
    addCorsHeaders(goodResp);
    return goodResp;
  });
}

export const handler_parents = make_handler(USER_PARENTS);
export const handler_researchers = make_handler(USER_RESEARCHERS);
export const handler_admins = make_handler(USER_ADMINS);
