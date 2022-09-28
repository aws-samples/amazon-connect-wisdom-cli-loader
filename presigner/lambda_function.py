import json
import boto3
import logging
import os
from botocore.exceptions import ClientError

BUCKET = os.environ['BUCKET']

def lambda_handler(event, context):
    print(event)
    if('filename' in event['params']['querystring']):
        print("Getting url for: " + event['params']['querystring']['filename'])
        signedURL = create_presigned_post(BUCKET, event['params']['querystring']['filename'], event['params']['querystring']['ctype'])
        print(signedURL)
        return signedURL
    else:
        return "NoFun"

def create_presigned_post(bucket_name, object_name,ctype,
                          fields=None, conditions=None, expiration=3600):
    
    
    s3_client = boto3.client('s3')
    try:
        response = s3_client.generate_presigned_url('put_object', Params={'Bucket':bucket_name,'Key':object_name, 'ContentType': ctype}, ExpiresIn=300, HttpMethod='PUT')
        #response = s3_client.generate_presigned_post(bucket_name, object_name, Fields=fields, Conditions=conditions, ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL and required fields
    return response

