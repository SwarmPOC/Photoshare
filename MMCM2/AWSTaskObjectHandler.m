//
//  AWSTaskObjectHandler.m
//  MMCM2
//
//  Created by Richard Montricul on 11/22/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "AWSTaskObjectHandler.h"

@implementation AWSTaskObjectHandler
static NSDictionary *dic;
static NSDictionary *arr;

- (id)initWithDictionary:(id)task;
{
   if (self = [super init]) {
      dic = task;
   }
   return self;
}
- (id)initWithArray:(id)task;
{
   if (self = [super init]) {
      arr = task;
   }
   return self;
}

- (NSInteger)getIntValueFor:(NSString *)key;
{
   //NSDictionary *temp = [dic objectForKey:key];
   return [[[dic objectForKey:key] objectForKey:@"N"] intValue];
}
- (NSString *)getStringValueFor:(NSString *)key;
{
   //NSDictionary *temp = [dic objectForKey:key];
   return [[dic objectForKey:key] objectForKey:@"N"];
}

@end
