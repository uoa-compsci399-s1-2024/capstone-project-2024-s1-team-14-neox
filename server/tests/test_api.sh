#!/bin/bash
set -e
set -o pipefail

echo "getting userpool ID, etc from sam..."
STACKNAME="backend-server-dev"
POOLID="$(sam list stack-outputs --output json --stack-name "$STACKNAME" | jq -r '.[] | select(.OutputKey == "UserPoolId") | .OutputValue')"
CLIENTID="$(sam list stack-outputs --output json --stack-name "$STACKNAME" | jq -r '.[] | select(.OutputKey == "AppClientId") | .OutputValue')"
API_URL="$(sam list stack-outputs --output json --stack-name "$STACKNAME" | jq -r '.[] | select(.OutputKey == "APIEndpoint") | .OutputValue')"

EMAIL_PARENT1="gabriel.lisaca@gmail.com"
IDTOKEN_PARENT1="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters USERNAME="$EMAIL_PARENT1",PASSWORD='Password123!' --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"
EMAIL_PARENT2="gabriel.lisaca+parent2@gmail.com"
IDTOKEN_PARENT2="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters USERNAME="$EMAIL_PARENT2",PASSWORD='Password123!' --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"
EMAIL_RESEARCHER="gabriel.lisaca+researcher@gmail.com"
IDTOKEN_RESEARCHER="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters USERNAME="$EMAIL_RESEARCHER",PASSWORD='Password123!' --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"
EMAIL_ADMIN="gabriel.lisaca+admin@gmail.com"
IDTOKEN_ADMIN="$(aws cognito-idp admin-initiate-auth --client-id "$CLIENTID" --auth-parameters USERNAME="$EMAIL_ADMIN",PASSWORD='Password123!' --user-pool-id "$POOLID" --auth-flow ADMIN_USER_PASSWORD_AUTH | jq -r '.AuthenticationResult.IdToken')"

echo "confirming researchers can't make children"
curl -i -X POST -H"Authorization: Bearer $IDTOKEN_RESEARCHER" "$API_URL/children" 2>/dev/null | head -n1
# echo ""
echo "confirming admins can't make children"
curl -i -X POST -H"Authorization: Bearer $IDTOKEN_ADMIN" "$API_URL/children" 2>/dev/null | head -n1
# echo ""

echo "confirming parents CAN'T make researchers"
curl -i -X POST -H"Authorization: Bearer $IDTOKEN_PARENT1" "$API_URL/researchers" -H'content-type: application/json' -d '{"given_name": "Richard", "family_name": "Johnson", "email": "gabriel.lisaca+dump-researcher@gmail.com"}' 2>/dev/null | head -n1
# echo ""
echo "confirming researchers CAN'T make researchers"
curl -i -X POST -H"Authorization: Bearer $IDTOKEN_RESEARCHER" "$API_URL/researchers" -H'content-type: application/json' -d '{"given_name": "Richard", "family_name": "Johnson", "email": "gabriel.lisaca+dump-researcher@gmail.com"}' 2>/dev/null | head -n1
# echo ""
echo "confirming admins CAN make researchers"
curl -i -X POST -H"Authorization: Bearer $IDTOKEN_ADMIN" "$API_URL/researchers" -H'content-type: application/json' -d '{"given_name": "Richard", "family_name": "Johnson", "email": "gabriel.lisaca+dump-researcher@gmail.com"}' 2>/dev/null | head -n1
# echo ""

echo "registering child for parent1..."
CHILDID="$(curl -X POST -H"Authorization: Bearer $IDTOKEN_PARENT1" "$API_URL/children" 2>/dev/null | jq -r '.data.id')"
echo "childID is $CHILDID"

echo "testing auth"
for user in PARENT1 PARENT2 RESEARCHER ADMIN; do
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
done

