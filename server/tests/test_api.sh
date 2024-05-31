#!/bin/bash

function usage()
{
	cat >&2 <<EOF
Usage: $0 [-s] [-r] [-h]
  -s	set up cognito accounts before testing
  -r	test researcher account creation
  -h	view this help message
EOF
	exit 1
}

while getopts ":srh" o; do
	case "${o}" in
		s) s=1 ;;
		r) test_create_researchers=1 ;;
		*|h) usage ;;
	esac
done

echo "getting userpool ID, etc from sam..."
STACKNAME="backend-server-dev"
POOLID="$(sam list stack-outputs --output json --stack-name "$STACKNAME" | jq -r '.[] | select(.OutputKey == "UserPoolId") | .OutputValue')"
CLIENTID="$(sam list stack-outputs --output json --stack-name "$STACKNAME" | jq -r '.[] | select(.OutputKey == "AppClientId") | .OutputValue')"
API_URL="$(sam list stack-outputs --output json --stack-name "$STACKNAME" | jq -r '.[] | select(.OutputKey == "APIEndpoint") | .OutputValue')"

EMAIL_PARENT1="gabriel.lisaca@gmail.com"
EMAIL_PARENT2="gabriel.lisaca+parent2@gmail.com"
EMAIL_RESEARCHER1="gabriel.lisaca+researcher1@gmail.com"
EMAIL_RESEARCHER2="gabriel.lisaca+researcher2@gmail.com"
EMAIL_ADMIN="gabriel.lisaca+admin@gmail.com"

PASSWORD="Password123!"

if [ "$s" = 1 ]; then
	echo "setting up test accounts..."

	function ensureNewPassword ()
	{
		local subject_name="$1" email="$2" temp_password
		read -p "enter temp password for $subject_name account from email: " temp_password
		local init_auth_resp="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters "{\"USERNAME\": \"$email\", \"PASSWORD\": \"$temp_password\"}" --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH)"
		if [ "$(echo "$init_auth_resp" | jq -r '.ChallengeName')" = NEW_PASSWORD_REQUIRED ]; then
			echo "$subject_name: need new password, setting to: $PASSWORD"
			aws cognito-idp respond-to-auth-challenge --client-id "$CLIENTID" --challenge-name NEW_PASSWORD_REQUIRED --challenge-responses "{\"USERNAME\": \"$email\", \"NEW_PASSWORD\": \"$PASSWORD\"}" --session "$(echo "$init_auth_resp" | jq -r '.Session')"
		fi
	}

	echo "creating admin account"
	sam remote invoke --stack-name "$STACKNAME" FuncMetaAdminsRegister --event "{\"given_name\": \"John\", \"family_name\": \"Admin\", \"email\": \"$EMAIL_ADMIN\"}"
	ensureNewPassword "admin" "$EMAIL_ADMIN"

	echo "making parent account 1"
	aws cognito-idp sign-up --client-id "$CLIENTID" --username "$EMAIL_PARENT1" --password "$PASSWORD" --user-attributes Name="email",Value="$EMAIL_PARENT1" Name="given_name",Value="G" Name="family_name",Value="L"
	echo "admin-confirming parent account 1"
	aws cognito-idp admin-confirm-sign-up --user-pool-id "$POOLID" --username "$EMAIL_PARENT1"

	echo "making parent account 2"
	aws cognito-idp sign-up --client-id "$CLIENTID" --username "$EMAIL_PARENT2" --password "$PASSWORD" --user-attributes Name="email",Value="$EMAIL_PARENT2" Name="given_name",Value="G" Name="family_name",Value="L"
	echo "admin-confirming parent account 2"
	aws cognito-idp admin-confirm-sign-up --user-pool-id "$POOLID" --username "$EMAIL_PARENT2"

	IDTOKEN_ADMIN="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters "{\"USERNAME\": \"$EMAIL_ADMIN\", \"PASSWORD\": \"$PASSWORD\"}" --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"

	echo "making researcher account 1"
	curl -i -X POST -H"Authorization: Bearer $IDTOKEN_ADMIN" "$API_URL/researchers" -H'content-type: application/json' -d "{\"given_name\": \"G\", \"family_name\": \"L R\", \"email\": \"$EMAIL_RESEARCHER1\"}" 2>/dev/null
	ensureNewPassword "researcher1" "$EMAIL_RESEARCHER1"

	echo "making researcher account 2"
	curl -i -X POST -H"Authorization: Bearer $IDTOKEN_ADMIN" "$API_URL/researchers" -H'content-type: application/json' -d "{\"given_name\": \"G\", \"family_name\": \"L R\", \"email\": \"$EMAIL_RESEARCHER2\"}" 2>/dev/null
	ensureNewPassword "researcher2" "$EMAIL_RESEARCHER2"
else
	echo "not setting up test accounts... rerun this script with the -s flag to do this"
fi



set -e
set -o pipefail

echo "clearing samples..."
sam remote invoke --stack-name "$STACKNAME" FuncMetaClearSamples
echo ""
echo "clearing studies..."
sam remote invoke --stack-name "$STACKNAME" FuncMetaClearStudies
echo ""
echo "clearing children..."
sam remote invoke --stack-name "$STACKNAME" FuncMetaClearChildren
echo ""

echo "getting ID tokens..."
IDTOKEN_PARENT1="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters "{\"USERNAME\": \"$EMAIL_PARENT1\", \"PASSWORD\": \"$PASSWORD\"}" --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"
IDTOKEN_PARENT2="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters "{\"USERNAME\": \"$EMAIL_PARENT2\", \"PASSWORD\": \"$PASSWORD\"}" --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"
IDTOKEN_RESEARCHER1="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters "{\"USERNAME\": \"$EMAIL_RESEARCHER1\", \"PASSWORD\": \"$PASSWORD\"}" --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"
IDTOKEN_RESEARCHER2="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters "{\"USERNAME\": \"$EMAIL_RESEARCHER2\", \"PASSWORD\": \"$PASSWORD\"}" --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"
IDTOKEN_ADMIN="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters "{\"USERNAME\": \"$EMAIL_ADMIN\", \"PASSWORD\": \"$PASSWORD\"}" --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"

# See https://stackoverflow.com/questions/16654607/using-getopts-inside-a-bash-function

function call_api()
{
	local OPTIND o
	local method token url post_data
	method="GET"
	while getopts ":m:t:u:d:" o; do
		case "${o}" in
			m) method="$OPTARG" ;;
			t) token="$OPTARG" ;;
			u) url="$OPTARG" ;;
			d) post_data="$OPTARG" ;;
			*) echo "$FUNCNAME: invalid option: $OPTARG" >&2
			   exit 1
			   ;;
		esac
	done
	if [ -z "$token" ]; then
		echo "missing token" >&2
		exit 1
	fi
	if [ -z "$url" ]; then
		echo "missing url" >&2
		exit 1
	fi
	if [ -n "$post_data" ]; then
		curl -i -X "$method" -H"Authorization: Bearer $token" "$url" -H'Content-Type: application/json' -d "$post_data" 2>/dev/null
	else
		curl -i -X "$method" -H"Authorization: Bearer $token" "$url" 2>/dev/null
	fi
	# make sure there's a final newline
	echo ""
}
function parse_http_status()
{
        awk 'NR == 1 {print $2; exit}'
}
function parse_http_body()
{
	awk -v inbody=0 '/^[[:space:]]*$/ {inbody=1; next} inbody {print}'
}
function aux_test_auth()
{
	local OPTIND o
	local method token url post_data
	local status_assertion_options=() message dodebug=0
	while getopts ":m:t:u:d:s:M:D" o; do
		case "${o}" in
			m) method="$OPTARG" ;;
			t) token="$OPTARG" ;;
			u) url="$OPTARG" ;;
			d) post_data="$OPTARG" ;;
			s) status_assertion_options+=("$OPTARG") ;;
			M) message="$OPTARG" ;;
			D) dodebug=1 ;;
			*) echo "$FUNCNAME: invalid option: $OPTARG" >&2
			   exit 1
			   ;;
		esac
	done
	if [ "${#status_assertion_options[@]}" -eq 0 ]; then
		echo "missing status code assertions" >&2
		exit 1
	fi
	[ -n "$message" ] && printf 'AUTH(expect one of: %s): %s... ' "${status_assertion_options[*]}" "$message"
	local resp="$(call_api -m "$method" -t "$token" -u "$url" -d "$post_data")"
	local status="$(echo "$resp" | parse_http_status)"
	# at least one needs to match for the assertion to succeed
	local asserted_status
	for asserted_status in "${status_assertion_options[@]}"; do
		if [ "$status" -eq "$asserted_status" ]; then
			echo "OK"
			return
		fi
	done
	echo "FAILED"
	if [ "$dodebug" -eq 1 ]; then
		echo "failed status: got '$status' but expected at least one of '${status_assertion_options[*]}'"
		echo "$resp"
	fi
}
function aux_test_body()
{
	# NOTE: this function assumes the status code has already been
	# checked before being called.
	# -C: check expression passed to jq
	#     which should process the response body
	#     and output to stdout 'true' for success, 'false' for failure
	local OPTIND o
	local method token url post_data
	local message dodebug=0 check_expr
	while getopts ":m:t:u:d:M:DC:" o; do
		case "${o}" in
			m) method="$OPTARG" ;;
			t) token="$OPTARG" ;;
			u) url="$OPTARG" ;;
			d) post_data="$OPTARG" ;;
			M) message="$OPTARG" ;;
			D) dodebug=1 ;;
			C) check_expr="$OPTARG" ;;
			*) echo "$FUNCNAME: invalid option: $OPTARG" >&2
			   exit 1
			   ;;
		esac
	done
	if [ -z "$check_expr" ]; then
		echo "missing check expression" >&2
		exit 1
	fi
	[ -n "$message" ] && printf 'BODY: %s... ' "$message"
	local resp="$(call_api -m "$method" -t "$token" -u "$url" -d "$post_data")"
	# local status="$(echo "$resp" | parse_http_status)"
	local body="$(echo "$resp" | parse_http_body)"
	local check_result="$(echo "$body" | jq -r "$check_expr")"
	case "$check_result" in
		true) echo "OK"
		      return ;;
		false) echo "FAILED"
		       if [ "$dodebug" -eq 1 ]; then
			       echo "failed check expr: \"$check_expr\""
			       echo "$resp"
		       fi
		       return
		       ;;
		*) echo "invalid result for check on http response body: got $check_result" >&2
		   exit 1
		   ;;
	esac
}

aux_test_auth -M "confirming researchers can't make children" \
	      -m POST -t "$IDTOKEN_RESEARCHER1" -u "$API_URL/children" \
	      -s 403 -D
aux_test_auth -M "confirming admins can't make children" \
	      -m POST -t "$IDTOKEN_ADMIN" -u "$API_URL/children" \
	      -s 403 -D
if [ "$test_create_researchers" = 1 ]; then
aux_test_auth -M "confirming parents CAN'T make researchers" \
	      -m POST -t "$IDTOKEN_PARENT1" -u "$API_URL/researchers" -d '{"given_name": "Richard", "family_name": "Johnson", "email": "gabriel.lisaca+dump-researcher@gmail.com"}' \
	      -s 403 -D
aux_test_auth -M "confirming researchers CAN'T make researchers" \
	      -m POST -t "$IDTOKEN_RESEARCHER1" -u "$API_URL/researchers" -d '{"given_name": "Richard", "family_name": "Johnson", "email": "gabriel.lisaca+dump-researcher@gmail.com"}' \
	      -s 403
aux_test_auth -M "confirming admins CAN make researchers" \
	      -m POST -t "$IDTOKEN_ADMIN" -u "$API_URL/researchers" -H'content-type: application/json' -d '{"given_name": "Richard", "family_name": "Johnson", "email": "gabriel.lisaca+dump-researcher@gmail.com"}' \
	      -s 204
fi

echo "registering child for parent1..."
CHILDID="$(call_api -m POST -t "$IDTOKEN_PARENT1" -u "$API_URL/children" | parse_http_body | jq -r '.data.id')"
echo "childID is $CHILDID"

if true; then
echo "TEST: actions whose status code won't change when child/researcher added/removed to/from study"
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	# first we set our assertions
	check_expr_fragment_basicformat="(. | type==\"object\") and (.data | type==\"array\") and all(.data[]; has(\"id\"))"
	check_expr_fragment_parents="
	[\"$EMAIL_PARENT1\",
	 \"$EMAIL_PARENT2\"
	] as \$parents | (\$parents - [.data[].id]) | length == 0
        "
	check_expr_fragment_researchers="
	[\"$EMAIL_RESEARCHER1\",
	 \"$EMAIL_RESEARCHER2\",
         \"$EMAIL_ADMIN\"
	] as \$researchers | (\$researchers - [.data[].id]) | length == 0
        "
	check_expr_fragment_admins="
	[\"$EMAIL_ADMIN\"
	] as \$admins | (\$admins - [.data[].id]) | length == 0
        "
	for usertype in parents researchers admins; do
		assert_code=403
		check_expr=""
		case "$user" in
			PARENT1|PARENT2)
				case "$usertype" in
					researchers)
						assert_code=200
						check_expr="${check_expr_fragment_basicformat}
						and ${check_expr_fragment_researchers}"
						;;
					admins)
						assert_code=200
						check_expr="${check_expr_fragment_basicformat}
						and ${check_expr_fragment_admins}"
						;;
				esac
				;;
			RESEARCHER1|RESEARCHER2)
				case "$usertype" in
					researchers)
						assert_code=200
						check_expr="${check_expr_fragment_basicformat}
						and ${check_expr_fragment_researchers}"
						;;
					admins)
						assert_code=200
						check_expr="${check_expr_fragment_basicformat}
						and ${check_expr_fragment_admins}"
						;;
				esac
				;;
			# admins can view all lists of user groups
			ADMIN)
				assert_code=200
				case "$usertype" in
					parents)
						check_expr="${check_expr_fragment_basicformat}
						and ${check_expr_fragment_parents}"
						;;
					researchers)
						check_expr="${check_expr_fragment_basicformat}
						and ${check_expr_fragment_researchers}"
						;;
					admins)
						check_expr="${check_expr_fragment_basicformat}
						and ${check_expr_fragment_admins}"
						;;
				esac
				;;
		esac

		# now we actually test
		aux_test_auth -M "$user: listing user group $usertype" \
			      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/$usertype" \
			      -s "$assert_code" -D
		# we won't check the response bodies for the unauthorised calls
		if [ -n "$check_expr" ]; then
			aux_test_body -M "$user: checking if test $usertype are in the list of $usertype" \
				      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/$usertype" \
				      -C "$check_expr" -D
		fi
	done

	assert_code=403
	check_expr=""
	case "$user" in
		PARENT1|ADMIN)
			assert_code=200
			check_expr="
			[\"$CHILDID\"
			] as \$children | (\$children - [.data[].id]) | length == 0"
			;;
	esac
	aux_test_auth -M "$user: listing children of PARENT1" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/parents/$EMAIL_PARENT1/children" \
		      -s "$assert_code"
	# we won't check the response bodies for the unauthorised calls
	if [ -n "$check_expr" ]; then
		aux_test_body -M "$user: checking if test child(ren) is in list of children for parent" \
			      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/parents/$EMAIL_PARENT1/children" \
			      -C "$check_expr" -D
	fi

	assert_code=403
	case "$user" in
		PARENT1)
			assert_code=204
			echo "clearing samples before an action which should be authorised..."
			sam remote invoke --stack-name "$STACKNAME" FuncMetaClearSamples
			echo ""
			;;
	esac
	aux_test_auth -M "$user: POSTing samples for child" \
		      -m POST -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/samples/$CHILDID" -d "$("$(git rev-parse --show-toplevel)/server/generateXsamples" 1)" \
		      -s "$assert_code"
done
fi

echo "clearing samples..."
sam remote invoke --stack-name "$STACKNAME" FuncMetaClearSamples
echo ""
BADSAMPLES="$("$(git rev-parse --show-toplevel)/server/generateXsamples" 7 |
		     jq -r '.samples[0].uv |= -1 |
			    .samples[1].light |= -1 |
			    .samples[2].col_red |= 256 |
			    .samples[3].col_green |= 256 |
			    .samples[4].col_blue |= 256 |
			    .samples[5].col_clear |= -1 |
			    .samples[6].col_temp |= -1')"
aux_test_body -M "checking if out-of-range field values are rejected" \
	      -m POST -t "$IDTOKEN_PARENT1" -u "$API_URL/samples/$CHILDID" -d "$BADSAMPLES" \
	      -D -C "(.errors | length == 7)
	      	     and all(.errors[]; .status == 400 and (.message | contains(\"out of range\")))"

echo "TEST: auth for actions whose status is affected by studies..."

if true; then
echo "TEST: PRE-STUDIES: child personal info auth and child sample fetching..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	assert_code=403
	case "$user" in
		PARENT1) assert_code=200 ;;
	esac
	aux_test_auth -M "$user: getting personal info for child" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/children/$CHILDID/info" \
		      -s "$assert_code"

	assert_code=403
	case "$user" in
		PARENT1) assert_code=204 ;;
	esac
	aux_test_auth -M "$user: PUTting personal info for child" \
		      -m PUT -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/children/$CHILDID/info" -d '{"given_name": "John", "family_name": "Cena"}' \
		      -s "$assert_code"
	aux_test_auth -M "$user: PATCHing personal info for child" \
		      -m PATCH -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/children/$CHILDID/info" -d '{"gender": "male"}' \
		      -s "$assert_code"

	assert_code=403
	case "$user" in
		PARENT1) assert_code=200 ;;
	esac
	aux_test_auth -M "$user: fetching samples for child" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/samples/$CHILDID" \
		      -s "$assert_code"
done
# NOTE: at this point, the child personal info would have been modified by the auth checking and are thus in an indeterminate state.
CHILDINFO='{
	"given_name": "Bob",
	"middle_name": "Billy",
	"family_name": "Jones",
	"nickname": "Bobby",
	"gender": "male",
	"birthdate": "2024-03-12"
}'
call_api -m PUT -t "$IDTOKEN_PARENT1" -u "$API_URL/children/$CHILDID/info" -d "$CHILDINFO" >/dev/null
aux_test_body -M "checking if PUT on child personal info works as expected" \
	      -m GET -t "$IDTOKEN_PARENT1" -u "$API_URL/children/$CHILDID/info" \
	      -D -C "(.data == $CHILDINFO)"
newfamilyname="Cena"
call_api -m PATCH -t "$IDTOKEN_PARENT1" -u "$API_URL/children/$CHILDID/info" -d "{\"family_name\": \"$newfamilyname\"}" >/dev/null
aux_test_body -M "checking if PATCH on child personal info works as expected" \
	      -m GET -t "$IDTOKEN_PARENT1" -u "$API_URL/children/$CHILDID/info" \
	      -D -C ".data == ($CHILDINFO | .family_name |= \"$newfamilyname\")"
# Now we check if backend rejects invalid field values
nongender="nongender"
aux_test_body -M "checking if nonexistent gender value '$nongender' is rejected from child personal info" \
	      -m PATCH -t "$IDTOKEN_PARENT1" -u "$API_URL/children/$CHILDID/info" -d "{\"gender\": \"$nongender\"}" \
	      -D -C "(.errors[0].status == 400)
	             and (.errors[0].resource | contains(\"fieldvalue=gender\"))"
nonbirthdate="nonbirthdate"
aux_test_body -M "checking if nonexistent birthdate value '$nonbirthdate' is rejected from child personal info" \
	      -m PATCH -t "$IDTOKEN_PARENT1" -u "$API_URL/children/$CHILDID/info" -d "{\"birthdate\": \"$nonbirthdate\"}" \
	      -D -C "(.errors[0].status == 400)
	             and (.errors[0].resource | contains(\"fieldvalue=birthdate\"))"
fi

# order:
# - create study
# - fetch/modify study details
# - list studies (globally)
# - add child/researcher to study
# - list studies (for child/researcher)
# - get samples from a given study
# - get samples from a given child
# - remove child/researcher from
# - get samples from a given study
# - get samples from a given child
if true; then
echo "TEST: study creation and study details..."
STUDYID="TEST123"
BADSTUDYID="ABC123"
STUDYFIELDS='{"start_date": "2024-01-01", "end_date": "2024-06-01", "name": "Test", "description": "Test description"}'
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	# everyone can list studies globally
	aux_test_auth -M "$user: listing studies (globally)" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies" \
		      -s 200

	case "$user" in
		ADMIN) assert_code=204 ;;
	esac
	aux_test_auth -M "$user: creating study with ID $STUDYID" \
		      -m PUT -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies/$STUDYID" -d "$STUDYFIELDS" \
		      -D -s "$assert_code"
done

for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	assert_code=403
	case "$user" in
		ADMIN) assert_code=409 ;;
	esac
	aux_test_auth -M "$user: creating study with duplicate ID $STUDYID" \
		      -m PUT -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies/$STUDYID" -d "$STUDYFIELDS" \
		      -D -s "$assert_code"

	# everyone can fetch study details
	aux_test_auth -M "$user: getting details of study" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies/$STUDYID/info" \
		      -D -s 200

	assert_code=403
	case "$user" in
		ADMIN) assert_code=204 ;;
	esac
	aux_test_auth -M "$user: PUTting details of study" \
		      -m PUT -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies/$STUDYID/info" -d "$STUDYFIELDS" \
		      -D -s "$assert_code"
	aux_test_auth -M "$user: PATCHing details of study" \
		      -m PATCH -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies/$STUDYID/info" -d '{"description": "testing myopia"}' \
		      -D -s "$assert_code"
done

aux_test_body -M "checking if backend rejects creating study with ID $BADSTUDYID with empty input" \
	      -m PUT -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$BADSTUDYID" \
	      -D -C "(.errors[0].message | test(\"missing.+body\"))"
for missing_field in start_date end_date; do
	aux_test_body -M "checking if backend rejects creating study with ID $BADSTUDYID with missing field '$missing_field'" \
		      -m PUT -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$BADSTUDYID" -d "$(echo "$STUDYFIELDS" | jq -r "del(.$missing_field)")" \
		      -D -C "(.errors[0].resource | contains(\"fieldname=$missing_field\"))
		             and (.errors[0].message | contains(\"missing\"))"
done
aux_test_auth -M "fetching details of nonexistent study $BADSTUDYID" \
	      -m GET -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$BADSTUDYID/info" \
	      -D -s 404
aux_test_auth -M "PUTting details of nonexistent study $BADSTUDYID" \
	      -m PUT -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$BADSTUDYID/info" -d "$STUDYFIELDS" \
	      -D -s 404
aux_test_auth -M "PATCHing details of nonexistent study $BADSTUDYID" \
	      -m PATCH -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$BADSTUDYID/info" -d '{"description": "testing myopia"}' \
	      -D -s 404

# NOTE: at this point, the study details would have been modified by the auth checking and are thus in an indeterminate state.
call_api -m PUT -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$STUDYID/info" -d "$STUDYFIELDS" >/dev/null
aux_test_body -M "checking if PUT on study details works as expected" \
	      -m GET -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$STUDYID/info" \
	      -D -C "(.data == $STUDYFIELDS)"
newname="updated study name"
call_api -m PATCH -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$STUDYID/info" -d "{\"name\": \"$newname\"}" >/dev/null
aux_test_body -M "checking if PATCH on study details works as expected" \
	      -m GET -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$STUDYID/info" \
	      -D -C ".data == ($STUDYFIELDS | .name |= \"$newname\")"

for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	assert_code=403
	case "$user" in
		ADMIN) assert_code=200 ;;
	esac
	aux_test_auth -M "$user: listing participants in study" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies/$STUDYID/participants" \
		      -s "$assert_code"
done
aux_test_body -M "checking there are no participants of the study we just made" \
	      -m GET -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$STUDYID/participants" \
	      -D -C "(.data.children | length == 0) and (.data.parents | length == 0) and (.data.researchers | length == 0)"
aux_test_auth -M "listing participants of nonexistent study $BADSTUDYID" \
	      -m GET -t "$IDTOKEN_ADMIN" -u "$API_URL/studies/$BADSTUDYID/participants" \
	      -s 404
fi

if true; then
echo "TEST: adding to study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	assert_code=403
	case "$user" in
		PARENT1) assert_code=204 ;;
	esac
        aux_test_auth -M "$user: adding child to study" \
		      -m PUT -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/children/$CHILDID/studies/$STUDYID" \
		      -D -s "$assert_code"

	assert_code=403
	case "$user" in
		ADMIN) assert_code=204 ;;
	esac
        aux_test_auth -M "$user: adding researcher1 to study" \
		      -m PUT -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/researchers/$EMAIL_RESEARCHER1/studies/$STUDYID" \
		      -D -s "$assert_code"
done
fi

# NOTE: the following tests require the above participants having been added to the study

if true; then
echo "TEST: listing studies that a child/user is participating in..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	assert_code=403
	check_expr=""
	case "$user" in
		PARENT1|ADMIN)
			assert_code=200
			check_expr="
			[\"$STUDYID\"] as \$studies | (\$studies - [.data[].id]) | length == 0"
			;;
	esac
	aux_test_auth -M "$user: listing studies (for child)" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/children/$CHILDID/studies" \
		      -D -s "$assert_code"
	if [ -n "$check_expr" ]; then
		aux_test_body -M "$user: checking child is in study" \
			      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/children/$CHILDID/studies" \
			      -D -C "$check_expr"
	fi

	assert_code=403
	check_expr=""
	case "$user" in
		RESEARCHER1|ADMIN)
			assert_code=200
			check_expr="
			[\"$STUDYID\"] as \$studies | (\$studies - [.data[].id]) | length == 0"
			;;
	esac
	aux_test_auth -M "$user: listing studies (for researcher1)" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/researchers/$EMAIL_RESEARCHER1/studies" \
		      -D -s "$assert_code"
	if [ -n "$check_expr" ]; then
		aux_test_body -M "$user: checking researcher1 is in study" \
			      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/researchers/$EMAIL_RESEARCHER1/studies" \
			      -D -C "$check_expr"
	fi

	assert_code=403
	check_expr=""
	case "$user" in
		RESEARCHER2|ADMIN)
			assert_code=200
			check_expr="
			[\"$STUDYID\"] as \$studies | (\$studies - [.data[].id]) | length == 1"
			;;
	esac
	aux_test_auth -M "$user: listing studies (for researcher2)" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/researchers/$EMAIL_RESEARCHER2/studies" \
		      -D -s "$assert_code"
	if [ -n "$check_expr" ]; then
		aux_test_body -M "$user: checking researcher2 is NOT in study" \
			      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/researchers/$EMAIL_RESEARCHER2/studies" \
			      -D -C "$check_expr"
	fi
done
fi

if true; then
echo "TEST: sample fetching..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	assert_code=403
	case "$user" in
		RESEARCHER1)
			assert_code=200
			;;
	esac
	aux_test_auth -M "$user: fetching samples from study" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/studies/$STUDYID/samples" \
		      -D -s "$assert_code"

	assert_code=403
	case "$user" in
		PARENT1|RESEARCHER1)
			assert_code=200
			;;
	esac
	aux_test_auth -M "$user: fetching samples from child" \
		      -m GET -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/samples/$CHILDID" \
		      -D -s "$assert_code"
done

echo "clearing samples to prepare for testing the research period..."
sam remote invoke --stack-name "$STACKNAME" FuncMetaClearSamples
echo ""
STUDY_START_DATE="$(echo "$STUDYFIELDS" | jq -r '.start_date')"
STUDY_END_DATE="$(echo "$STUDYFIELDS" | jq -r '.end_date')"
# The third sample is definitely not in the study.
RANGETESTSAMPLES="$("$(git rev-parse --show-toplevel)/server/generateXsamples" 3 |
			   jq -r ".samples[0].timestamp |= \"$STUDY_START_DATE\" + \"T00:00:00Z\" |
			          .samples[1].timestamp |= \"$STUDY_END_DATE\" + \"T23:59:59Z\"")"
call_api -m POST -t "$IDTOKEN_PARENT1" -u "$API_URL/samples/$CHILDID" -d "$RANGETESTSAMPLES" >/dev/null
aux_test_body -M "checking if samples from child of same study as researcher are restricted the samples in research period" \
	      -m GET -t "$IDTOKEN_RESEARCHER1" -u "$API_URL/samples/$CHILDID" \
	      -D -C ".data | length == 2"
aux_test_body -M "checking if samples from study have timestamps from within the research period" \
	      -m GET -t "$IDTOKEN_RESEARCHER1" -u "$API_URL/studies/$STUDYID/samples" \
	      -D -C ".data | length == 2"
fi

if true; then
echo "TEST: removing from study..."
# TODO: test what happens if delete someone from nonexistent study
aux_test_auth -M "checking if deleting someone from study which doesn't exist indicates there is no such study" \
	      -m DELETE -t "$IDTOKEN_ADMIN" -u "$API_URL/researchers/$EMAIL_RESEARCHER2/studies/$BADSTUDYID" \
	      -D -s 404
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "re-adding child to study to prepare for auth test of child removal (from study)..."
        call_api -m PUT -t "$IDTOKEN_PARENT1" -u "$API_URL/children/$CHILDID/studies/$STUDYID" >/dev/null
	assert_code=403
	case "$user" in
		PARENT1|ADMIN) assert_code=204 ;;
	esac
	aux_test_auth -M "$user: removing child from study" \
		      -m DELETE -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/children/$CHILDID/studies/$STUDYID" \
		      -D -s "$assert_code"

	echo "re-adding researcher1 to study to prepare for auth test of researcher removal (from study)..."
        call_api -m PUT -t "$IDTOKEN_ADMIN" -u "$API_URL/researchers/$EMAIL_RESEARCHER1/studies/$STUDYID" >/dev/null
	assert_code=403
	case "$user" in
		ADMIN) assert_code=204 ;;
	esac
	aux_test_auth -M "$user: removing researcher1 from study" \
		      -m DELETE -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/researchers/$EMAIL_RESEARCHER1/studies/$STUDYID" \
		      -D -s "$assert_code"
done
aux_test_auth -M "checking if deleting a researcher from study who isn't actually in the study doesn't confirm the existence of the ID" \
	      -m DELETE -t "$IDTOKEN_ADMIN" -u "$API_URL/researchers/$EMAIL_RESEARCHER2/studies/$STUDYID" \
	      -D -s 403
fi

if false; then
echo "test: listing participants in study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: listing participants in study"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/participants" 2>/dev/null #| head -n1
	echo ""
done
fi

if false; then
echo "test: sample fetching..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: fetching samples from study"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/samples" 2>/dev/null #| head -n1
	echo ""

	echo "$user: fetching samples from child"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/samples/$CHILDID" 2>/dev/null #| head -n1
	echo ""
done
fi
