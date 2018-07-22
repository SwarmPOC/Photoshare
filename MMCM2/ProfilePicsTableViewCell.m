//
//  ProfilePicsTableViewCell.m
//  MMCM2
//
//  Created by Richard Montricul on 12/19/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "ProfilePicsTableViewCell.h"

@implementation ProfilePicsTableViewCell
static UIScrollView *scrollView;

- (id)init:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
{
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   [self setupViews];
   return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupViews;
{
   [self setupScrollView];
}

- (void)setupScrollView;
{
   //each element is 60width + 5 margin
   //initial left margin is 19px
   scrollView = [[UIScrollView alloc] init];
   scrollView.frame = CGRectMake(0,0,0,80);
   scrollView.delegate = self;
   scrollView.backgroundColor = [UIColor whiteColor];
   [self addSubview:scrollView];
}

- (void)setData:(NSArray *)data;
{
}


@end
