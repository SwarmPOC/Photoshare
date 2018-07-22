#AWSLambdaFunction
#MMCM_Public_Login
#import MMCM_Private_News
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
          if event['action'] == 'logout':
             logout(client, event)
             return "logout OK"
          if event['action'] == 'saveFBProfileData':
             return saveFBProfileData(client, event, item)
          if event['action'] == 'saveFBFriendData':
             return saveFBFriendData(client, event)
          if event['action'] == 'retrieveFriends':
             return retrieveFriends(client, event)
          if event['action'] == 'verifyInviteCode':
             return verifyInviteCode(client, event)
          if event['action'] == 'updateName':
             return updateName(client, event)
          if event['action'] == 'updateGender':
             return updateGender(client, event)
          if event['action'] == 'updateRelationshipStatus':
             return updateRelationshipStatus(client, event)
          if event['action'] == 'updateLookingFor':
             return updateLookingFor(client, event)
          if event['action'] == 'addProfilePicture':
             return addProfilePicture(client, event)
          if event['action'] == 'retrieveMediaForTag':
             return retrieveMediaForTag(client, event)
          if event['action'] == 'retrieveTagsForUserID':
             return retrieveTagsForUserID(client, event)
          if event['action'] == 'retrieveGroupData':
             return retrieveGroupData(client, event)
          if event['action'] == 'retrieveGroupUsers':
             return retrieveGroupUsers(client, event)
          if event['action'] == 'retrieveUser':
             return retrieveUser(client, event)
          if event['action'] == 'getUserRelationType':
             return getUserRelationType(client, event)
       else:
          return {"uError":'verification error (1)'}


######################################################################
# Table: MMCM_User
######################################################################
def checkUser(client, params):
    item = retrieveRecord(client, 'MMCM_User', {'userID':{'S':params['userID']}})
    if 'sError' in item.keys():
       return 0
    return 1


def getUserItem(client,params):
    return retrieveRecord(client, 'MMCM_User', {'userID':{'S':params['userID']}})


def precheck(item, params):
    if 'AWSCognitoID' in item.keys():
       if item['AWSCognitoID']['S'] == params['AWSCognitoID']:
          return True
    return False


def login(client, params, item):
    if 'userID' in item.keys():
       tickLoginCount(client, params)
       return myUserData(item)
    return {"uError":'verification error (2)'}

def myUserData(item):
    returnVal = {"firstName":item['first_name']['S'],
                 "lastName":item['last_name']['S'],
                 "fullName":item['name']['S'],
                 "userID":item['userID']['S'],
                 "gender":item['gender']['S'],
                 "inviteCode":item['inviteCode']['S'],
                 "relationshipStatus":item['relationshipStatus']['S'],
                 "registrationAccepted":item['registrationAccepted']['N'],
                 "lookingFor":item['lookingFor']['S'],
                 "creationDate":item['creationDate']['N'],
                 "imageS3Key":item['imageS3Key']['S'] }
    return returnVal


def register(client, params):
    attributes={"creationDate":{"Action":"PUT","Value":{"N":str(time.time())}},
                "AWSCognitoID":{"Action":"PUT","Value":{"S":params['AWSCognitoID']}},
                "FBTokenString":{"Action":"PUT","Value":{"S":params['FBTokenString']}},
                "friendCount":{"Action":"PUT","Value":{"N":"0"}},
                "loginCount":{"Action":"PUT","Value":{"N":"1"}},
                "registrationComplete":{"Action":"PUT","Value":{"N":"0"}},
                "registrationAccepted":{"Action":"PUT","Value":{"N":"0"}},
                "isLoggedIn":{"Action":"PUT","Value":{"N":"1"}}}
    updateUserTable(client, params, attributes)
    createNewUserCode(client, params)
    return getUserItem(client, params)


def completeRegistration(client, params):
    attributes={"registrationComplete":{"Action":"PUT","Value":{"N":"1"}},
                "registrationAccepted":{"Action":"PUT","Value":{"N":"1"}}}
    updateUserTable(client, params, attributes)


def tickLoginCount(client, params):
    attributes={"loginCount":{"Action":"ADD", "Value":{"N":"1"}},
                "lastLoginDate":{"Action":"PUT","Value":{"N":str(time.time())}},
                "isLoggedIn":{"Action":"PUT","Value":{"N":"1"}}}
    updateUserTable(client, params, attributes)


def logout(client, params):
    attributes = {"isLoggedIn":{"Action":"PUT", "Value":{"N":"0"}}}
    updateUserTable(client, params, attributes)


def saveFBProfileData(client, params, item):
    attributes = {"name":{"Action":"PUT", "Value":{"S":params['name']}},
                  "first_name":{"Action":"PUT", "Value":{"S":params['first_name']}},
                  "last_name":{"Action":"PUT", "Value":{"S":params['last_name']}},
                  "name_format":{"Action":"PUT", "Value":{"S":params['name_format']}},
                  "email":{"Action":"PUT", "Value":{"S":params['email']}},
                  "gender":{"Action":"PUT", "Value":{"S":params['gender']}},
                  "locale":{"Action":"PUT","Value":{"S":params['locale']}}}
    updateUserTable(client, params, attributes)
    return myUserData(item)


def updateName(client, params):
    attributes = {"name":{"Action":"PUT", "Value":{"S":params['name']}},
                  "first_name":{"Action":"PUT", "Value":{"S":params['first_name']}},
                  "last_name":{"Action":"PUT", "Value":{"S":params['last_name']}}}
    updateUserTable(client, params, attributes)


def updateGender(client, params):
    attributes = {"gender":{"Action":"PUT", "Value":{"S":params['gender']}}}
    updateUserTable(client, params, attributes)


def updateRelationshipStatus(client, params):
    attributes = {"relationshipStatus":{"Action":"PUT", "Value":{"S":params['relationshipStatus']}}}
    updateUserTable(client, params, attributes)
    if params['relationshipStatus'] == "0":
       groups = getAllUserGroups(client, params['userID'])['Items']
       if groups['Count'] > 0:
          for group in groups['Items']:
             tickGroupSinglesCount(client, group['groupID'])
    if params['relationshipStatus'] == "1" or params['relationshipStatus'] == "2":
       if params['isInitialStatus'] == "NO":
          untickGroupSinglesCount(client, group['groupID'])


def updateLookingFor(client, params):
    attributes = {"lookingFor":{"Action":"PUT", "Value":{"S":params['lookingFor']}}}
    updateUserTable(client, params, attributes)
    completeRegistration(client, params)


def updateUserTable(client, params, attributes):
    updateTable(client, 'MMCM_User', {'userID':{'S':params['userID']}}, attributes)


######################################################################
# Facebook Related
######################################################################
def saveFBFriendData(client, params):
    arrNew = params['ids']
    arrUpdate = []
    allUserRelations = getAllUserRelations(client, params)
    if len(allUserRelations) > 0:
       for item in allUserRelations:
          if item['userIDRelation']['S'] in arrNew:
             arrNew.remove(item['userIDRelation']['S'])
             if item['type']['N'] == 2:
                # relation is restricted - update existing relation
                arrUpdate.add(item['userIDRelation']['S'])
    if len(arrNew):
       processUserRelations(client, params, arrNew, True)
    if len(arrUpdate):
       processUserRelations(client, params, arrUpdate, False)
    return count+len(arrNew)


def processUserRelations(client, params, arrRelations, isNewUserRelation):
    for userIDRelation in arrRelations:
       updateUserRelationType(client, params['userID'], userIDRelation, "1")
    postUserRelationNews(client, params, arrRelations, isNewUserRelation)


######################################################################
# Table: MMCM_UserRelation
######################################################################
def updateUserRelationType(client, userID, userIDRelation, relationType):
    if userID == userIDRelation:
      return
    userRelation = getUserRelation(client, userID, userIDRelation)
    if 'type' in userRelation.keys():
      if (userRelation['type'] == "0") or (userRelation['type'] == "1"):
         # userRelation exists as unrestricted or blocked
         return
    epoch_time = str(time.time())
    attributes={"lastModifiedDate" : {"Action":"PUT","Value":{"N":epoch_time}},
                "type"             : {"Action":"PUT","Value":{"N":relationType}}}
    if 'sError' in userRelation.keys():
       # userRelation does not exist
       attributes["creationDate"] = {"Action":"PUT","Value":{"N":epoch_time}}
    # create the links
    # Link
    client.update_item(TableName='MMCM_UserRelation',
        Key={'userID'        :{'S':userID},
             'userIDRelation':{'S':userIDRelation}},
        AttributeUpdates=attributes
    )
    # Reverse Link
    client.update_item(TableName='MMCM_UserRelation',
        Key={'userID'        :{'S':userIDRelation},
             'userIDRelation':{'S':userID}},
        AttributeUpdates=attributes
    )
    return


def getAllUserRelations(client, userID):
    response = client.query(TableName='MMCM_UserRelation',
           # KeyCondition={'userID':{'S':params['userID']}})
           KeyConditionExpression='userID = :userID',
           ExpressionAttributeValues={':userID':{"S":userID}})
    if response['Count'] > 0:
       return response['Items']
    else:
       return []


def getUserRelation(client, userID, userIDRelation):
    key={'userID':{'S':userID},
         'userIDRelation':{'S':userIDRelation}}
    return retrieveRecord(client, 'MMCM_UserRelation', key)


######################################################################
# Table: MMCM_RegistrationCode
######################################################################
def createNewUserCode(client, params):
    params['registrationCodesAction']='createNewUserCode'
    response = boto3.client('lambda').invoke(
          FunctionName='MMCM_Private_RegistrationCodes',
          Payload=json.dumps(params))
    # print response['Payload'].read()
    return 0


def verifyInviteCode(client, params):
    key={'codeID':{'S':params['code']}}
    item = retrieveRecord(client, 'MMCM_RegistrationCode', key)
    if 'active' in item.keys():
       if item['active']['N'] == '1':
          key={'userID':{'S':params['userID']},
               'groupID':{'S':item['link']['S']}}
          testItem = retrieveRecord(client, 'MMCM_UserGroup', key)
          if 'sError' in testItem.keys():
             invitationCodeAction(client, params, item)
          return True
    return False


def invitationCodeAction(client, params, codeRecord):
    # if code type is individual:
    if codeRecord['type']['N'] == '1':
       # add friend based on link
       updateUserRelationType(client, params['userID'], codeRecord['link']['S'], "1")
    # if code type is pool:
    if codeRecord['type']['N'] == '2':
       # code is a for a group
       # retrieve group type:
       groupRecord = retrieveGroup(client, codeRecord['link']['S'])
       if groupRecord['type']['N'] == "1":
          # network
          Users = getAllGroupUsers(client, codeRecord['link']['S'])
          if Users['Count'] > 0:
             for user in Users['Items']:
                updateUserRelationType(client, params['userID'], user['userID']['S'], "2")
       addGroupUser(client, codeRecord['link']['S'], params['userID'])
       addUserGroup(client, params['userID'], codeRecord['link']['S'])
       tickGroupMemberCount(client, codeRecord['link']['S'])


######################################################################
# Table: MMCM_Group
######################################################################
def retrieveGroup(client, groupID):
    return retrieveRecord(client, 'MMCM_Group', {'groupID':{'S':groupID}})

def tickGroupMemberCount(client, groupID):
    attributes={"memberCount":{"Action":"ADD", "Value":{"N":"1"}}}
    updateTable(client, 'MMCM_Group', {'groupID':{'S':groupID}}, attributes)
def untickGroupMemberCount(client, groupID):
    attributes={"memberCount":{"Action":"ADD", "Value":{"N":"-1"}}}
    updateTable(client, 'MMCM_Group', {'groupID':{'S':groupID}}, attributes)
def tickGroupSinglesCount(client, groupID):
    attributes={"singlesCount":{"Action":"ADD", "Value":{"N":"1"}}}
    updateTable(client, 'MMCM_Group', {'groupID':{'S':groupID}}, attributes)
def untickGroupSinglesCount(client, groupID):
    attributes={"singlesCount":{"Action":"ADD", "Value":{"N":"-1"}}}
    updateTable(client, 'MMCM_Group', {'groupID':{'S':groupID}}, attributes)

######################################################################
# Table: MMCM_GroupUser
######################################################################
def getAllGroupUsers(client, groupID):
    response = client.query(TableName='MMCM_GroupUser',
           KeyConditionExpression='groupID = :groupID',
           ExpressionAttributeValues={':groupID':{"S":groupID}})
    if response['Count'] > 0:
       return response
    else:
       return []


def addGroupUser(client, groupID, userID):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_GroupUser',
        Key={'groupID':{'S':groupID},
             'userID':{'S':userID}},
        AttributeUpdates={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
    )


######################################################################
# Table: MMCM_UserGroup
######################################################################
def getAllUserPools(client, userID):
    response = client.query(TableName='MMCM_UserPool',
           KeyConditionExpression='userID = :userID',
           ExpressionAttributeValues={':userID':{"S":userID}})
    if response['Count'] > 0:
       return response['Items']
    else:
       return []


def getAllUserGroups(client, userID):
    response = client.query(TableName='MMCM_UserGroup',
           KeyConditionExpression='userID = :userID',
           ExpressionAttributeValues={':userID':{"S":userID}})
    if response['Count'] > 0:
       return response
    else:
       return []

def addUserGroup(client, userID, groupID):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_UserGroup',
        Key={'groupID':{'S':groupID},
             'userID':{'S':userID}},
        AttributeUpdates={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
    )


######################################################################
# Table: MMCM_News
######################################################################
def postUserRelationNews(client, params, arrRelations, isNewRelation):
   if isNewRelation:
       params['action']='newUserRelation'
   else:
       params['newsAction']='updateUserRelation'
   params['list']=arrRelations
   response = boto3.client('lambda').invoke(
      FunctionName='MMCM_Private_News',
      Payload=json.dumps(params))


######################################################################
# Table: MMCM_Media
######################################################################
def addMedia(client, params):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_Media',
        Key={'mediaID':{'S':params['mediaID']}},
        UpdateExpression= "set creationDate = if_not_exists(creationDate, :time),"
           "s3BucketName = if_not_exists(s3BucketName, :s3BucketNameExpression),"
           "mediaType = if_not_exists(mediaType, :typeExpression),"
           "lastModifiedDate = :time "
           "ADD userArray :user",
        ExpressionAttributeValues= {':time':{"N":epoch_time},
           ':s3BucketNameExpression':{"S":params['s3BucketName']},
           ':typeExpression':{"S":params['type']},
           ':user':{"SS":[params['userID']]}}
        )
    # client.update_item(TableName='MMCM_Media',
    #     Key={'mediaID':{'S':params['mediaID']}},
    #     AttributeUpdates={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
    #                       "s3BucketName":{"Action":"PUT","Value":{"S":params['s3BucketName']}},
    #                       #"userArray":{"Action":"ADD","Value":{"SS":params['userArray']}},
    #                       "type":{"Action":"PUT","Value":{"S":params['type']}},
    #                       "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
    # )

def removeMedia(client, params):
    client.delete_item(TableName='MMCM_Media',
        Key={'mediaID':{'S':params['mediaID']}}
    )




######################################################################
# Table: MMCM_MediaTag
######################################################################
def addMediaTag(client, params):
    epoch_time = str(time.time())
    client.update_item(TableName='MMCM_MediaTag',
        Key={'groupID':{'S':params['mediaID']},
             'tagID':{'S':params['tag']}},
        AttributeUpdates={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "userIDAuthor":{"Action":"PUT","Value":{"S":params['userIDAuthor']}},
                          "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
    )


######################################################################
# Table: MMCM_UserMedia
######################################################################
def addUserMedia(client, params):
    epoch_time = str(time.time())
    attributes={"creationDate":{"Action":"PUT","Value":{"N":epoch_time}},
                 "tagArray":{"Action":"PUT","Value":{"SS":params['tagArray']}},
                 "lastModifiedDate" :{"Action":"PUT","Value":{"N":epoch_time}}}
    if 'caption' in params.keys():
       attributes["caption"] = {"Action":"PUT","Value":{"S":params['caption']}}
    if 'userArray' in params.keys():
       attributes["userArray"] = {"Action":"PUT","Value":{"SS":params['userArray']}}
    client.update_item(TableName='MMCM_UserMedia',
        Key={'userID':{'S':params['userID']},
             'mediaID':{'S':params['mediaID']}},
        AttributeUpdates=attributes
    )


def removeUserMedia(client, params):
   key={'userID':{'S':params['userID']},
      'mediaID':{'S':params['mediaID']}},
   item = retrieveRecord(client, 'MMCM_UserMedia', key)
   client.delete_item(TableName='MMCM_UserMedia', Key=key)
   return item['tagArray']['SS']


######################################################################
# Table: MMCM_UserTag
######################################################################
def addUserTag(client, params):
   epoch_time = str(time.time())
   client.update_item(TableName='MMCM_UserTag',
       Key={'userID':{'S':params['userID']},
            'tagID':{'S':params['tag']}},
       UpdateExpression="set creationDate = if_not_exists(creationDate, :time),"
          "lastModifiedDate = :time "
          "add mediaArray :media",
       ExpressionAttributeValues={':time':{"N":epoch_time}, ":media":{"SS":[params['mediaID']]}}
   )

def removeUserTag(client, params):
   key={'userID':{'S':params['userID']},
        'tagID':{'S':params['tag']}},
   item = retrieveRecord(client, 'MMCM_UserTag', key)
   if len(item['mediaArray']['SS']) <= 1:
      client.delete_item(TableName='MMCM_UserTag', Key=key)
   else:
      epoch_time = str(time.time())
      client.update_item(TableName='MMCM_UserTag',
          Key=key,
          UpdateExpression = "SET lastModifiedDate = :time "
                             "DELETE mediaArray :media",
          ExpressionAttributeValues={':time':{"N":epoch_time}, ":media":{"SS":[params['mediaID']]}}
      )


######################################################################
# General API
######################################################################
def addProfilePicture(client, params):
   params['type']='image'
   addMedia(client, params);
   addUserMedia(client, params)
   for tag in params['tagArray']:
      params['tag'] = tag
      addUserTag(client, params)
   return "200"


def removeMediaReferences(client, params):
   # arrNew.remove(item['userIDRelation']['S'])
   params['type']='image'
   removeMedia(client, params);
   tagArray = removeUserMedia(client, params)
   for tag in tagArray:
      params['tag'] = tag
      removeUserTag(client, params)
   return "200"


def retrieveFriends(client, params):
    userList = []
    isVerified = False
    allUserRelations = getAllUserRelations(client, params['userID'])
    if params['friendsForUserID'] == params['userID']:
       isVerified = True
    else:
       for relation in allUserRelations:
          if relation['userIDRelation']['S'] == params['friendsForUserID']:
             if relation['type']['N'] == "1": #relation is of type friend
                isVerified = True
    if (isVerified):
       allUserRelations = getAllUserRelations(client, params['friendsForUserID'])
       for relation in allUserRelations:
          if relation['type']['N'] == "1": #relation is of type friend
             item = retrieveRecord(client, 'MMCM_User', {'userID':{'S':relation['userIDRelation']['S']}})
             user = {"firstName":item['first_name']['S'],
                     "lastName":item['last_name']['S'],
                     "fullName":item['name']['S'],
                     "userID":item['userID']['S'],
                     "gender":item['gender']['S'],
                     "relationshipStatus":item['relationshipStatus']['S'],
                     "lookingFor":item['lookingFor']['S'],
                     "creationDate":relation['creationDate']['N'],
                     "imageS3Key":item['imageS3Key']['S'] }
             userList.append(user)
    return userList

def retrieveTagsForUserID(client, params):
   KeyConditionExpression='userID = :userID'
   ExpressionAttributeValues={':userID':{"S":params['forUser']}}
   return retrieveWithExpression(client, 'MMCM_UserTag', KeyConditionExpression, ExpressionAttributeValues)


def retrieveMediaForTag(client, params):
   key={'userID':{'S':params['userID']},
        'tagID':{'S':params['tag']}}
   return retrieveRecord(client, 'MMCM_UserTag', key)


def retrieveGroupData(client, params):
   allUserGroups = getAllUserGroups(client, params['userID'])
   groupList = []
   if allUserGroups['Count'] > 0:
      for userGroup in allUserGroups['Items']:
         groupItem = retrieveGroup(client, userGroup['groupID']['S'])
         returnVal = {"name":groupItem['name']['S'],
                      "memberCount":groupItem['memberCount']['N'],
                      "singlesCount":groupItem['singlesCount']['N'],
                      "groupID":groupItem['groupID']['S'],
                      "creationDate":userGroup['creationDate']['N'] }
         groupList.append(returnVal)
   return groupList


def retrieveGroupUsers(client, params):
   groupUsers = dict()
   returnVal = dict()
   userList = []
   if params['exclusiveStartKey'] == '0':
       groupUsers = client.query(TableName='MMCM_GroupUser',
          Limit=params['limit'],
          KeyConditionExpression='groupID = :groupID',
          ExpressionAttributeValues={':groupID':{"S":params['groupID']}})
   else:
       groupUsers = client.query(TableName='MMCM_GroupUser',
          # ExclusiveStartKey={ 'groupID':{"S":params['groupID']},
          #                     'userID':{"S":params['exclusiveStartKey']}},
          ExclusiveStartKey=params['exclusiveStartKey'],
          Limit=params['limit'],
          KeyConditionExpression='groupID = :groupID',
          ExpressionAttributeValues={':groupID':{"S":params['groupID']}})
   if groupUsers['Count'] > 0:
      for groupUser in groupUsers['Items']:
         item = retrieveRecord(client, 'MMCM_User', {'userID':{'S':groupUser['userID']['S']}})
         user = {"firstName":item['first_name']['S'],
                 "lastName":item['last_name']['S'],
                 "fullName":item['name']['S'],
                 "userID":item['userID']['S'],
                 "gender":item['gender']['S'],
                 "relationshipStatus":item['relationshipStatus']['S'],
                 "lookingFor":item['lookingFor']['S'],
                 "creationDate":groupUser['creationDate']['N'],
                 "imageS3Key":item['imageS3Key']['S'] }
         userList.append(user)
      if 'LastEvaluatedKey' in groupUsers:
         returnVal['LastEvaluatedKey'] = groupUsers['LastEvaluatedKey']
      returnVal['userList'] = userList
      return returnVal
   else:
      return returnVal


def retrieveUser(client,params):
   item = retrieveRecord(client, 'MMCM_User', {'userID':{'S':params['userIDToRetrieve']}})

   returnVal = {"firstName":item['first_name']['S'],
                "lastName":item['last_name']['S'],
                "fullName":item['name']['S'],
                "userID":item['userID']['S'],
                "imageS3Key":item['imageS3Key']['S'] }

   return returnVal


def getUserRelationType(client, params):
    record = getUserRelation(client, params['userID'], params['userIDRelation'])
    return record["type"]["N"]

######################################################################
# General Utility
######################################################################
def retrieveWithExpression(client, tableName, keyCondition, expressionAttributeValues):
    response = client.query(TableName=tableName,
           KeyConditionExpression=keyCondition,
           ExpressionAttributeValues=expressionAttributeValues)
    if response['Count'] > 0:
       return response['Items']
    else:
       return []

def retrieve(client, tableName, key, retrieveType):
    try:
       response = client.get_item(TableName=tableName,
             Key=key)
    except ClientError as e:
       return {'sError':'ClientError: MPL_GUI'}
    else:
       if retrieveType in response.keys():
          return response[retrieveType]
       return {'sError':'no results'}

def retrieveRecord(client, tableName, key):
    return retrieve(client, tableName, key, 'Item')

def retrieveRecords(client, tableName, key):
    return retrieve(client, tableName, key, 'Items')

def updateTable(client, tableName, key, attributes):
    attributes["lastModifiedDate"] = {"Action":"PUT","Value":{"N":str(time.time())}}
    client.update_item(TableName=tableName,
        Key=key,
        AttributeUpdates=attributes
    )


######################################################################
# OLD / UNUSED / EXAMPLE
######################################################################
# def retrieveFriends(client, params):
#    params['newsAction']='retrieveFriends'
#    response = boto3.client('lambda').invoke(
#          FunctionName='MMCM_Private_News',
#          Payload=json.dumps(params))
#    print(response)

#def retrieveFriends(client, params):
#   myDict = {'Key' : 'Value', 'one' : 'one', 'two' : 'too'}
#   myDict2 = {'second' : 'dictionary'}
#   myDict3 = {'third' : 'attempt'}
#   myList = [myDict,myDict2,myDict3]
#   return myList

#    allUserRelationsDump = getAllUserRelations(client, params):
#    count = allUserRelationsDump['Count']
#    if count > 0:
#       existingRelations = allUserRelationsDump['Items']
#       for item in existingRelations:
#          if item['userIDRelation']['S'] in arrNew:
#             arrNew.remove(item['userIDRelation']['S'])
#             if item['type']['N'] == 2:
#                # relation is restricted - update existing relation
#                arrUpdate.add(item['userIDRelation']['S'])


# Old DynamoDB Policy
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "dynamodb:BatchGetItem",
#                 "dynamodb:GetItem",
#                 "dynamodb:PutItem",
#                 "dynamodb:Query",
#                 "dynamodb:UpdateItem"
#             ],
#             "Resource": [
#                 "arn:aws:dynamodb:us-east-1:993974096162:table/MMCM_User"
#             ]
#         }
#     ]
# }
