# How to build backend

## Prerequisites

- `aws` CLI.  I (Gabriel) use version 1
- Configured credentials for AWS
- `sam` CLI.  Download from PyPI or ... (TODO)

We will not set up the website here.  See `website/BUILD.md` if you
want to do that.

## Configuration

We have multiple "usecases" for the backend, each of which will be
launched in separate CloudFormation stacks and VPCs.

Within each "usecase", we have "environments" which split into
development environments (`dev` and `localhost`) which share a stack
and VPC and the production environment (`prod`) which is separate from
the development environments.

We only support `dev` and `localhost` for now.

### Usecases

Usecases are split by the team who will use the instance and also any
special uses.

- server
- website
- app
- all (all teams)
- prod (presentable iteration of project)
- ml (machine learning)

## Building

``` shell
sam build
sam deploy --config-env <USECASE>-<ENVIRONMENT>
```

where `<USECASE>` and `<ENVIRONMENT>` are defined as above.

Upon successfully building the backend, you will see a table of stack
outputs.  Use the value of `APIEndpoint` in HTTP requests.

To initialise the database:

``` shell
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaSetupDB
```

You can also use `FuncMetaSetupDB` to clear the DB.  But to clear only
the samples, use `FuncMetaClearSamples` which is helpful if there are
users already set up since resetting all the whole DB would desync the
DB and Cognito.

Now initialise the user pool:

``` shell
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaSetupUserPool
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaSetupUserGroups
```

To create an admin account (replace field names as you wish):

``` shell
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaAdminsRegister --event '{"given_name": "John", "family_name": "Admin", "email": "john.admin@example.com"}'
```

Cognito will send a temporary password to that email.  When you first
log in, Cognito will require you to first set a new password.  (Once
the website is set up, you will be able to do this there.)

You can get the user pool ID (`UserPoolId`) and client ID from the
template stack outputs.  Use any client ID for now (`AppClientId` or
`WebClientId`).

To log in:

``` shell
aws cognito-idp admin-initiate-auth --user-pool-id "<POOL ID>" --client-id "<CLIENT ID>" --auth-flow ADMIN_USER_PASSWORD_AUTH --auth-parameters USERNAME="john.admin@example.com",PASSWORD='<PASSWORD FROM EMAIL>'
```

To respond to auth challenge on first login when Cognito requires you
to set a new password for admin account, see
<https://docs.aws.amazon.com/cognito/latest/developerguide/how-to-create-user-accounts.html#authentication-flow-for-create-user>.

Copying verbatim from output of `aws cognito-idp respond-to-auth-challenge help`:

```
This example responds to  an  authorization  challenge  initiated  with
initiate-auth. It is a response to the NEW_PASSWORD_REQUIRED challenge.
It sets a password for user jane@example.com.

Command:

    aws cognito-idp respond-to-auth-challenge --client-id 3n4b5urk1ft4fl3mg5e62d9ado --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses USERNAME=jane@example.com,NEW_PASSWORD="password" --session "SESSION_TOKEN"

Output:

    {
      "ChallengeParameters": {},
      "AuthenticationResult": {
          "AccessToken": "ACCESS_TOKEN",
          "ExpiresIn": 3600,
          "TokenType": "Bearer",
          "RefreshToken": "REFRESH_TOKEN",
          "IdToken": "ID_TOKEN",
          "NewDeviceMetadata": {
              "DeviceKey": "us-west-2_fec070d2-fa88-424a-8ec8-b26d7198eb23",
              "DeviceGroupKey": "-wt2ha1Zd"
          }
      }
    }
```

Use the value of `AuthenticationResult.IdToken` in `Authorization: Bearer <Value of IdToken>`
header when making API requests directly (rather than through app or
website which does it for you).

View all tables with:

``` shell
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaReadAllTables
```

## Debugging lambdas

You can use

``` shell
sam logs --config-env <USECASE>-<ENVIRONMENT> -n <FUNCTION_LOGICAL_NAME>
```

where `<FUNCTION_LOGICAL_NAME>` is the name that the lambda function
has in the `Resources` section of the template.

You can also add the `-i` flag to include AWS X-Ray traces for
summaries of execution times and HTTP status codes returned by the
functions.

There are also the `-s` and `-e` flags to configure which function
invocations you want to see the logs of.

Also, the logs may not update immediately after calling the function.
If you want to see the latest call to the function but it's not there
yet, just run the command again.

Alternatively, you open a separate terminal and add the `--tail` flag
to the call to get logs as they are written.

## Help

- `sam`: Run `sam --help` (`sam -h` for short) OR `sam <SUBCOMMAND> -h`.
- `aws`: Run `aws help` OR `aws <SUBCOMMAND> help`.
