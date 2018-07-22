//
//  Result.h
//  MMCM2
//
//  Created by Richard Montricul on 9/6/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Result : NSObject

@property (strong, nonatomic) NSDictionary *success;
@property (strong, nonatomic) NSDictionary *error;
@property (strong, nonatomic) NSDictionary *exception;

- (void)setSuccess:(NSDictionary *)message;
- (void)setError:(NSDictionary *)message;
- (void)setException:(NSDictionary *)message;
- (id)with:(Result *)result;

@end
