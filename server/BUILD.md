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
- prod (final product)
<!-- - ml (machine learning) -->

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

Since we don't have user auth yet, setup test users, children, and
data:

``` shell
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaSetupTestData
```

View all tables with:

``` shell
sam remote invoke --config-env <USECASE>-<ENVIRONMENT> FuncMetaReadAllTables
```
