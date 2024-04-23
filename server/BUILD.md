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

You can also use `FuncMetaSetupDB` to clear the DB.

Since we don't have user auth yet, setup test users, children, and
data:

``` shell
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaSetupTestData
```

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
