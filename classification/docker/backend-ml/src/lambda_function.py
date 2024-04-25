import json
import sklearn
import joblib


def lambda_handler(event, context):

    # Read in pickled model
    model = joblib.load("xgboost_model.pkl")

    # Extract the body of the request
    data = json.loads(event['body'])

    prediction = model.score(data)
    # Return prediction
    return {
        'statusCode': 200,
        'body': json.dumps(1 if prediction[1] > 0.7 else 0 )
    }
