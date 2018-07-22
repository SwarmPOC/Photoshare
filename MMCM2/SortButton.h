//
//  SortButton.h
//  MMCM2
//
//  Created by Richard Montricul on 5/8/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import <UIKit/UIKit.h>

// typedef NS_ENUM(NSInteger, SORTBUTTON_ANCHORSIDE)
// {
//    ANCHOR_LEFT = 0,
//    ANCHOR_RIGHT = 1
// };

@interface SortButton : UIButton

// @property (strong, nonatomic) SORTBUTTON_ANCHORSIDE anchorSide;
@property (strong, nonatomic) NSArray *sortValues;
@property NSInteger index;

@end
