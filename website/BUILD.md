# How to build the website (for website team)

## Prerequisites

- `npm`
- `aws` CLI.  The devs used version 1, which is available from PyPI
- Configured credentials for AWS
- `sam` CLI.  The devs downloaded from PyPI

Before we do anything, we need to first create the S3 buckets for the
`prod` and `dev` websites.

However, if you just want to test on localhost, you can skip this
step.

If there is no such Cloudformation stack, run (in this directory):

``` shell
sam deploy
```

The output will look like this:

```
CloudFormation outputs from deployed stack
----------------------------------------------------------------------------------------------
Outputs
----------------------------------------------------------------------------------------------
Key                 ServerDevURL
Description         -
Value               http://neox-frontend-server-dev.s3-website-ap-southeast-2.amazonaws.com

Key                 WebsiteDevS3Name
Description         -
Value               neox-frontend-website-dev

Key                 WebsiteDevURL
Description         -
Value               http://neox-frontend-website-dev.s3-website-ap-southeast-2.amazonaws.com

Key                 AppDevURL
Description         -
Value               http://neox-frontend-app-dev.s3-website-ap-southeast-2.amazonaws.com

Key                 ServerDevS3Name
Description         -
Value               neox-frontend-server-dev

Key                 AppDevS3Name
Description         -
Value               neox-frontend-app-dev
----------------------------------------------------------------------------------------------
```

Have each of these values ready for later.

## Notation: `<USECASE>`

In the following instructions replace `<USECASE>` with the usecase for
which you are developing.

See `BUILD.md` in the server subsystem directory for more details.

## Notation: `<ENV>`

In the following instructions replace `<ENV>` with the environment for
which you are developing:

- If you're developing for the developer[^1] website, you would
  replace `<ENV>` with `dev`.
- If you're developing for the production[^2] website, you would
  replace `<ENV>` with `prod`.

See `BUILD.md` in the server subsystem directory for more details.

## 1. Build an instance of the backend for localhost/dev/prod (needed for CORS)

Go to the `server/` directory from the project root.

Run

``` shell
sam build
```

```
sam deploy --config-env <USECASE>-<ENV>
```

Once the deployment succeeds, you will see the outputs of the
CloudFormation stack which look look this:

```
CloudFormation outputs from deployed stack
-----------------------------------------------------------------------------------------------------------------------------------------
Outputs
-----------------------------------------------------------------------------------------------------------------------------------------
Key                 APIEndpoint
Description         Base URL of API
Value               https://nyttfeb9u6.execute-api.ap-southeast-2.amazonaws.com/localhost
```

If you miss the output or you're following these instructions long
after deployment, you can also run:

```
sam list stack-outputs --config-env <USECASE>-<ENV>
```

Note down the `Value` field of `APIEndpoint`, `UserPoolId`, and
`WebClientId`.

Back in this directory, install the web app dependencies with:

```
npm install
```

## Develop on localhost

Note that the backend must have been built with the `localhost` environment.

### 2. Start the web app

1. Set the corresponding properties in `src/aws-exports.js` from the values you noted earlier
2. Set `REGION` to the region you see in the user pool ID
3. Start the development server with `npm start`

### Done

## Develop on website hosted on AWS

Note that the backend must have been built with the `dev` environment.

### 2. Build the web app

1. Set the corresponding properties in `src/aws-exports.js` from the values you noted earlier
2. Set `REGION` to the region you see in the user pool ID
3. Build the web app with `npm run build`

### 3. Upload compiled web app to AWS and Visit website

#### Instructions

Run:

``` shell
aws s3 sync build/ s3://<USECASE><ENV>S3Name  --delete
```

Visit the website at this URL from the stack outputs earlier:
`<USECASE><ENV>URL`.

#### NOTE

Our S3 buckets were automatically assigned policy statements which
reject unencrypted HTTP connections.  If you also have this issue, you
will need to disable such rules because S3 static site hosting does
not provide an HTTPS endpoint.

## Cleanup

When you're done, you can shut down the instances of the backend you
used.

In the `server/` directory, run the following command with the same
value for `--config-env` as when you created the backend instance:

``` shell
sam delete --config-env <USECASE>-<ENV>
```

Answer `y` (yes) to all of the prompts.

[^1]: which is only for cloud devs

[^2]: which is the polished version of each iteration of the website
