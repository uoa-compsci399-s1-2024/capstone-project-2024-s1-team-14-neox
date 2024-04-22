# How to build the website (for website team)

## Prerequisites

- `aws` CLI.  I (Gabriel) use version 1
- Configured credentials for AWS
- `sam` CLI.  Download from PyPI or ... (TODO)

Before we do anything, we need to first create the S3 buckets for the
`prod` and `dev` websites.  I've already made them using the
Cloudformation stack called `frontend`.  Check the Cloudformation
console on the AWS website.

However, if you just want to test on localhost, you can skip this step.

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

## 1. Build an instance of the backend for localhost/dev/prod (needed for CORS)

Go to the `server/` directory.

Run

``` shell
sam build
```

Making sure to replace `ENVIRONMENT` depending on whether you're
developing on `localhost`, for the `dev` website, or for the `prod`
website, run this:

```
sam deploy --config-env website-ENVIRONMENT
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

Note down the `Value` field of `APIEndpoint`.  In this example, it is
`https://nyttfeb9u6.execute-api.ap-southeast-2.amazonaws.com/localhost`.

## Develop on localhost

### 2. Start the web app (`npm start`) with the API URL as an environment variable

Follow the instructions in the link to:

- start the development server, and
- set the `REACT_APP_API_URL` environment variable to have the value of `APIEndpoint`

<https://create-react-app.dev/docs/adding-custom-environment-variables/#adding-temporary-environment-variables-in-your-shell>

### Done

## Develop on website hosted on AWS

### 2. Build the web app (`npm run build`) with the API URL as an environment variable

Follow the instructions in the link to:

- build the web app, and
- set the `REACT_APP_API_URL` environment variable to have the value of `APIEndpoint`

Wherever the instructions say to do `npm start`, replace it with `npm run build`.

<https://create-react-app.dev/docs/adding-custom-environment-variables/#adding-temporary-environment-variables-in-your-shell>

### 3. Upload compiled web app to AWS and Visit website

#### Notation: `<ENV>`

In the following instructions replace `<ENV>` with the environment for
which you are developing:

- If you're developing for the developer[^1] website, you would
  replace `<ENV>` with `dev`.
- If you're developing for the production[^2] website, you would
  replace `<ENV>` with `prod`.

FOR NOW: we only support `dev`.

#### Instructions

Run:

``` shell
aws s3 sync build/ s3://Website<ENV>S3Name  --delete
```

Visit the website at this URL: `Website<ENV>URL`.

#### NOTE

Right now, our S3 buckets are automatically assigned policy statements
that reject unencrypted HTTP connections.  I have to manually remove
them every time they're re-applied.  (TODO add instructions for how to
do this).  Once we have an ACM certificate, we will no longer need to
do this.

### 4. Cleanup

When you're done, shut down the instances of the backend you used.

In the `server/` directory, run the following command with the same
value for `--config-env` as when you created the backend instance:

``` shell
sam delete --config-env website-ENVIRONMENT
```

Answer `y` (yes) to all of the prompts.

[^1]: which is only for cloud devs

[^2]: which is the polished version of each iteration of the website
