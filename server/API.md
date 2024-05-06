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
sends a *new* sample with the same timestamp[^1] for child A, then the
server will reject that sample.

## User Roles

### Parent

- Can create new children entities on server associated with
  him/herself.
- Can view and modify their own personal info.
- Can view and modify their children's personal info.
- Can view only their own children's sample data.
- Can view the indoor/outdoor classifications only for the sample
  data of their own children.
- Can send samples associated with their children to the server.
- Can view the list of their own children.
- Can view the list of the studies their children are part of (by
  specific child).
- Can add and revoke consent for studies their children are part of
  (by specific child).

### Researcher

- Can view the list of studies they are part of.
- Can view anonymised sample data of all children in a given study
  they have access to.
- Can view *some* personal info fields of children in their studies
  (inlined as a sample field):
  - age (*not* date of birth)
  - gender
- Can only VIEW their own personal info (their accounts are made for
  them).

### Admin

- Can create researcher accounts.
- Can delete researcher accounts.
- Can delete parent accounts.
- Can delete researcher accounts.
- Can view, patch, and replace their own personal information.
- Can view, patch, and replace a researcher's personal information.
- Can view, patch, and replace a parent's personal information.
- Can create studies.
- Can delete studies.
- Can modify metadata of studies.
- Can view list of researcher IDs.
- Can view list of parent IDs.
- Can view list of child IDs.
- Can view list of child IDs for a parent.
- Can view list of studies for a child.
- Can view list of studies for a researcher.
- Can view list of children, parents, researchers involved in a study.
- Can *revoke* consent to a given study for a child.
- Can add and remove access to a given study for a researcher.

#### Note on creation

Admin accounts can't be created or removed with the API.  For security
reasons, they must only be created or removed by the sysadmin
operating the backend.

## Note on IDs

The client should treat IDs as an opaque string.

### Child IDs

Child IDs will be a 9-digit number.  A regular expression to match
such IDs is `^[0-9]{9}$`.

### User IDs

User IDs (ie, parents, researchers, and admins) will simply be the
email address which the account was created with.  Why?  Because:

1. the stakeholders are used to communicating via email, so it would
   be easier if the email *is* the ID; and
2. it would make the implementation of users simple in the backend
   since a previous version of spec required child and user IDs to
   come from the same "namespace" and thereby incur the complexity
   associated with maintaining that uniqueness between quite different
   entities (children don't have accounts; parents, researchers, and
   admins have accounts).

### Privacy

Although child and user IDs aren't a secret, we will only share IDs to
those who need it.

## Note on sample fields

- `child_id`: ID of child with which the sample is associated.
- `timestamp`: String of ISO8601-formatted datetime with seconds
  resolution and timezone.  If timezone is UTC 0, then it must be
  specified either as `Z` OR an offset of `+00:00`.
- `uv`: Non-negative integer value of UV exposure (TODO units).
- `light`: Non-negative integer value of light exposure (TODO units).
- `accel_x`: Signed integer value for the `x` component of the
  acceleration experienced by the device.
- `accel_y`: Signed integer value for the `y` component of the
  acceleration experienced by the device.
- `accel_z`: Signed integer value for the `z` component of the
  acceleration experienced by the device.
- `col_red`: Unsigned integer value for the red component of the
  colour sensed by the device.
- `col_green`: Unsigned integer value for the green component of the
  colour sensed by the device.
- `col_blue`: Unsigned integer value for the blue component of the
  colour sensed by the device.

### Additional sample fields when retrieving the samples for a study

See the relevant permission for the researcher user role.

## Note on personal info fields

We use some fields from here:
https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-attributes.html

### Children

All fields are optional.  Researchers only really want `birthdate`
since age is a relevant predictor for progression of myopia.

- `birthdate`
- `family_name`
- `given_name`
- `middle_name`
- `nickname`
- `gender`

### Users (ie, everyone except children)

- `family_name` (required)
- `given_name` (required)
- `middle_name`
- `nickname`
- `email` (required)
- `phone_number` ???

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
	"data": CONTENT,
	"metadata": {
		"key1": "val1",
		"key2": "val2",
		...
	}
}
```
where:

- the schema for `CONTENT` will differ depending on the API action and status code.

### Schema for error responses

When there are errors, it will go into the `errors` field BUT the
`data` field may still be available when the API can do other useful
work despite the error.  The `errors` field will have the schema:

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

### Sign up

Sign up via the AWS Cognito API.  Other than this and authenticating
the user, Cognito should never be called.  Use the API actions for
that.

#### LOW PRIORITY???: We *may* allow registering via Google.

### Register researcher account (POST) (`/researchers`)

Client will send the following personal info of the researcher to be
registered:

- `given_name`
- `family_name`
- `email`

#### If authorised AND all required fields given

Server will return HTTP status 204.

The server will create a researcher account and set a temporary
password.  The researcher should reset this password within some
number of days (TBD).

Note that the ID of the researcher account is the email.

#### If authorised BUT NOT all required fields given

Server will return HTTP status 400.

#### If not authorised

Server will return 403.

### LOW PRIORITY: Search for parents (GET) (`/parents`)

Should be able to search by name, number of children, etc.  Filters
should go into query string.

### LOW PRIORITY: Search for researchers (GET) (`/researchers`)

Should be able to search by name, number of children, etc.  Filters
should go into query string.

### LOW PRIORITY: Search for children (GET) (`/children`)

Should be able to search by name, number of children, etc.  Filters
should go into query string.

### Get/Replace/Update personal info associated with a specific child/parent/researcher (GET/PUT/PATCH) (`/<children OR parents OR researchers>/{ID}/info`)

#### If authorised AND such a child/parent/researcher exists:

- GET: the `data` field of the response body will contain the personal
  info associated with the child/parent/researcher specified in the
  request.
- PUT: server will completely replace the personal info of the
  child/parent/researcher specified in the request with the info
  supplied by caller.
- PATCH: server will update only the personal info fields of the
  child/parent/researcher supplied by caller.

#### Personal info schema:

```json
{
	"<PERSONAL_INFO_FIELD_NAME>": "<PERSONAL_INFO_FIELD_VALUE>",
	...
}
```

#### If not authorised OR no such child/parent/researcher:

Return 403 response where the `resource` field of the error response
is the same as the URI at which the action was invoked.

#### PUT/PATCH

If any personal info fields are invalid: return 400 response, where for each invalid field name/value:

- the `resource` field of the object in `errors` will be:
  - `/<children OR parents OR researchers>/{ID}/info?fieldname={field}` when `field` is an invalid
    field name
  - `/<children OR parents OR researchers>/{ID}/info?fieldvalue={field}` when the value of `field`
    is invalid
- `status` will be 400.

No personal info fields will be updated so the client should correct
the fields listed in the errors when they try again.  For example, if
the client provided the `birthdate` field for a child but it was in
the wrong format:

```json
{
	"errors": [
		{
			"resource": "/children/123456789/info?fieldvalue=birthdate",
			"status": 400,
			"message": "birthdate must be formatted YYYY-MM-DD",
		}
	],
}
```

### LOW PRIORITY: Delete a specific parent/researcher account (DELETE) (`/parents/{parentID}` OR `/researchers/{researcherID}`)

#### If authorised AND such an account exists

Server will delete parent/researcher account with the given ID and
return a 204 response.

#### If not authorised OR no such account

Server will return 403.

#### OPEN QUESTION: FOR PARENTS: Should this delete their children and the data of their children too?

### LOW PRIORITY: Delete child (DELETE) (`/children/{childID}`)

#### If authorised AND such a child exists

Server will delete child with ID `childID` and return a 204 response.

#### If not authorised OR no such child exists

Server will return a 403.

#### OPEN QUESTION: Should all the samples associated with `childID` be deleted too?

### Register child (POST) (`/children`)

In the `data` field of the response, the server will send the client a
JSON object whose only field (for now) will be the ID of the child.
The client should add this ID to samples for that child before sending
them to server.

Schema of `data` field of response:
```json
{
	"id": ID,
}
```

This is *not* a sub-resource of a specific user because only the app
for the parents should be able to register children.  And that app
provides a token to identify the parent which we would use to
automatically associate the parent with the child.

#### OPEN QUESTION: For consistency (and testing purposes), should admins be able to register child devices?

### Get list of children associated with a parent (GET) (`/parents/{parentID}/children`)

#### If authorised AND such a parent exists:

Server returns HTTP 200 response:

``` json
{
	"data": {
		"children": [
			{"id": CHILD_ID1},
			{"id": CHILD_ID2},
			...
		],
	}
}
```

#### If not authorised OR no such user:

Server returns 403.

### Get list of studies a child/researcher is enrolled/collaborating in (GET) (`/<children OR researchers>/{ID}/studies`)

#### If authorised AND such a child/researcher exists:

Server returns HTTP 200 response:

``` json
{
	"data": {
		"studies": [
			{"id": STUDY_ID1},
			{"id": STUDY_ID2},
			...
		],
	}
}
```

#### If not authorised OR no such child/researcher:

Server returns 403.

### Add/Remove a child OR researcher to/from a study (PUT/DELETE) (`/<children OR researchers>/{ID}/studies/{studyID}`)

#### If authorised AND such a study exists

Server returns 204.

#### If authorised BUT no such study exists

Server returns 404.

#### If not authorised OR no such child/researcher

Server returns 403

### Create study with a given study ID (PUT) (`/studies/{studyID}`)

`studyID` is a case-insensitive string used to identify the study.  It
should be short and easy to remember since parents will need to enter
it to consent to the study.  Regular expression: `^[A-Za-z0-9]+$`.

Request body should have the following schema with the following
mandatory fields:

``` json
{
	"min_date": ...,
	"max_date": ...,
	"ethics_approval_code": ...,
}
```

where:

- `min_date` and `max_date` refer to the earliest and latest samples,
  respectively, to include in the study (note that all samples from
  any day in the period of the study are included).
- `ethics_approval_code` is a unique string from ethics committee

These fields are optional:

- `name`: name of study
- `description`

#### If authorised AND study ID unique:

Server will create study and return 204.

#### If authorised AND study ID taken:

Server will return 404.

Study IDs are designed to be shared.

#### If not authorised:

Server will return 403.

### Delete a study (DELETE) (`/studies/{studyID}`)

See action to create a study for the format of `studyID`.

#### If authorised AND study exists:

Server will delete study and return 204.

#### If authorised BUT no such study:

Server will return 404.

#### If not authorised:

Server will return 403.

### Get info about study (GET) (`/studies/{studyID}/info`)

#### If authorised for the specific study identified by `studyID`:

Server will return 200 with the body being a JSON object containing
the same fields (mandatory and optional) as the one you enter when
creating the study:

``` json
{
	"data": {
		"<STUDY_FIELD_NAME>": "<STUDY_FIELD_VALUE>",
		...
	}
}
```

#### If study ID doesn't exist:

Server will return 404.

Study IDs are designed to be shared.

#### If not authorised:

Server will return 403.

### Get list of children, parents, and researchers in a study (GET) (`/studies/{studyID}/participants`)

#### If authorised:

Server will return HTTP status 200 with the body:

``` json
{
	"data": {
		"children": [
			{"id": ..., "parent_id": ...},
			...
		],
		"parents": [
			{"id": ...},
			...
		],
		"researchers": [
			{"id": ...},
			...
		]
	}
}
```

#### If not authorised:

Server will return 403.

### Authenticate (Cognito)

#### Flow

1. User gives credentials to AWS Cognito API.
2. Upon successful authentication, pass the token in each request in
   the `Authorization` header.

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

If not authorised OR no such child: server will return 403 response.

If any errors: return 207 response, where `resource` will be
`/samples/{childID}/{timestamp}` and `timestamp` is the `timestamp`
which the sample specified.

If no errors: return 204 response.

If sample already existing: error `status` will be 409 "Conflict".

If sample sensor fields are invalid: error `status` will be 400 "Bad Request".

### Search samples (GET) (`/samples/{childID}`)

#### Flow

##### 1. User sends GET request with query parameters for:

- Filter by:
  - min/max timestamp
  - (FUTURE: child device type/version)

- Specify output format:
  - sensor values
  - list of timestamps only

##### 2a. If authorised and output format is sensor values

User receives:

``` json
{
	"data": [
		{"timestamp": ..., ...},
		...
	]
}
```

##### 2b. If authorised and output format is the list of timestamps only

User receives a list of timestamps:

``` json
{
	"data": [
		TIMESTAMP_1,
		TIMESTAMP_2,
		...
	]
}
```

This is mainly for the app when the sample-adding requests timeout and
thereby don't receive a response from server about which samples
succeeded.

Assuming the app knows the minimum and maximum timestamp of the
sample-adding request which timed out, they can use the response from
this action to mark the samples which successfully went onto the
server (and thereby have their timestamp show up in the output).

##### 2c. If not authorised OR no such child

Server returns 403.

#### Details

- FOR NOW: filters will be a simple AND, but it could be extended to
  allow arbitrary nesting of logical expressions (up to a limit).
  Maybe by having just one query parameter with special syntax like
  those of search engines.
- TODO: Maybe the results should be returned in "pages" (AKA
  "pagination").
- Automatically sort results by date.

### Search samples in a given study (GET) (`/studies/{studyID}/samples`)

#### Flow

##### 1. User sends GET request with query parameters for:

- Same filters as sample search action

##### 2a. If authorised AND study exists:

Server will return HTTP status 200.

The response body will have the same schema as the response from the
sample search action, but each sample will have additional fields (see
the relevant subheading in the notes for sample fields above).

##### 2b. If authorised BUT no such study:

Server will return 404.

### Classify samples (GET) (`/classifications/{childID}`)

#### Flow

##### 1. User sends GET request with query parameters for:

- Same filters as sample search action
- Some classifier options

##### 2a. If authorised

User receives:

``` json
{
	"data": [
		{"timestamp": ..., "outside": BOOL},
		...
	]
}
```

##### 2b. If not authorised OR no such child

Server returns 403.

#### Details

- TODO: Maybe the results should be returned in "pages" (AKA
  "pagination").
- Automatically sort results by date.

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
