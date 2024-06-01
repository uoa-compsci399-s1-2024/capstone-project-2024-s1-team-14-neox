import process from "node:process";
import {
  CognitoIdentityProviderClient,
  DeleteGroupCommand,
  CreateGroupCommand,
  ResourceNotFoundException,
} from "@aws-sdk/client-cognito-identity-provider";

const cognitoClient = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

const GROUPS = [
  process.env.GROUPNAME_ADMINS,
  process.env.GROUPNAME_RESEARCHERS,
  process.env.GROUPNAME_PARENTS,
];

export const handler = async (event) => {
  for (let i=0; i<GROUPS.length; i++) {
    console.log(`deleting group ${i+1}/${GROUPS.length}: ${GROUPS[i]}`);
    try {
      await cognitoClient.send(new DeleteGroupCommand({
        UserPoolId: process.env.USERPOOL_ID,
        GroupName: GROUPS[i],
      }))
    } catch (e) {
      if (e instanceof ResourceNotFoundException) {
        // don't care if group didn't exist before
        continue;
      } else {
        throw e;
      }
    }
  }
  for (let i=0; i<GROUPS.length; i++) {
    console.log(`creating group ${i+1}/${GROUPS.length}: ${GROUPS[i]}`);
    await cognitoClient.send(new CreateGroupCommand({
      UserPoolId: process.env.USERPOOL_ID,
      GroupName: GROUPS[i],
    }));
  }
};
