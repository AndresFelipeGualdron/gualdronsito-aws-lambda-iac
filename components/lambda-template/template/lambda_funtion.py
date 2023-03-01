

def lambda_handler(event, context):
    rs = {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin" : "*"
            },
            "body": "hello world"
        }
    return rs
    