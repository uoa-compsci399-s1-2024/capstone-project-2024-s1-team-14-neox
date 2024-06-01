import process from "node:process";
import {
  CognitoIdentityProviderClient,
  DescribeUserPoolCommand,
  UpdateUserPoolCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import {
  LambdaClient,
  AddPermissionCommand,
  RemovePermissionCommand,
  ResourceNotFoundException,
} from "@aws-sdk/client-lambda";
import assert from "node:assert/strict";

const cognitoClient = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});
const lambdaClient = new LambdaClient({
  region: process.env.AWS_REGION,
});

export const handler = async (event) => {
  console.log(`fetching current config for user pool ${process.env.USERPOOL_ID}`);
  let currConfigResp = await cognitoClient.send(new DescribeUserPoolCommand({UserPoolId: process.env.USERPOOL_ID}));
  let config = currConfigResp.UserPool;
  if (config.AdminCreateUserConfig !== undefined && config.AdminCreateUserConfig.UnusedAccountValidityDays !== undefined &&
      config.Policies !== undefined && config.Policies.PasswordPolicy !== undefined && config.Policies.PasswordPolicy.TemporaryPasswordValidityDays !== undefined) {
    assert(config.AdminCreateUserConfig.UnusedAccountValidityDays === config.Policies.PasswordPolicy.TemporaryPasswordValidityDays, `temp password validity config inconsistent between AdminCreateUserConfig and Policies.PasswordPolicy: ${config.AdminCreateUserConfig.UnusedAccountValidityDays} vs ${config.Policies.PasswordPolicy.TemporaryPasswordValidityDays}`);
    delete config.AdminCreateUserConfig.UnusedAccountValidityDays;
  }
  config.UserPoolId = process.env.USERPOOL_ID;
  config.LambdaConfig = {
    PostConfirmation: process.env.POSTCONFIRM_TRIGGER_ARN,
  };
  console.log(`updating user pool with config: ${JSON.stringify(config)}`);
  await cognitoClient.send(new UpdateUserPoolCommand(config));
  console.log(`removing permission to invoke postconfirm trigger`);
  try {
    await lambdaClient.send(new RemovePermissionCommand({
      StatementId: '1',
      FunctionName: process.env.POSTCONFIRM_TRIGGER_ARN,
    }));
  } catch (e) {
    if (e instanceof ResourceNotFoundException) {
      console.log(`got ResourceNotFoundException but don't care`);
      console.log(e);
    } else{
      throw e;
    }
  }
  console.log(`adding permission to invoke ${process.env.POSTCONFIRM_TRIGGER_ARN}`);
  await lambdaClient.send(new AddPermissionCommand({
    StatementId: '1',
    FunctionName: process.env.POSTCONFIRM_TRIGGER_ARN,
    Principal: 'cognito-idp.amazonaws.com',
    SourceArn: process.env.USERPOOL_ARN,
    Action: 'lambda:InvokeFunction',
  }));
};
