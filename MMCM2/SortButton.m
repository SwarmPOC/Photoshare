//
//  SortButton.m
//  MMCM2
//
//  Created by Richard Montricul on 5/8/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

//
//  Recommended Size: width = 108, y = 28
//
#import "SortButton.h"
#import "ViewUtilities.h"

@implementation SortButton

- (id)init;
{
   self = [super init];
   _sortValues = @[@"sort: recent",@"sort: alphabetical"]; 
   self.index = 0;
   self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
   self.titleLabel.numberOfLines = 1;
   [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   self.backgroundColor = [UIColor clearColor];
   self.titleLabel.font = [UIFont systemFontOfSize:12];
   [self addTarget:self action:@selector(_sortButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   [self setSortValues:@[@"sort: recent",@"sort: alphabetical"]]; 
   return self;
}


- (void)setSortButtonText;
{
   [UIView animateWithDuration:0.2
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         self.alpha = 0;
      } 
      completion:^(BOOL finished){
         [self setTitle:[_sortValues objectAtIndex:self.index] forState:UIControlStateNormal];
         [ViewUtilities fadeInView:self];
      }
   ];
}

- (void)setSortValues:(NSArray *)SortValues;
{
   _sortValues = SortValues;
   [self setSize];
   [self setSortButtonText];
}


- (void)_sortButtonClicked;
{
   self.index = ++self.index%[_sortValues count];
   [self setSortButtonText];
}


- (void)setSize;
{
   CGSize size = CGSizeMake(0,0);
   CGRect tempFrame;
   NSDictionary *attributes = @{NSFontAttributeName:self.titleLabel.font};
   for (NSString *str in _sortValues) {
      tempFrame.size = [str sizeWithAttributes:attributes];
      if (tempFrame.size.width > size.width) {
         size = tempFrame.size;
      }
   }
   CGRect frame = { {0,0}, {size.width, 40} };
   self.frame = frame;
}

@end
