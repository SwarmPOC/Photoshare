#AWSLambdaFunction
#MMCM_Public_Login
import json
import boto3
import time
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    client = boto3.client('dynamodb')
    if event['action'] == 'registerUser':
       return register(client, event)
    if event['action'] == 'checkUser':
       return checkUser(client, event)
    else:
       item = getUserItem(client, event)
       if precheck(item, event):
          if event['action'] == 'login':
             return login(client, event, item)
          if event['action'] == 'getUser':
             return item
          if event['action'] == 'logout':
             logout(client, event)
             return "logout OK"
          if event['action'] == 'saveFBProfileData':
             saveFBProfileData(client, event)
             return "saveFBProfileData OK"
          if event['action'] == 'saveFBFriendData':
             return saveFBFriendData(client, event)
             #return "OK"
       else:
          return {"uError":'verification error (1)'}


def checkUser(client, params):
    try:
       response = client.get_item(TableName='MMCM_User', Key={'userID':{'S':params['userID']}})
    except ClientError as e:
       return {'sError':'ClientError: MPL_GUI'}
    else:
       if 'Item' in response.keys():
          return 1
       return 0


def getUserItem(client,params):
    try:
       response = client.get_item(TableName='MMCM_User', Key={'userID':{'S':params['userID']}})
    except ClientError as e:
       return {'sError':'ClientError: MPL_GUI'}
    else:
       if 'Item' in response.keys():
          return response['Item']
       return {'uError':'User does not exist'}


def precheck(item, params):
    if 'AWSCognitoID' in item.keys():
       if item['AWSCognitoID']['S'] == params['AWSCognitoID']:
          return True
    return False


# def login(client, params):
#     item = getUserItem(client, params)
#     if 'userID' in item.keys():
#        if precheck(item, params):
#           tickLoginCount(client, params)
#           return getUserItem(client, params)
#        return {"uError":'verification error'}
#     elif 'uError' in item.keys():
#        register(client, params)
#        return login(client, params)
def login(client, params, item):
    if 'userID' in item.keys():
       tickLoginCount(client, params)
       return getUserItem(client, params)
    return {"uError":'verification error (2)'}


def register(client, params):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_User',
        Key={'userID':{'S':params['userID']}},
        AttributeUpdates={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}},
                          "AWSCognitoID":{"Action":"PUT","Value":{"S":params['AWSCognitoID']}},
                          "FBTokenString":{"Action":"PUT","Value":{"S":params['FBTokenString']}},
                          "lastLoginDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "friendCount":{"Action":"PUT","Value":{"N":"0"}},
                          "loginCount":{"Action":"PUT","Value":{"N":"1"}},
                          "isLoggedIn":{"Action":"PUT","Value":{"N":"1"}}}
    )
    return 0

def tickLoginCount(client, params):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_User',
        Key={'userID':{'S':params['userID']}},
        AttributeUpdates={"loginCount":{"Action":"ADD", "Value":{"N":"1"}},
                          "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}},
                          "lastLoginDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "isLoggedIn":{"Action":"PUT","Value":{"N":"1"}}}
        )


def logout(client, params):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_User',
        Key={'userID':{'S':params['userID']}},
        AttributeUpdates={"isLoggedIn":{"Action":"PUT", "Value":{"N":"0"}},
                          "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
    )

def saveFBProfileData(client, params):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_User',
        Key={'userID':{'S':params['userID']}},
        AttributeUpdates={"lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}},
                          "name":{"Action":"PUT", "Value":{"S":params['name']}},
                          "first_name":{"Action":"PUT", "Value":{"S":params['first_name']}},
                          "last_name":{"Action":"PUT", "Value":{"S":params['last_name']}},
                          "name_format":{"Action":"PUT", "Value":{"S":params['name_format']}},
                          "email":{"Action":"PUT", "Value":{"S":params['email']}},
                          "locale":{"Action":"PUT","Value":{"S":params['locale']}}}
    )

def saveFBFriendData(client, params):
    arr = params['ids']
    response = client.query(TableName='MMCM_UserRelation',
          KeyConditionExpression='userID = :userID',
          ExpressionAttributeValues={':userID':{"S":params['userID']}})
    count = response['Count']
    if count > 0:
       existingRelations = response['Items']
       for item in existingRelations:
          if item['userIDRelation']['S'] in arr:
             arr.remove(item['userIDRelation']['S'])
    if len(arr):
       for userIDRelation in arr:
          epoch_time = str(time.time())
          # Normal link
          client.update_item(TableName='MMCM_UserRelation',
              Key={'userID':{'S':params['userID']},
                   'userIDRelation':{'S':userIDRelation}},
              AttributeUpdates={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
                                "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
                                #"isFBFriend":{"Action":"PUT","Value":{"N":"1"}}}
          )
          # Reverse Link
          client.update_item(TableName='MMCM_UserRelation',
              Key={'userIDRelation':{'S':params['userID']},
                   'userID':{'S':userIDRelation}},
              AttributeUpdates={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
                                "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
                                #"isFBFriend":{"Action":"PUT","Value":{"N":"1"}}}
          )

          TODO: CALL UPDATE FRIEND COUNT...HERE or on Login??

       client.update_item(TableName='MMCM_User',
           Key={'userID':{'S':params['userID']}},
           AttributeUpdates={"lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}},
                             #"FBFriendCount":{"Action":"PUT","Value":{"N":params['FBFriendCount']}},
                             "friendCount":{"Action":"PUT","Value":{"N":str(count+len(arr))}}}
       )
    return count+len(arr)

def processFBFriends(client, params):
    user = getUserItem(client, params)
    if 'FBFriendCount' in user.keys():
       count = user['FBFriendCount']
       if count <= params['FBFriendCount']:
          return True
    return False
    # This is flawed because a user may have unfriended someone and added someone else resulting in
    # an equal number.  A better way may be to hash all the fb friends userIDs
    #
    #
    # As

