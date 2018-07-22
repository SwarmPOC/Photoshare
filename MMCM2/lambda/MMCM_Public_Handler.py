#AWSLambdaFunction
#MMCM_Public_Handler
#import MMCM_Public_Login
import json
import boto3
import time
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    client = boto3.client('dynamodb')
    if event['action'] == 'addProfilePicture':
       return addProfilePicture(client, event)
    return {"uError":'verification error (1)'}

#def addProfilePicture(client, params):

    # ---------
    # media table - general media identification - doesn't have to be profile pictures, can be media
    # in a coovo and stuff:
    # ---------
    # mediaID (s3Key)
    #    s3BucketName
    #    creationDate
    #    lastModifiedDate
    #    type
    # 
    # ------------------
    # profileMedia table - all profile pictures/videos
    # ------------------
    # mediaID (s3Key)
    #    creationDate
    #    lastModifiedDate
    #    tagArray
    #    userArray
    #    convoID
    #
    # 
    # -------------
    # media.tag table - probably unused at this point
    # -------------
    # MediaID
    #    tagID
    #       creationDate
    #       lastModifiedDate
    #       userIDAuthor
    #       tagType
    # 
    #
    # --------------
    # user.media table - all media for a user
    # --------------
    # userID
    #    mediaID
    #       creationDate
    #       lastModifiedDate
    #
    #
    # --------------
    # user.tag table - all tags for a user...may need to rethink this
    # --------------
    # userID
    #    tagID
    #       creationDate
    #       lastModifiedDate
    #       media count
    #       mediaArray
    #       conversationCount (forum Post count)
    #       conversationArray (array of forum posts with this tag)
    #
------------------
user.userTag table - all usertags for a user - this includes all ppl that have been tagged to a
photo that i am also tagged in (not everyone is necessarily friends)
------------------
userID
   taggedUserID
      creationDate
      lastModifiedDate
      media count
      mediaArray

i will favorite  pics - i don't need to track this (for speed):- seems very unncessary at least in the beginning
my pics will have favorites - this is to be tracked so that i can pull up this list

my favorites
userID
    favoriteMediaID
      creationDate
      lastModifiedDate
      type - in case we expand this to other types
        0 - none (un favorited)
        1 - normal
        2 - TBD


all media of favorite type - i.e. i can pull up all media that has been unfavorited
userID
    favoriteTypeID (0 - unfavorited, 1 - normal, 2 - TBD, etc...)
      creationDate
      lastModifiedDate
      count
      mediaArray
        
all users that have favorited this media - i.e. i can pull up that 10 ppl like this pic and their
userID's
MediaID
    favoriteTypeID (0 - unfavorited, 1 - normal, 2 - TBD, etc...)
      creationDate
      lastModifiedDate
      count
      userArray



the whole upvote feature - may be delayed
