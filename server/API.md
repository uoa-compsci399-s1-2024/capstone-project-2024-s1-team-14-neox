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

## Note on whether we primarily associate samples with "children" or "devices"

Since one of the main purposes of the data is for researchers to
explore how outdoor time relates to the development of myopia AND for
clinicians to track outdoor time to help their child patients, we
associate samples with children.

FUTURE: Samples should also declare the type/version of the device on
which it was recorded.

## Note on sample timestamps

For a given child, we will require that timestamps uniquely identify
samples.  For example, if the server already has a sample with the
timestamp `2024-04-10T22:49:48+12:00` for child A, and the client
sends a *new* sample with the same timestamp[^1], then the server will
reject that sample.

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

## Note on IDs

Child IDs and user IDs (ie, parents, researchers, and clinicians) will
be a 6-digit number all coming from the same "namespace".  In other
words, a child ID and a user ID can't be the same.

The client should treat it as an opaque string, however.  The fact
that it can be represented as an integer is an implementation detail.

## Note on sample fields

- `child_id`: ID of child with which the sample is associated.
- `timestamp`: String of ISO8601-formatted datetime with seconds
  resolution.  TODO: will we require timezone to be specified? (ie, no
  default timezone).
- `uv`: Numeric value of UV exposure (TODO units).
- `light`: Numeric value of light exposure (TODO units).
- `acceleration`: Three-element numeric array for device acceleration
  where the first element is the `x` component, second is `y`, and
  third is `z`.

## Note on personal info fields

We use some fields from here:
https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-attributes.html

- birthdate (not for users)
- family_name
- given_name
- middle_name
- nickname
- (for users:) email

## Authentication (SUBJECT TO CHANGE)

Use HTTP authentication: use the `Authorization` header.

For OAuth, we use `Authorization: Bearer <TOKEN>`
(<https://stackoverflow.com/questions/17334276/oauth2-0-how-to-pass-access-token>).

Otherwise, use HTTP cookies.

## Note on status codes

See <https://restfulapi.net/http-status-codes/>.

### 200 OK: everything went well, expect a response body

### 204 No Content: everything went well, expect NO response body

Will be used for API actions that require no additional information.

Example: when the personal info of a user is successfully updated.

### 207 Multi-Status: some parts of request succeeded, some failed

Will be used for API actions which we want to process as much as we
can.

Example: when sending samples to server.

### 401 "Unauthorized" (really, it means "Unauthenticated"): no session token in request OR session token not valid

Client should reauthenticate.

All actions except the login action (to be specified) will require
authentication.

### 403 "Forbidden" (really, it means "Unauthorized"): server knows who client is but request is not allowed

### 4XX: client errors

Expect them also.

## Note on response bodies

The schema for response bodies from every status code (except 204 of course, and also 401):
```json
{
	"version": API_VERSION,
	"data": CONTENT,
	"metadata": {
		"key1": "val1",
		"key2": "val2",
		...
	}
}
```
where:

- the `version` key is always first;
- the content and type of `API_VERSION` is currently unspecified (maybe int or maybe string); and
- the schema for `CONTENT` will differ depending on the API action and status code.

### Schema for error responses

When there are errors, it will go into the `errors` field BUT the
`data` field will still be available to the client in case the API can
still do other useful work despite the error.  The `errors` field will
have the schema:

```json
[
  {
    "resource": RESOURCE_URI,
    "status": HTTP_STATUS_CODE,
    "message": ...,
  },
  ...
]
```
where:

- `RESOURCE_URI` is the URI on which the API action was done for or
   the URI of the resource which the API action tried to create, eg,
   `"/users/<userID>/info"` for editing personal info of a user or
   `"/samples/<childID>/<timestamp>"` for adding samples to server.

## Actions

### Sign up (POST) (`/users/`)

In the `data` field of the response, the server will send the client a
JSON object whose only field (for now) will be the ID of the user.
The ID won't need to be added to any requests from client because we
would already know their ID once they've been authenticated.

The schema:
```json
{
	"id": ID,
}
```

AWS Cognito allows using third party identity providers like Google
and Facebook, so we will use Cognito even if we don't use third party
identity providers.

LOW PRIORITY: MAYBE: Session token[^3] is OPTIONAL.  If the session token
given to the server is an admin's token, then allow registering other
accounts?  This is to allow site admins to register clinicians since
the admins would need to set which child devices they can monitor.
Only the admins should be allowed to see the list of child devices.  I
don't think this would allow site admins to register users by OAuth
though.

### LOW PRIORITY: Search for users (GET) (`/users`)

Should be able to search by name, number of children, etc.  Filters
should go into query string.

### Get/Replace/Update personal info of a specific user (GET/PUT/PATCH) (`/users/{userID}/info`)

If authorised:

- GET: the `data` field of the response body will contain the personal
  info associated with the user with ID `userID`.
- PUT: server will completely replace the personal info of `userID`
  with the info supplied by caller.
- PATCH: server will update only the personal info fields of `userID`
  supplied by caller.

If not authorised:

Return 403 response where the `resource` field of the error response
is the same as the URI at which the action was invoked.

If no such user:

Return 404 "Not Found".

### Delete a specific user (DELETE) (`/users/{userID}`)

If authorised: server will delete user with ID `userID` and return a
204 response.

If not authorised: server will return a 403 response where the
`resource` field of the error response is the same as the URI at which
the action was invoked.

If no such user:

Return 404 "Not Found".

OPEN QUESTION: Should this delete their children and the data of their
children too?

OPEN QUESTION: Should only admins be allowed to delete users?

### Register child (POST) (`/children`)

The client will send a JSON object containing any personal information
the client wants to share about the child (see note on personal info
fields above).  In other words, all fields are optional.  It will have
the schema:

```json
{
	"<PERSONAL_INFO_FIELD_NAME>": "<PERSONAL_INFO_FIELD_VALUE>",
	...
}
```

In the `data` field of the response, the server will send the client a
JSON object whose only field (for now) will be the ID of the child.
The client should add this ID to samples for that child before sending
them to server.

The schema:
```json
{
	"id": ID,
}
```

If any personal info fields are invalid: return 207 response, where
the `resource` field of `errors` will be
`/children/{childID}/info?field={field}` and `status` will be 400 for
each invalid field.  However, the `data` field will still contain the
generated ID.  The client should correct the fields listed in the
errors.  For example, if the client provided the `birthdate` field but
it was in the wrong format:

```json
{
	"data": {
		"id": "123456789"
	},
	"errors": [
		{
			"resource": "/children/123456789/info?field=birthdate",
			"status": 400,
			"message": "birthdate must be formatted YYYY-MM-DD",
		}
	],
	"metadata": {
		...
	}
}
```

This is *not* a sub-resource of a specific user because only the app
for the parents should be able to register children.  And that app
provides a token to identify the parent which we would use to
automatically associate the parent with the child.

OPEN QUESTION: For consistency (and testing purposes), should admins
be able to register child devices?

### Get/Replace/Update personal info associated with a specific child (GET/PUT/PATCH) (`/children/{childID}/info`)

If authorised:

- GET: the `data` field of the response body will contain the personal
  info associated with the child with ID `childID`.
- PUT: server will completely replace the personal info of `childID`
  with the info supplied by caller.
- PATCH: server will update only the personal info fields of `childID`
  supplied by caller.

If not authorised:

Return 403 response where the `resource` field of the error response
is the same as the URI at which the action was invoked.

If no such child:

Return 404 "Not Found".

### LOW PRIORITY: Delete child (DELETE) (`/children/{childID}`)

If authorised: server will delete child with ID `childID` and return a
204 response.

If not authorised: server will return a 403 response where the
`resource` field of the error response is the same as the URI at which
the action was invoked.

If no such child:

Return 404 "Not Found".

OPEN QUESTION: Should all the samples associated with `childID` be
deleted too?

### Authenticate (POST) (one of `/auth`, `/authenticate`, `/login`)

#### Flow

1. User gives credentials.
2. Upon successful authentication, user gets session token.

#### Details

- This will just be an interface to AWS Cognito.
- Client doesn't need to do this API action if they authenticate with
  OAuth, for example.  The client can just pass the token from a
  third-party identity provider directly to the API.
- NOTE: Every other action (except registration) will take a session
  token[^3] to identify the user.

### Add samples (POST) (`/samples/{childID}`)

User sends a JSON object with the schema:
```json
{
    "samples": [SAMPLE...],
}
```
where each `SAMPLE` is a JSON object containing the sample fields
mentioned before except the field for child ID since it's already been specified in the URI.

If authorised to add samples for `childID`: server will return 204 or
207 (see later).

If not authorised: server will return 403 response.

If any errors: return 207 response, where `resource` will be
`/samples/{childID}/{timestamp}` and `timestamp` is the `timestamp`
which the sample specified.

If no errors: return 204 response.

If sample already existing: error `status` will be 409 "Conflict".

If sample sensor fields are invalid: error `status` will be 400 "Bad Request".

### Search samples (GET) (`/samples`)

#### Flow

1. User sends GET request with query parameters for:
    - Filter by:
        - min/max timestamp
        - parent ID
        - child ID
		- (FUTURE: child device type/version)
        - child name[^2] (fuzzy match?)
    <!-- - Specify output format: -->
    <!--     - sensor values only -->
    <!--     - classified only (`outside` or `inside`) -->
    <!--     - both of the above -->
        <!-- - include parent ID -->
        <!-- - include child name[^2] -->
2. Upon success: user receives a JSON array in the `data` response
   field where each element of the array is a JSON object containing
   the sample fields.

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

### Should the `/children/{childID}` resource allow access to samples from the child whose ID is `childID` (say, as `/children/{childID}/samples`)?

I thought it would make for a more intuitive API.

#### Why not

We already have the `GET /samples?<QUERY STRING>` action which would
do the same thing, but more generally.  The caller should just filter
by device ID.

[^1]: maybe because the child uses more than one device

[^2]: NOTE: The clients want child names anonymised on backend or
    encrypted (they said "hashed" but the way they used it implied
    encryption)

[^3]: TODO: is "session token" an accurate name?
