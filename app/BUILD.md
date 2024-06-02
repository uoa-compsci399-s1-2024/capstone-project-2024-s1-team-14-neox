# Neox Sens App 

## Setting Backend Instance of Server on App 

To setup the connection to a new server or change from an existing one.

**Follow these instructions:** 

1. Navigate to `/project_root/app/lib/server/child_api_service.dart`. 

2. Look at line 11 where you should see something similar to: `static const String apiUrl = 'https://xu31tcdj0e.execute-api.ap-southeast-2.amazonaws.com/dev';`. 

3. Replace the URL with the URL for your own backend instance. 


## Setting AWS Cognito Userpool

To use a certain Cognito Userpool you will have to change the `POOL_ID` and `CLIENT_ID` in the application `.env` file. 

**Follow these instructions:** 

1. Navigate to `/project_root/app/.env`. 

2. Set the `POOL_ID` and `CLIENT_ID` to the values that match your userpool. 






