//
//  MMCMIdentityProvider.h
//  MMCM2
//
//  Created by Richard Montricul on 8/6/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Frameworks
   #import <AWSCore/AWSCore.h>

@interface MMCMIdentityProvider : NSObject <AWSIdentityProviderManager>
@property NSString *token;

- (id)init:(NSString *)token;

@end
