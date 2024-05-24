import {
  addCorsHeaders,
  connectToDB,
  authenticateUser,
  AUTH_NONE,
  AUTH_ADMIN,
  AUTH_PARENT_OFCHILD,
  AUTH_ALL,
} from "/opt/nodejs/lib.mjs";
import {
  CognitoIdentityProviderClient,
  AdminListGroupsForUserCommand,
} from "@aws-sdk/client-cognito-identity-provider";

let db = await connectToDB();
const cognitoClient = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

const COLLECTION_GLOBAL = "global";
const COLLECTION_RESEARCHERS = "researchers";
const COLLECTION_CHILDREN = "children";

const UNAUTH_OR_NO_SUCH_PARTICIPANT_MESSAGE = "not authorised or no such participant";

function make_handler(collectionID)
{
  return (async (event) => {
    const subjectID = (() => {
      switch (collectionID) {
      case COLLECTION_GLOBAL:
        return null;
      case COLLECTION_RESEARCHERS:
        return decodeURIComponent(event.pathParameters.researcherID);
      case COLLECTION_CHILDREN:
        return decodeURIComponent(event.pathParameters.childID);
      }
    })();
    const resolvedResource = (() => {
      switch (collectionID) {
      case COLLECTION_RESEARCHERS:
        return event.resource.replace("{researcherID}", encodeURIComponent(subjectID));
      case COLLECTION_CHILDREN:
        return event.resource.replace("{childID}", encodeURIComponent(subjectID));
      }
    })();
    console.log(`collection: ${collectionID}`);
    console.log(`subjectID: ${subjectID}`);

    const auth = await (async () => {
      switch (collectionID) {
      case COLLECTION_GLOBAL:
        return await authenticateUser(event, db, AUTH_ALL);
      case COLLECTION_RESEARCHERS:
        return await authenticateUser(event, db, AUTH_ADMIN);
      case COLLECTION_CHILDREN:
        return await authenticateUser(event, db, AUTH_ADMIN | AUTH_PARENT_OFCHILD, {"childID": subjectID});
      }
    })();
    if (auth === AUTH_NONE) {
      const unauthResp = {
        statusCode: 403,
        body: JSON.stringify({
          errors: [{
            resource: resolvedResource,
            status: 403,
            message: UNAUTH_OR_NO_SUCH_PARTICIPANT_MESSAGE,
          }]
        }),
      };
      addCorsHeaders(unauthResp);
      return unauthResp;
    }

    let res;
    switch (collectionID) {
    case COLLECTION_GLOBAL:
      res = await db.query("SELECT upper(id) AS id FROM studies");
    case COLLECTION_RESEARCHERS:
      res = await db.query(`SELECT upper(study_id) AS id
                            FROM study_researchers
                            WHERE participant_id = $1`,
                           [subjectID]);
    case COLLECTION_CHILDREN:
      res = await db.query(`SELECT upper(study_id) AS id
                            FROM study_children
                            WHERE participant_id = $1`,
                           [subjectID]);
    }
    // determine what kind of error happened (if any)
    if (res.rows.length === 0) {
      const unauthResp = {
        statusCode: 403,
        body: JSON.stringify({
          errors: [{
            resource: resolvedResource,
            status: 403,
            message: UNAUTH_OR_NO_SUCH_PARTICIPANT_MESSAGE,
          }]
        }),
      };
      addCorsHeaders(unauthResp);

      switch (collectionID) {
      case COLLECTION_GLOBAL:
        // just no studies at all
        break;
      // need to differentiate between no such participant OR participant is not in any studies
      case COLLECTION_RESEARCHERS:
        // either participant (who is a researcher) is in no studies OR participant is not a RESEARCHER
        if ((await db.query("SELECT * FROM users WHERE id = $1", [subjectID])).rows.length === 0) {
          // no such user at all
          return unauthResp;
        } else {
          let groups = [];
          let nextToken;
          do {
            nextToken = null;
            let res;
            try {
              const config = {
                Username: subjectID,
                UserPoolId: process.env.USERPOOL_ID,
              };
              if (nextToken != null) {
                config.NextToken = nextToken;
              }
              res = await cognitoClient.send(new AdminListGroupsForUserCommand(config));
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
            groups.concat(res.Groups.map(g => g.GroupName));
            nextToken = res.NextToken;
          } while (nextToken != null);

          if (groups.includes(process.env.GROUPNAME_RESEARCHERS)) {
            // researcher is just not in any studies
          } else {
            return unauthResp;
          }
        }
        break;
      // need to differentiate between no such participant OR participant is not in any studies
      case COLLECTION_CHILDREN:
        if ((await db.query("SELECT * FROM children WHERE id = $1", [subjectID])).rows.length === 0) {
          // no such child
          return unauthResp;
        } else {
          // child is just not in any studies
        }
        break;
      }
    }

    const goodResp = {
      statusCode: 200,
      body: JSON.stringify({
        data: res.rows,
      }),
    };
    addCorsHeaders(goodResp);
    return goodResp;
  });
}

export const handler_global = make_handler(COLLECTION_GLOBAL);
export const handler_researchers = make_handler(COLLECTION_RESEARCHERS);
export const handler_children = make_handler(COLLECTION_CHILDREN);
