import {
  addCorsHeaders,
  connectToDB,
  validateContentType,
  authenticateUser,
  AUTH_NONE,
  AUTH_ADMIN,
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
  const auth = await authenticateUser(event, db, AUTH_ADMIN);
  if (auth === AUTH_NONE) {
    const code = 403;
    const response = {
      statusCode: code,
      body: JSON.stringify({
        errors: [{
          resource: event.resource,
          status: code,
          message: "only admins can make researcher accounts",
        }]
      }),
    };
    addCorsHeaders(response);
    return response;
  }

  const maybeEarlyErrorResp = {
    statusCode: 400,
  };
  addCorsHeaders(maybeEarlyErrorResp);

  const contentTypeError = validateContentType(event.headers, event.resource);
  if (contentTypeError !== null) {
    maybeEarlyErrorResp.body = JSON.stringify({errors: [contentTypeError]});
    return maybeEarlyErrorResp;
  }

  let reqBody;
  try {
    reqBody = JSON.parse(event.body);
  } catch (e) {
    console.error(e);
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: event.resource,
          status: 400,
          message: "missing or empty request body",
        }
      ],
    });
    return maybeEarlyErrorResp;
  }
  if (reqBody == null) {
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: event.resource,
          status: 400,
          message: "missing or empty request body",
        }
      ],
    });
    return maybeEarlyErrorResp;
  }

  let errors = [];
  for (let i=0; i<REQUIRED_FIELDS.length; i++) {
    if (reqBody[REQUIRED_FIELDS[i]] == null) {
      errors.push({
        resource: event.resource,
        status: 400,
        message: `missing field: ${REQUIRED_FIELDS[i]}`,
      });
    }
  }
  if (errors.length > 0) {
    maybeEarlyErrorResp.body = JSON.stringify({'errors': errors});
    return maybeEarlyErrorResp;
  }
  if (Object.keys(reqBody).length > REQUIRED_FIELDS.length) {
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: event.resource,
          status: 400,
          message: `too many fields, there must only be: ${REQUIRED_FIELDS.join(', ')}`,
        }
      ]
    });
  }

  console.log(`got fields: ${JSON.stringify(reqBody)}`);
  let newUser;
  try {
    newUser = await cognitoClient.send(new AdminCreateUserCommand({
      UserPoolId: process.env.USERPOOL_ID,
      Username: reqBody.email,
      UserAttributes: REQUIRED_FIELDS.map(f => ({Name: f, Value: reqBody[f]})),
    }));
  } catch (e) {
    console.error(e);
    if (e instanceof UsernameExistsException) {
      maybeEarlyErrorResp.statusCode = 409;  // conflict
      maybeEarlyErrorResp.body = JSON.stringify({
        errors: [
          {
            resource: `${event.resource}/${encodeURIComponent(reqBody.email)}`,
            status: 409,
            message: "user already exists",
          }
        ]
      });
      return maybeEarlyErrorResp;
    } else {
      maybeEarlyErrorResp.statusCode = 500;
      maybeEarlyErrorResp.body = JSON.stringify({
        errors: [
          {
            resource: event.resource,
            status: 500,
            message: "failed to create user for some reason",
          }
        ]
      });
      return maybeEarlyErrorResp;
    }
  }

  try {
    await cognitoClient.send(new AdminAddUserToGroupCommand({
      UserPoolId: process.env.USERPOOL_ID,
      GroupName: process.env.GROUPNAME_RESEARCHERS,
      Username: newUser.User.Username,
    }));
  } catch (e) {
    console.error(e);
    maybeEarlyErrorResp.statusCode = 500;
    maybeEarlyErrorResp.body = JSON.stringify({
      errors: [
        {
          resource: event.resource,
          status: 500,
          message: "failed to create user for some reason",
        }
      ]
    });
    return maybeEarlyErrorResp;
  }

  console.log("adding new user to DB");
  try {
    await db.query("INSERT INTO users (id) VALUES ($1)", [reqBody.email]);
  } catch (e) {
    // TODO: handle this case
    throw e;
  }

  const successResp = {statusCode: 204};
  addCorsHeaders(successResp);
  return successResp;
};

