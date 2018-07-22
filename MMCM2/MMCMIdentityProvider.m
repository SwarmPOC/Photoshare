//
//  MMCMIdentityProvider.m
//  MMCM2
//
//  Created by Richard Montricul on 8/6/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "MMCMIdentityProvider.h"

@implementation MMCMIdentityProvider
- (id)init:(NSString *)token;
{
   self.token = token;
   return self;
}

- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins;
{
   return [AWSTask taskWithResult:@{AWSIdentityProviderFacebook:self.token}];
}
@end
