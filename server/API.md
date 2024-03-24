# API for app and web interface

Our API will be RESTful and JSON-based.  It should be forwards- and
backwards-compatible, so it will include a version number.

## Note on Rest Principle: HATEOAS

Link: <https://restfulapi.net/hateoas/>

This may be overkill.

## Supported HTTP Methods in AWS API Gateway

- ANY
- DELETE
- GET
- HEAD
- OPTIONS
- PATCH
- POST
- PUT

## Note on POST vs PUT

PUT is defined as idempotent but POST is not, so doing the same PUT
request multiple times has the same effect (ie, there is no side
effect).

## Note on PUT vs PATCH for personal info

- PUT: completely replace the resource at the URI.
- PATCH: update specific fields of the resource at the URI.

We have both methods for completeness.  It would be helpful for admins
to be able to completely replace the whole set of personal info for a
user.

## Open Questions

- What should "devices" be named?  Children? In other words, are
  samples associated with *devices* or *children*?  Can a child be
  associated with more than one device?
- Should samples be given unique IDs?  I assume we can uniquely
  identify samples by their timestamp and device ID.  BUT this assumes
  each device only reports one sample per timestamp.

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

## Authentication

Use HTTP authentication: use the `Authorization` header.

For OAuth, we use `Authorization: Bearer <TOKEN>`
(<https://stackoverflow.com/questions/17334276/oauth2-0-how-to-pass-access-token>).

Otherwise, use HTTP cookies.

## Actions

### Sign up (POST) (`/users/`)

AWS Cognito allows using third party identity providers like Google
and Facebook, so we will use it even if we don't use third party
identity providers.

LOW PRIORITY: MAYBE: Session token is OPTIONAL.  If the session token
given to the server is an admin's token, then allow registering other
accounts?  This is to allow site admins to register clinicians since
the admins would need to set which child devices they can monitor.
Only the admins should be allowed to see the list of child devices.  I
don't think this would allow site admins to register users by OAuth
though.

### LOW PRIORITY: Search for users (GET) (`/users`)

Should be able to search by name, number of children, device IDs, etc.
Filters should go into query string.

### Get/Replace/Update personal info of a specific user (GET/PUT/PATCH) (`/users/{userID}/info`)

If authorised:

- GET: the caller will get a JSON object with the personal info
  associated with the user with ID `userID`.
- PUT: server will completely replace the personal info of `userID`
  with the info supplied by caller.
- PATCH: server will update only the personal info fields of `userID`
  supplied by caller.

### Delete a specific user (DELETE) (`/users/{userID}`)

OPEN QUESTION: Should this delete their children and the data of their children too?

OPEN QUESTION: Should only admins be allowed to delete users?

### Register child device (POST) (`/devices`)

This is *not* a sub-resource of a specific user because only the app
for the parents should be able to register child devices.  And that
app provides a token to identify the parent which we would use to
automatically associate the parent with the device.

OPEN QUESTION: For consistency (and testing purposes), should admins
be able to register child devices?

### Get/Replace/Update personal info associated with a specific child device (GET/PUT/PATCH) (`/devices/{deviceID}/info`)

If authorised:

- GET: the caller will get a JSON object with the personal info
  associated with the child device with ID `deviceID`.
- PUT: server will completely replace the personal info of `deviceID`
  with the info supplied by caller.
- PATCH: server will update only the personal info fields of
  `deviceID` supplied by caller.

### LOW PRIORITY: Delete child device (DELETE) (`/devices/{deviceID}`)

OPEN QUESTION: Should all the samples associated with `deviceID` be
deleted too?

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
- Asking for samples to be classified would make a call to the
  classifier (ML or something else).  This would slow down the
  response time.

\* NOTE: The clients want child names anonymised on backend or
encrypted (they said "hashed" but the way they used it implied
encryption).

## Some rejected approaches

### Should individual fields in a user's personal information be identified in the URI?

For example, we would read and write `/users/{userID}/email`.

#### Why not

Because it's not elegant and updating specific fields via a JSON
object as the body of a PATCH request does the same thing and allows
callers to treat updating multiple fields the same as updating just
one.

### Should the server automatically register devices if the server receives a sample from a device whose ID it doesn't recognise?

So that the app can generate IDs locally and therefore not have to
coordinate with server.

#### Why not

This would be fine, practically speaking, if we used UUIDs but I'd
rather the server have control of registration (which means control of
IDs).

### Should the `/devices/{deviceID}` resource allow access to samples from the device whose ID is `deviceID` (say, as `/devices/{deviceID}/samples`)?

I thought it would make for a more intuitive API.

#### Why not

We already have the `GET /samples?<QUERY STRING>` action which would
do the same thing, but more generally.  The caller should just filter
by device ID.
