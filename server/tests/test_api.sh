#!/bin/bash

usage() { echo "Usage: $0 [-s]" 1>&2; exit 1; }

while getopts ":sh" o; do
	case "${o}" in
		s)
			s=1
			;;
		*|h)
			usage
			;;
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
	[ -n "$message" ] && printf '%s... ' "$message"
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

aux_test_auth -M "confirming researchers can't make children" \
	      -m POST -t "$IDTOKEN_RESEARCHER1" -u "$API_URL/children" \
	      -s 403 -D
aux_test_auth -M "confirming admins can't make children" \
	      -m POST -t "$IDTOKEN_ADMIN" -u "$API_URL/children" \
	      -s 403 -D
if false; then
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
CHILDID="$(curl -X POST -H"Authorization: Bearer $IDTOKEN_PARENT1" "$API_URL/children" 2>/dev/null | jq -r '.data.id')"
echo "childID is $CHILDID"

if true; then
echo "testing auth..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: getting personal info for child"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/children/$CHILDID/info" 2>/dev/null | head -n1
	# echo ""

	echo "$user: PUTting personal info for child"
	curl -i -X PUT -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/children/$CHILDID/info" -d '{"given_name": "John", "family_name": "Cena"}' 2>/dev/null | head -n1
	# echo ""

	echo "$user: PATCHing personal info for child"
	curl -i -X PATCH -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/children/$CHILDID/info" -d '{"gender": "male"}' 2>/dev/null | head -n1
	# echo ""

	echo "$user: fetching samples for child"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/samples/$CHILDID" 2>/dev/null | head -n1
	# echo ""

	echo "$user: POSTing samples for child"
	curl -i -X POST -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/samples/$CHILDID" -H'content-type: application/json' -d "$("$(git rev-parse --show-toplevel)/server/generateXsamples" 1)" 2>/dev/null | head -n1
	# echo ""

	for usertype in parents researchers admins; do
		echo "$user: listing user group $usertype"
		curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/$usertype" 2>/dev/null | head -n1
		# echo ""
	done

	echo "$user: listing children of PARENT1"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/parents/$EMAIL_PARENT1/children" 2>/dev/null #| head -n1
	# echo ""
done
fi  # false

echo "testing auth for studies..."
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
if true; then
echo "test: creating study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: creating study"
	curl -i -X PUT -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID" -d '{"start_date": "2024-01-23", "end_date": "2024-06-13"}' 2>/dev/null #| head -n1
	echo ""
done
fi

if true; then
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

if true; then
echo "test: listing studies (globally)..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: listing studies (globally)"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies" 2>/dev/null #| head -n1
	echo ""
done
fi

if true; then
echo "test: listing participants in study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: listing participants in study"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/participants" 2>/dev/null #| head -n1
	echo ""
done
fi

if true; then
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

if true; then
echo "test: listing participants in study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: listing participants in study"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/participants" 2>/dev/null #| head -n1
	echo ""
done
fi

if true; then
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

if true; then
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

if true; then
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

if true; then
echo "test: listing participants in study..."
for user in PARENT1 PARENT2 RESEARCHER1 RESEARCHER2 ADMIN; do
	echo "$user: listing participants in study"
	curl -i -X GET -H"Authorization: Bearer $(eval echo \$"IDTOKEN_${user}")" "$API_URL/studies/$STUDYID/participants" 2>/dev/null #| head -n1
	echo ""
done
fi

if true; then
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
