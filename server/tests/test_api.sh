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
echo "clearing studies..."
sam remote invoke --stack-name "$STACKNAME" FuncMetaClearStudies
echo "clearing children..."
sam remote invoke --stack-name "$STACKNAME" FuncMetaClearChildren

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
			*) echo "invalid option: $o" >&2
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
	if [ "$method" = "POST" ] && [ -n "$post_data" ]; then
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
			*) echo "invalid option: $o" >&2
			   exit 1
			   ;;
		esac
	done
	if [ "${#status_assertion_options[@]}" -eq 0 ]; then
		echo "missing status code assertions" >&2
		exit 1
	fi
	[ -n "$message" ] && printf 'AUTH: %s... ' "$message"
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
			*) echo "invalid option: $o" >&2
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
echo "TEST: auth for actions whose status code won't change when child/researcher added/removed to/from study"
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
		PARENT1) assert_code=204 ;;
	esac
	aux_test_auth -M "$user: POSTing samples for child" \
		      -m POST -t "$(eval echo \$"IDTOKEN_${user}")" -u "$API_URL/samples/$CHILDID" -d "$("$(git rev-parse --show-toplevel)/server/generateXsamples" 1)" \
		      -s "$assert_code"
done
fi

echo "testing auth for studies..."

if true; then
echo "TEST: PRE-STUDIES: child personal info auth..."
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
STUDYID="TEST123"
BADSTUDYID="ABC123"
if false; then
echo "test: creating study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: creating study"
	curl -i -X PUT -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID" -d '{"start_date": "2024-01-23", "end_date": "2024-06-13"}' 2>/dev/null #| head -n1
	echo ""
done
fi

if false; then
echo "test: study details..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: getting details of study"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/info" 2>/dev/null | head -n1
	# echo ""

	echo "$user: PUTting details of study"
	curl -i -X PUT -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/info" -d '{"start_date": "2020-01-01", "end_date": "2020-12-31", "name": "myopia test"}' 2>/dev/null | head -n1
	# echo ""

	echo "$user: PATCHing details of study"
	curl -i -X PATCH -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/info" -d '{"description": "testing myopia"}' 2>/dev/null | head -n1
	# echo ""
done
fi

if false; then
echo "test: listing studies (globally)..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: listing studies (globally)"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies" 2>/dev/null #| head -n1
	echo ""
done
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
echo "test: adding to study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: adding child to study"
	curl -i -X PUT -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/children/$CHILDID/studies/$STUDYID" 2>/dev/null #| head -n1
	echo ""

	echo "$user: adding researcher1 to study"
	curl -i -X PUT -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/researchers/$EMAIL_RESEARCHER1/studies/$STUDYID" 2>/dev/null #| head -n1
	echo ""

	# echo "$user: adding researcher2 to study"
	# curl -i -X PUT -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/researchers/$EMAIL_RESEARCHER2/studies/$STUDYID" 2>/dev/null #| head -n1
	# echo ""
done
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
echo "test: listing studies..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: listing studies (for child)"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/children/$CHILDID/studies" 2>/dev/null #| head -n1
	echo ""

	echo "$user: listing studies (for researcher1)"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/researchers/$EMAIL_RESEARCHER1/studies" 2>/dev/null #| head -n1
	echo ""

	echo "$user: listing studies (for researcher2)"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/researchers/$EMAIL_RESEARCHER2/studies" 2>/dev/null #| head -n1
	echo ""

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

if false; then
echo "test: removing from study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: removing child from study"
	curl -i -X DELETE -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/children/$CHILDID/studies/$STUDYID" 2>/dev/null #| head -n1
	echo ""

	echo "$user: removing researcher1 from study"
	curl -i -X DELETE -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/researchers/$EMAIL_RESEARCHER1/studies/$STUDYID" 2>/dev/null #| head -n1
	echo ""

	echo "$user: removing researcher2 from study"
	curl -i -X DELETE -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/researchers/$EMAIL_RESEARCHER2/studies/$STUDYID" 2>/dev/null #| head -n2
	echo ""
done
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
