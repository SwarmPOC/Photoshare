//
//  User.h
//  MMCM2
//
//  Created by Richard Montricul on 8/23/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *relationshipStatus;
@property (strong, nonatomic) NSString *lookingFor;
@property (strong, nonatomic) NSString *imageS3Key;
@property (strong, nonatomic) NSString *creationDate;

@property (strong, nonatomic) UIImage *image;

@property BOOL isFirstDegreeFriend;


- (id)initWithDictionary:(NSDictionary *)dic;


@end
