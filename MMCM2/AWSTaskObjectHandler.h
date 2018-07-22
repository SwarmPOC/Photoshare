//
//  AWSTaskObjectHandler.h
//  MMCM2
//
//  Created by Richard Montricul on 11/22/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWSTaskObjectHandler : NSObject
- (id)initWithDictionary:(id)task;
- (id)initWithArray:(id)task;
- (NSInteger)getIntValueFor:(NSString *)key;
- (NSString *)getStringValueFor:(NSString *)key;

@end
