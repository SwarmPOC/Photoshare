#AWSLambdaFunction
#MMCM_Private_News
import json
import boto3
import time
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    client = boto3.client('dynamodb')
    if event['action'] == 'new':
       return newUserRelation(client, event)

def getUserItem(client,params):
    try:
       response = client.get_item(TableName='MMCM_User', Key={'userID':{'S':params['userID']}})
    except ClientError as e:
       return {'sError':'ClientError: MPL_GUI'}
    else:
       if 'Item' in response.keys():
          return response['Item']
       return {'uError':'User does not exist'}

