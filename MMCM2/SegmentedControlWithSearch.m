//
//  SegmentedControlWithSearch.m
//  MMCM2
//
//  Created by Richard Montricul on 12/14/16.
//  Copyright © 2016 Shadow Prodigy. All rights reserved.
//

#import "SegmentedControlWithSearch.h"
#import "ViewUtilities.h"

@implementation SegmentedControlWithSearch
static UIView *containerFrame;
   static UIView *segmentedControlFrame;
   static UIView *searchFrame;
      static UIView *searchTextFieldView;
         static UIImageView *searchIcon;

static int segmentedControlHeight = 40;
static int margin = 20;
static int expansionFrameHeight = 75;

static int heightCollapsed;
static int heightExpanded;

static id delegate;

- (id)init:(id)Delegate;
{
   self = [super init];
   delegate = Delegate;
   heightCollapsed = segmentedControlHeight;
   heightExpanded = segmentedControlHeight + expansionFrameHeight + margin;
   self.frame = CGRectMake(0,0,screenWidth,heightCollapsed);
   [self setupSegmentedControlFrame];
   [self setupSearchFrame];
   _isExpanded = false;
   self.backgroundColor = [UIColor whiteColor];
   return self;
}

- (void)setupSegmentedControlFrame;
{ // Includes the segmentedControl and the round search button
   segmentedControlFrame = [[UIView alloc] init];
   segmentedControlFrame.frame = CGRectMake(0,0,screenWidth,segmentedControlHeight);
   [self setupSegmentedControl];
   [self setupSearchButton];
   [self addSubview:segmentedControlFrame];
}


- (void)setupSegmentedControl;
{
   NSArray *segmentTitles = @[@"", @""];
   _segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
   [_segmentedControl addTarget:self action:@selector(selectSegment:) forControlEvents:UIControlEventValueChanged];
   [ViewUtilities setWidth:0.9*segmentedControlFrame.frame.size.width forView:_segmentedControl];
   _segmentedControl.tintColor = themeColor;
   _segmentedControl.center = segmentedControlFrame.center;
   [segmentedControlFrame addSubview:_segmentedControl];

   _segmentedControl.selectedSegmentIndex = 0;
   _selectedSegmentIndex = 0;
}

- (void)setSegmentTitles:(NSArray *)titles;
{
   [_segmentedControl setTitle:titles[0] forSegmentAtIndex:0];
   [_segmentedControl setTitle:titles[1] forSegmentAtIndex:1];
}

- (void)selectSegment:(UISegmentedControl *)segment;
{
   _selectedSegmentIndex = _segmentedControl.selectedSegmentIndex;
}

- (void)setupSearchButton;
{
   CGFloat size = 40;
   _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
   [_searchButton addTarget:self action:@selector(searchClicked) forControlEvents:UIControlEventTouchUpInside];
   [_searchButton setBackgroundColor: themeColor];
   _searchButton.frame = CGRectMake(0,0,size,size);
   _searchButton.layer.borderWidth = 1;
   _searchButton.layer.borderColor = [UIColor whiteColor].CGColor;
   _searchButton.layer.cornerRadius = size/2;
   _searchButton.layer.masksToBounds = YES;
   _searchButton.center = segmentedControlFrame.center;
   UIImage *btnImage = [UIImage imageNamed:@"SearchIcon"];
   [_searchButton setImage:btnImage forState:UIControlStateNormal];
   [segmentedControlFrame addSubview:_searchButton];
}

- (void)searchClicked;
{
   int alpha = 1 - searchFrame.alpha;
   int topSize;
   if (alpha == 1) {
      topSize = heightExpanded;
      _isExpanded = true;
   }
   else {
      topSize = heightCollapsed;
      _isExpanded = false;
   }
   [UIView animateWithDuration:0.1
      delay:0.0
      options: UIViewAnimationOptionCurveEaseOut
      animations:^{ 
         searchFrame.alpha = alpha;
         [ViewUtilities setHeight:topSize forView: self];
         [self controlIsExpanding];
      } 
      completion:^(BOOL finished){
         [self controlHasExpanded];
      }
   ];
}

- (void)controlIsExpanding;
{
}
- (void)controlHasExpanded;
{
}

- (void)setupSearchFrame;
{
   searchFrame = [[UIView alloc] init];
   searchFrame.frame = CGRectMake(
         0,
         segmentedControlHeight+margin,
         screenWidth,
         expansionFrameHeight);
   searchFrame.alpha = 0.0f;

   [self setupSearchTextField];
   [self setupSortButton];

   [self addSubview:searchFrame];
}


- (void)setupSearchTextField;
{
   CGFloat textFieldWidth = .8*screenWidth;
   searchTextFieldView = [[UIView alloc] init];
   searchTextFieldView.frame = CGRectMake(.1*screenWidth,0,textFieldWidth, 28); 
   searchTextFieldView.layer.borderWidth = 1;
   searchTextFieldView.layer.borderColor = darkGray.CGColor;;
   searchTextFieldView.layer.cornerRadius = 5.0;
   searchTextFieldView.layer.masksToBounds = YES;

   UIImage *image = [[UIImage imageNamed:@"SearchIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
   searchIcon = [[UIImageView alloc] initWithImage:image];
   searchIcon.frame = CGRectMake(8,8,14,14);
   searchIcon.contentMode = UIViewContentModeScaleAspectFill;
   [searchIcon setTintColor:darkGray];
   [searchTextFieldView addSubview:searchIcon];

   _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(34,0, textFieldWidth - 34 , 28)];
   _searchTextField.delegate = delegate;
   _searchTextField.font = [UIFont systemFontOfSize:15];
   _searchTextField.returnKeyType = UIReturnKeyDone;
   _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
   _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
   _searchTextField.borderStyle = UITextBorderStyleNone;
   _searchTextField.backgroundColor = [UIColor clearColor];
   [_searchTextField addTarget:self 
      action:@selector(textFieldDidChange:)
      forControlEvents:UIControlEventEditingChanged];
   [searchTextFieldView addSubview:_searchTextField];

   [searchFrame addSubview:searchTextFieldView];
}

-(void)textFieldDidChange :(UITextField *) textField{
   NSLog(@"textFieldDidChange");
}

- (BOOL) textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldCleared");
    return YES;
}


- (void)setupSortButton;
{
   _sortButton = [[SortButton alloc] init];
   [ViewUtilities setXY:
      CGPointMake(
         .9*screenWidth - _sortButton.frame.size.width,
         CGRectGetMaxY(searchTextFieldView.frame) + 20
      )
      forView:_sortButton ];
   [searchFrame addSubview:_sortButton];
   [_sortButton addTarget:self action:@selector(sortButtonClicked:) forControlEvents:UIControlEventEditingChanged];
}
- (void)setSortValues:(NSArray *)SortValues;
{
   _sortButton.sortValues = SortValues;
   [ViewUtilities setXY:
      CGPointMake(
         .9*screenWidth - _sortButton.frame.size.width,
         CGRectGetMaxY(searchTextFieldView.frame) + 20
      )
      forView:_sortButton ];
}

- (void)sortButtonClicked:(SortButton *)sender;
{
   _sortIndex = sender.index;
   [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
