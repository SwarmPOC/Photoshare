#AWSLambdaFunction
#MMCM_Private_RegistrationCodes
import json
import boto3
import time
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    client = boto3.client('dynamodb')
    if event['registrationCodesAction'] == 'createNewUserCode':
       return createNewUserCode(client, event)


def createNewUserCode(client,params):
    # check to see that code exists already or not
    epoch_time = str(time.time())
    code = ""
    codeFound = False
    rounds = 0

    while not codeFound:
       rounds = rounds + 1
       code=generateNum()
       codeRecord = retrieveCodeRecord(client, code)
       if 'sError' in codeRecord.keys():
          codeFound=True
    client.update_item(TableName='MMCM_RegistrationCode',
        Key={'codeID':{'S':code}},
        AttributeUpdates={"creationDate"    :{"Action":"PUT","Value":{"N":epoch_time}},
                          "lastModifiedDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "expireDate"      :{"Action":"PUT","Value":{"N":"0"}},
                          "description"     :{"Action":"PUT","Value":{"S":"User Code"}},
                          "type"            :{"Action":"PUT","Value":{"N":"1"}},
                          "link"            :{"Action":"PUT","Value":{"S":params['userID']}},
                          "rounds"          :{"Action":"PUT","Value":{"N":str(rounds)}},
                          "active"          :{"Action":"PUT","Value":{"N":"1"}}}
    )
    client.update_item(TableName='MMCM_User',
        Key={'userID':{'S':params['userID']}},
        AttributeUpdates={"lastModifiedDate":{"Action":"PUT","Value":{"N":epoch_time}},
                          "inviteCode"      :{"Action":"PUT","Value":{"S":code}}}
    )

def generateNum():
    cTime = float(time.time())
    num = (int(cTime*100) * 3874204899) % 10000000000
    return encode(num)

def encode(num):
    #alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    alphabet = "123456789ABCDEFGHIJKLMNPQRSTUVWXYZ"
    """Encode a positive number in Base X

    Arguments:
    - `num`: The number to encode
    - `alphabet`: The alphabet to use for encoding
    """
    if num == 0:
        return alphabet[0]
    arr = []
    base = len(alphabet)
    while num:
        num, rem = divmod(num, base)
        arr.append(alphabet[rem])
    arr.reverse()
    return ''.join(arr)

def retrieveCodeRecord(client, code):
    try:
       response = client.get_item(TableName='MMCM_RegistrationCode',
             Key={'codeID':{'S':code}})
    except ClientError as e:
       return {'sError':'ClientError: MPL_GUI'}
    else:
       if 'Item' in response.keys():
          return response['Item']
       return {'sError':'code does not exist'}

def remoteUpdate(client, params, function, partitionKeyValue, sortKeyValue, attributes, key, keyType, value):
    params['action']='updateField'
    params['partitionKey'] = partitionKey
    params['sortKeyValue'] = sortKeyValue
    params['attributes'] = attributes
    params['key'] = key
    params['keyType'] = keyType
    params['value'] = value
    response = boto3.client('lambda').invoke(
          FunctionName=function,
          Payload=json.dumps(params))
    return

def updateField(client, params):
    try:
       response = client.get_item(TableName='MMCM_RegistrationCode',
                                  Key={'codeID':{'S':params['partitionKey']}})
    except ClientError as e:
       return
    else:
       if 'Item' in response.keys():
          attributes = params['attributes']
          if attributes is None:
             attributes = {params['key']:{"Action":"PUT","Value":{params['keyType']:params['value']}}}
          updateLocalTable(client, params['partitionKeyValue'], attributes)

def updateLocalTable(client, partitionKeyValue, attributes):
    attributes["lastModifiedDate"] = {"Action":"PUT","Value":{"N":str(time.time())}}
    client.update_item(TableName='MMCM_RegistrationCode',
        Key={'code':{'S':partitionKeyValue}},
        AttributeUpdates=attributes
    )
