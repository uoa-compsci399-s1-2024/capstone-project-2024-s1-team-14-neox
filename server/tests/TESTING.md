# Tests for server subsystem

The main entry point for testing is the `tests/test_api.sh` Bash
script which has the following prerequisites:

- Configured AWS credentials
- `sam` CLI
- `curl` for making HTTP requests
- `jq` for working with JSON (used by tests on the response body)
- `git` CLI

Also set the SAM stack name in the script by changing the `STACKNAME`
variable.

You can run `tests/test_api.sh -h` for usage information:

```
Usage: tests/test_api.sh [-s] [-r] [-h]
  -s	set up cognito accounts before testing
  -r	test researcher account creation
  -h	view this help message
```

## What the script tests for

The script mainly tests that all the actions can only be accessed by
authorised users[^1] by checking the HTTP status code.  It also tests
that API actions behave according to the spec by making assertions on
the output after the API call.

## `-s` flag

If you provide the `-s` flag, you will need to modify the following
constants to emails you have access to because you will be emailed
temporary passwords for the researcher and admins accounts:

- `EMAIL_PARENT1`
- `EMAIL_PARENT2`
- `EMAIL_RESEARCHER1`
- `EMAIL_RESEARCHER2`
- `EMAIL_ADMIN`

The password each account will have after completing this process is
the password stored in the constant `PASSWORD`.  The value is
currently `Password123!`.

## `-r` flag

If you provide the `-r` flag, the test script will confirm that only
admins can create researcher accounts.  Note that this will count
towards the daily email limit of Cognito[^2] so don't use this flag
all the time lest you exhaust this limit and then become no longer
able to send verification codes for new parent accounts, or send
temporary passwords for researcher and admin accounts.

A future version of the project may configure SES on the Cognito user
pool to get around this daily limit (and instead be limited only by
the budget of the AWS account).

[^1]: as specified by the permissions of the user roles in the API document

[^2]: we currently use the default email sender which has a daily limit

