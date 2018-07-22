//
//  Result.m
//  MMCM2
//
//  Created by Richard Montricul on 9/6/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "Result.h"

@implementation Result

- (id)init 
{
   if (self = [super init]) {
      _success = nil;
      _error = nil;
      _exception = nil;
   }
   return self;
}

- (void)setSuccess:(NSDictionary *)message;
{
   if (message && !_exception && !_error)
      _success = [self setMessage:message forResult:_success];
}

- (void)setError:(NSDictionary *)message;
{
   if (message && !_exception) {
      _success = nil;
      _error = [self setMessage:message forResult:_error];
   }
}

- (void)setException:(NSDictionary *)message;
{
   if (message) {
      _success = nil;
      _error = nil;
      _exception = [self setMessage:message forResult:_exception];
   }
}

- (id)setMessage:(NSDictionary *)message forResult:(NSDictionary *)result;
{
   if (!message) {
      return result;
   }
   // if (result) {
   NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:result];
   [mDic addEntriesFromDictionary:message];
   return [NSDictionary dictionaryWithDictionary:mDic];
   // } else {
   //    return [NSDictionary dictionaryWithDictionary:message];
   // }
}

- (id)with:(Result *)result;
{
   [self setException:result.exception];
   [self setError:result.error];
   [self setSuccess:result.success];
   return self;
}
@end

