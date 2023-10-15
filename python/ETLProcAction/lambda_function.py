import boto3
import json
import os

DataOutputBucketName = os.environ["DataOutputBucketName"] # 'octovmwebsitearm'
cronjobcadence       = os.environ["cronjobcadence"] # how often a cron job it run, to pull from previous pull
deployvm             = os.environ["deployvm"]
deploylambda         = os.environ["deploylambda"]
deploycontainer      = os.environ["deploycontainer"]
output               ='s3://'+DataOutputBucketName+'/dataquery/'# Where API query results will be stored

def lambda_handler(event, context):
    if deployvm == True:
        response=1
        return response
    elif deploylambda == True:
        response=1
        return response
    elif deploycontainer == True:
        response=1
        return response
    else:
        return {
            'statusCode': 501,
            'body': json.dumps("501 Server-side Error: No deployment type detected")
        }
    
    return
