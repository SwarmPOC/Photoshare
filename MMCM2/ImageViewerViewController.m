//
//  ImageViewerViewController.m
//  MMCM2
//
//  Created by Richard Montricul on 3/6/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "ImageViewerViewController.h"

@interface ImageViewerViewController ()

@end

@implementation ImageViewerViewController
lockType zoomLock = MIN;
CGPoint point;
bool hasImage;
NSString *key;

UIView *upperShadow;
UIView *lowerShadow;
NSMutableArray *overlayArray;
static BOOL showingOverlay = true;
static CGFloat shadowAlpha = 0.6;

EDITTYPE editType;


- (BOOL)shouldAutorotate
{
   return YES;
}

- (id)initWithKey:(NSString *)Key editType:(EDITTYPE)EditType;
{
   self = [super init];
   hasImage = NO;
   key = Key;
   editType = EditType;
   return self;
}
- (id)initWithImage:(UIImage *)image;
{
   self = [super init];
    if (self) 
      self.image = image;
   hasImage = YES;
   return self;
}


- (void)setupViews;
{
   if (hasImage) {
      [self initScrollView];
      [self initImageView];
      [self setupOverlay];
      self.scrollView.maximumZoomScale = 1.5f;
      point = CGPointMake(0,0);
   }
   else {
      self.view.backgroundColor = [UIColor blackColor];
      overlayArray = [[NSMutableArray alloc] init];
      [self loadImage];
   }
}


- (void)loadImage;
{
   [server downloadFullImage:key withCompletionBlock:^(UIImage *image){
      hasImage = YES;
      self.image = image;
      [self setupViews];
      [self adjustScrollView];
   }];
}


- (void)viewWillAppear:(BOOL)animated 
{
   [super viewWillAppear:animated];
   // [self adjustScrollView];
}


- (void) viewWillDisappear:(BOOL)animated {
    // NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    // [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [super viewWillDisappear:animated];
}

- (void)initScrollView;
{
   self.scrollView = [[UIScrollView alloc] init];
   self.scrollView.delegate = self;
   CGRect screenRect = [[UIScreen mainScreen] bounds];
   self.scrollView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=screenRect.size};
   [self.view addSubview:self.scrollView];
   [self initTapGestures];
}


- (void)initImageView;
{
   self.imageView = [[UIImageView alloc] initWithImage:self.image];
   self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.image.size};
   self.imageView.contentMode = UIViewContentModeScaleAspectFill;
   [self.scrollView addSubview:self.imageView];
   self.scrollView.contentSize = self.image.size;
}


- (void)setupOverlay;
{
   [self setupUpperShadow];
   [self setupExitButton];
   if (editType != EDITTYPE_NONE)
      [self setupLowerShadow];
}

- (void)setupUpperShadow;
{
   upperShadow = [[UIView alloc] init];
   upperShadow.backgroundColor = [UIColor blackColor];
   upperShadow.alpha = shadowAlpha;
   // CAGradientLayer *gradient = [CAGradientLayer layer];
   // gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
   // [upperShadow.layer insertSublayer:gradient atIndex:0];
   [self adjustShadows];
   [self.view addSubview:upperShadow];
}

- (void)setupExitButton;
{
   _exitButton = [[UIButton alloc] init];
   _exitButton.frame = CGRectMake(20, 15, 40, 40);
   [_exitButton setTitle:@"exit" forState:UIControlStateNormal];
   [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   [_exitButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
   _exitButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
   [_exitButton sizeToFit];
   _exitButton.backgroundColor =[UIColor blueColor];
   _exitButton.alpha = 1.0f;
   [self.view addSubview:_exitButton];
   [overlayArray addObject:_exitButton];
}


- (void)setupLowerShadow;
{
   lowerShadow = [[UIView alloc] init];
   lowerShadow.backgroundColor = [UIColor blackColor];
   lowerShadow.alpha = shadowAlpha;
   // CAGradientLayer *gradient = [CAGradientLayer layer];
   // gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
   // [lowerShadow.layer insertSublayer:gradient atIndex:0];
   [self adjustShadows];
   [self.view addSubview:lowerShadow];
}

- (void)initTapGestures;
{
   UITapGestureRecognizer *oneFingerTapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self
      action:@selector(scrollViewOneFingerTapped:)];
   oneFingerTapRecognizer.cancelsTouchesInView = NO;
   oneFingerTapRecognizer.numberOfTapsRequired = 1;
   oneFingerTapRecognizer.numberOfTouchesRequired = 1;
   [self.view addGestureRecognizer:oneFingerTapRecognizer];

   UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self
      action:@selector(scrollViewDoubleTapped:)];
   doubleTapRecognizer.numberOfTapsRequired = 2;
   doubleTapRecognizer.numberOfTouchesRequired = 1;
   [self.scrollView addGestureRecognizer:doubleTapRecognizer];
 
   UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self
      action:@selector(scrollViewTwoFingerTapped:)];
   twoFingerTapRecognizer.numberOfTapsRequired = 1;
   twoFingerTapRecognizer.numberOfTouchesRequired = 2;
   [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];

   [oneFingerTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
}


- (CGSize)getFullScreenSize;
{
   float factor;
   int width;
   int height;
   if (self.image.size.width > screenWidth)
   {
      factor = screenWidth/self.image.size.width;
      width = screenWidth;
      height = self.image.size.height * factor;
   }
   else 
   {
      factor = screenHeight/self.image.size.height;
      width = self.image.size.width * factor;
      height = screenHeight;
   }
   return CGSizeMake(width, height);
}


- (void)centerScrollViewContents 
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
 
    if (contentsFrame.size.width < boundsSize.width) 
       contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    else
       contentsFrame.origin.x = 0.0f;
 
    if (contentsFrame.size.height < boundsSize.height)
       contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    else
       contentsFrame.origin.y = 0.0f;
 
    self.imageView.frame = contentsFrame;
}



- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
   [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
      // Code here will execute before the rotation begins.
      // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
   point = [self getCenterPoint];
   [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      // Place code here to perform animations during the rotation.
      // You can pass nil or leave this block empty if not necessary.
      // values obtained here pertaining to screensize and rotation are the same as those
      // post rotation
      [self adjustScrollView];
      [self adjustShadows];

   } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      // Code here will execute after the rotation has finished.
   }];
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer 
{
   if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale)
      [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
   else
   {
      CGPoint pointInView = [recognizer locationInView:self.imageView];
      CGFloat newZoomScale = self.scrollView.zoomScale * 4.0f;
      newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
      CGSize scrollViewSize = self.scrollView.bounds.size;
      CGFloat w = scrollViewSize.width / newZoomScale;
      CGFloat h = scrollViewSize.height / newZoomScale;
      CGFloat x = pointInView.x - (w / 2.0f);
      CGFloat y = pointInView.y - (h / 2.0f);
      CGRect rectToZoomTo = CGRectMake(x, y, w, h);
      [self.scrollView zoomToRect:rectToZoomTo animated:YES];
   }
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer 
{
   // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
   CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
   newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
   [self.scrollView setZoomScale:newZoomScale animated:YES];
}


- (void)scrollViewOneFingerTapped:(UITapGestureRecognizer*)recognizer 
{
   // CGPoint location = [recognizer locationInView:[recognizer.view superview]];

   [UIView animateWithDuration:0.1
      delay:0.0
      options: UIViewAnimationOptionCurveEaseIn
      animations:^{ 
         if (showingOverlay) {
            for (UIView *view in overlayArray) {
               view.alpha = 0.0f;
            }
            upperShadow.alpha = 0.0f;
            lowerShadow.alpha = 0.0f;
         }
         else {
            for (UIView *view in overlayArray) {
               view.alpha = 1.0f;
            }
            upperShadow.alpha = shadowAlpha;
            lowerShadow.alpha = shadowAlpha;
         }
         showingOverlay = !showingOverlay;
      } 
      completion:^(BOOL finished){
      }
   ];
}


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
   if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale)
      zoomLock = MIN;
   else if (self.scrollView.zoomScale == self.scrollView.maximumZoomScale)
      zoomLock = MAX;
   else
      zoomLock = NONE;
    [self centerScrollViewContents];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}


- (void)adjustScrollView
{
   CGRect screenRect = [[UIScreen mainScreen] bounds];
   self.scrollView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=screenRect.size};
   CGRect scrollViewFrame = self.scrollView.frame;
   CGFloat scaleHeight = scrollViewFrame.size.height / self.image.size.height;
   CGFloat scaleWidth = scrollViewFrame.size.width / self.image.size.width;
   // CGFloat imageWidth = _image.size.width;
   // CGFloat imageHeight = _image.size.height;
   CGFloat minScale = MIN(scaleWidth, scaleHeight);
   self.scrollView.minimumZoomScale = minScale;
 
   if (zoomLock == MIN)
     self.scrollView.zoomScale = minScale;
   else if(zoomLock == MAX)
      self.scrollView.zoomScale = self.scrollView.maximumZoomScale;
   [self centerScrollViewContents];
   [self.scrollView setContentOffset:[self getOffset:point] animated:YES];
}


- (void)adjustShadows;
{
   CGRect screenRect = [[UIScreen mainScreen] bounds];
   // Upper Shadow
   upperShadow.frame = CGRectMake(0,0, screenRect.size.width, CGRectGetMaxY(_exitButton.frame) + _exitButton.frame.origin.y);
   //[upperShadow.layer.sublayers objectAtIndex:0].frame = upperShadow.bounds;

   // Lower Shadow
   if (editType == EDITTYPE_FULL) {
      if (screenRect.size.width > screenRect.size.height)
         lowerShadow.frame = CGRectMake(0,screenRect.size.height - 120, screenRect.size.width, 120);
      else
         lowerShadow.frame = CGRectMake(0,screenRect.size.height - 240, screenRect.size.width, 240);
      //[lowerShadow.layer.sublayers objectAtIndex:0].frame = lowerShadow.bounds;
   }
   else if (editType == EDITTYPE_PARTIAL) { //Non-Friend
   }
}



- (CGPoint)getCenterPoint;
{
   CGFloat x;
   CGFloat y;
   CGRect screenRect = [[UIScreen mainScreen] bounds];

   x = self.scrollView.contentOffset.x + (screenRect.size.width/2);
   x = x/self.imageView.frame.size.width;

   y = self.scrollView.contentOffset.y + (screenRect.size.height/2);
   y = y/self.imageView.frame.size.height;

   if ( (screenRect.size.width) > self.imageView.frame.size.width )
      x = 0.5f;
   if ( (screenRect.size.height) > self.imageView.frame.size.height )
      y = 0.5f;
   return CGPointMake(x,y);
}

- (CGPoint)getOffset:(CGPoint)point;
{
   CGFloat x;
   CGFloat y;
   CGFloat xOffset;
   CGFloat yOffset;
   CGRect screenRect = [[UIScreen mainScreen] bounds];
   CGSize imSize = self.imageView.frame.size;

   x = point.x * imSize.width;
   xOffset = x - (screenRect.size.width/2);
   y = point.y * imSize.height;
   yOffset = y - (screenRect.size.height/2);

   if (xOffset < 0)
      xOffset = 0.0f;
   if (yOffset < 0)
      yOffset = 0.0f;
   return CGPointMake(xOffset,yOffset);
}


- (void)cancelButtonClicked;
{
   [self dismissViewControllerAnimated:NO completion:NULL];
}



@end
