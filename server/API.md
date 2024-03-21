# API for app and web interface

Our API will be RESTful and JSON-based.  It should be forwards- and
backwards-compatible, so it will include a version number.

## Note on POST vs PUT

PUT is defined as idempotent but POST is not, so doing the same PUT
request multiple times has the same effect (ie, there is no side
effect).

## Actions

### Sign up (POST) (one of `signup`)

I'm not sure how this should work yet since I don't know if we're
using AWS Cognito or some other provider, and I don't know how to use
any of them yet.

### Authenticate (POST) (one of `/auth`, `/authenticate`, `/login`)

#### Flow

1. User gives credentials.
2. Upon successful authentication, user gets session token.

#### Details

- This will just be an interface to AWS Cognito.
- NOTE: Every other action will take a session token to identify the
  user:
    - Each parent will be able to view their children.
    - Each clinician will be able to view children they work with.

### Send samples (POST) (`/samples`)

#### Flow

1. User sends a JSON object of samples keyed by child device IDs:

```json
{
    "child device id": [
        {
            "timestamp": "timestamp",
            "sensor value name": "value"
        }
    ]
}
```

#### Details

- We key by child device ID because it seems natural to do it.  Maybe
it would be better to have it all flattened since it will all go into
database rows anyway.

### Get samples (GET) (`/samples`)

#### Flow

1. User sends JSON object with query options:
    - Filter by:
        - min/max timestamp
        - parent ID
        - child device ID
        - child name\* (fuzzy match?)
    - Specify output format:
        - sensor values only
        - classified only (`outside` or `inside`)
        - both of the above
        - include parent ID
        - include child name\*

#### Details

- FOR NOW: filters will be a simple AND, but it could be extended to
  allow arbitrary nesting of logical expressions (up to a limit).
- The samples will be given in a JSON array where each element of the
  array is a JSON object containing the sample fields.  Each sample
  will contain the child device ID and parent ID.
- TODO: Maybe the results should be returned in "pages" (AKA
  "pagination").
- TODO: Maybe allow sorting the results (by a given field?).

\* NOTE: The clients want child names anonymised on backend or
encrypted (they said "hashed" but the way they used it implied
encryption).
