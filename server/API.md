# API for app and web interface

Our API will be RESTful and JSON-based.  It should be forwards- and
backwards-compatible, so it will include a version number.

## Note on Rest Principle: HATEOAS

Link: <https://restfulapi.net/hateoas/>

This may be overkill.

## Note on POST vs PUT

PUT is defined as idempotent but POST is not, so doing the same PUT
request multiple times has the same effect (ie, there is no side
effect).

## Open Questions

- Does the phone app first need to register devices before giving
  samples for them?  Or maybe it should be registered if the server
  receives a sample from a device whose ID it doesn't recognise?
- Should individual fields in a user's personal information be
  identified in the URI?  I ask so that we can easily do an HTTP
  DELETE on `/users/userID/email` for example.
- Should the `/devices/{deviceID}` resource allow access to samples
  from the device whose ID is `deviceID` (say, as
  `/devices/{deviceID}/samples`)?  It definitely makes for a more
  intuitive API.  If we want that, it would be a good idea to match
  the filtering API of the `/samples` resource (of course, restricted
  to the device identified by `deviceID`).

## User Roles

- Parent:
  - Can view only their own children's data.
  - Can view their own personal info.
  - Can view their children's personal info.
- Clinician:
  - Can only view data of children they work with.
  - Can view their own personal info.
  - Can view the personal info of the children they work with.
- Researcher: Can only view anonymised data of children.
- Admin:
  - Can register and delete users.
  - Can add, delete, and modify a user's personal information.

## Actions

### Sign up (POST) (one of `/signup` or `/register`)

AWS Cognito allows using third party identity providers like Google
and Facebook, so we will use it even if we don't use third party
identity providers.

LOW PRIORITY: MAYBE: Session token is OPTIONAL.  If the session token
given to the server is an admin's token, then allow registering other
accounts?  This is to allow site admins to register clinicians since
the admins would need to set which child devices they can monitor.
Only the admins should be allowed to see the list of child devices.

### LOW PRIORITY: Search for users (GET) (`/users`)

Should be able to search by name, number of children, device IDs, etc.

### LOW PRIORITY: Get/Update personal info of a specific user (GET / PUT?) (`/users/{userID}`)
### LOW PRIORITY: Delete a specific user (DELETE) (`/users/{userID}`)

Should this delete their children and the data of their children too?

### LOW PRIORITY: Get/Update personal info associated with a specific child device (GET / PUT?) (one of `/devices/{deviceID}`, `/children/{childID}`)

### Authenticate (POST) (one of `/auth`, `/authenticate`, `/login`)

#### Flow

1. User gives credentials.
2. Upon successful authentication, user gets session token.

#### Details

- This will just be an interface to AWS Cognito.
- NOTE: Every other action (except registration) will take a session
  token to identify the user.

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

1. User sends GET request with query parameters for:
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
2. Upon success: user receives a JSON array where each element of the
   array is a JSON object containing the sample fields.  Each sample
   will contain the child device ID and parent ID.

#### Details

- Filters are given in the query string.
- FOR NOW: filters will be a simple AND, but it could be extended to
  allow arbitrary nesting of logical expressions (up to a limit).
  Maybe by having just one query parameter with special syntax like
  those of search engines.
- TODO: Maybe the results should be returned in "pages" (AKA
  "pagination").
- Automatically sort results by date.

\* NOTE: The clients want child names anonymised on backend or
encrypted (they said "hashed" but the way they used it implied
encryption).
