//
//  ProfilePhotoStreamView.m
//  MMCM2
//
//  Created by Richard Montricul on 2/19/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "ProfilePhotoStreamView.h"
#import "CameraRollCollectionViewCell.h"
#import "ImageViewerViewController.h"

@implementation ProfilePhotoStreamView {
   id delegate;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}


- (id)init:(NSString *)Tag photoArray:(NSArray *)array delegate:(id)Delegate;
{
   self = [super init];
   _streamTag = Tag;
   _photoArray = [[NSMutableArray alloc] initWithArray:array];
   delegate = Delegate;
   _thumbnailDictionary = [[NSMutableDictionary alloc] init];
   _lowerIndex = 0;
   self.frame = CGRectMake(0,0,screenWidth, 130);
   self.backgroundColor = [UIColor blueColor];
   [self setupViews];
   return self;
}

- (void)setupViews;
{
   [self reload];
   dispatch_async(dispatch_get_main_queue(), ^{
      [self setupLabel];
   });
}

- (void)setupCollectionView;
{
   UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
   [layout setItemSize:CGSizeMake(60, 80)];
   [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
   layout.minimumLineSpacing = 5;
   layout.minimumInteritemSpacing = 0;
   _collectionView = [[UICollectionView alloc] initWithFrame:
      CGRectMake(0,50,screenWidth, 80) collectionViewLayout:layout];
   _collectionView.backgroundColor = [UIColor orangeColor];
   _collectionView.delegate = self;
   _collectionView.dataSource = self;
   _collectionView.showsVerticalScrollIndicator = NO;
   _collectionView.allowsSelection = YES;
   [_collectionView registerClass:[CameraRollCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
   [self addSubview:_collectionView];
}

- (void)setupLabel;
{
   UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, screenWidth, 21)];
   label.textAlignment = NSTextAlignmentLeft;
   label.textColor = [UIColor blackColor];
   label.numberOfLines = 1;
   label.font = [UIFont systemFontOfSize: 18 weight:UIFontWeightRegular];
   label.text = [NSString stringWithFormat:@"#%@", _streamTag];
   [self addSubview:label];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
   if (_photoArray) {
      return _upperIndex + 1;
   }
   else return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
   NSString *identifier = @"cell";
   CameraRollCollectionViewCell *cell = (CameraRollCollectionViewCell*) [collectionView
      dequeueReusableCellWithReuseIdentifier:identifier
      forIndexPath:indexPath];
   if (cell == nil) {
      cell = [[CameraRollCollectionViewCell alloc] initWithFrame:CGRectMake(0,0,60,80)];
   }
   [cell setImageFromImage:nil];
   if (indexPath.row == _upperIndex) {
      if ([self raiseIndexLimit])
         [self pullThumbnails];
   }
   [cell setImageFromImage:[_thumbnailDictionary objectForKey:[_photoArray objectAtIndex:indexPath.row]]];
   return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   ImageViewerViewController *viewController = [[ImageViewerViewController alloc]
      initWithKey:[_photoArray objectAtIndex:indexPath.row]
      // XXX TODO
      // this needs to be checked
      editType:EDITTYPE_FULL];
      // XXX TODO

   //[super presentViewController:viewController];
   //[_delegate presentViewController:viewController animated:YES completion:nil];
   [(UIViewController *)delegate presentViewController:viewController animated:YES completion:nil];
}


- (void)reload;
{
   [server retrieveMediaForTag:_streamTag completionBlock:^(id result){
      NSDictionary *dic = [result objectForKey:@"mediaArray"];
      _photoArray = [dic objectForKey:@"SS"];
      if ([_photoArray count] - _lowerIndex > 50)
         _upperIndex = _lowerIndex + 49;
      else
         _upperIndex = [_photoArray count] - 1;
      if (!_collectionView) {
         dispatch_async(dispatch_get_main_queue(), ^{
            [self setupCollectionView];
         });
      }
      [self pullThumbnails];
   }];
}

 - (void)pullThumbnails;
{
   // for (int index = 0; index < _lowerIndex; index++) {
   //    if ([_thumbnailDictionary objectForKey:[_photoArray objectAtIndex:index]]) {
   //       [_thumbnailDictionary removeObjectForKey:[_photoArray objectAtIndex:index]];
   //    }
   // }
   // if (_upperIndex < [_photoArray count] - 1) {
   //    for (int index = _upperIndex + 1; index < [_photoArray count]; index++) {
   //       if ([_thumbnailDictionary objectForKey:[_photoArray objectAtIndex:index]]) {
   //          [_thumbnailDictionary removeObjectForKey:[_photoArray objectAtIndex:index]];
   //       }
   //    }
   // }
   for (NSInteger index = _lowerIndex; index <= _upperIndex; index++) {
      if (![_thumbnailDictionary objectForKey:[_photoArray objectAtIndex:index]]) {
         [server downloadThumbnail:[_photoArray objectAtIndex:index] withCompletionBlock:^(UIImage *image){
               [_thumbnailDictionary setObject:image forKey:[_photoArray objectAtIndex:index]];
               if (index == _upperIndex) {
                  [self reloadCollectionView];
               }
         }];
      }
      if (index == _upperIndex) {
         [self reloadCollectionView];
      }
   }
}

- (void)reloadCollectionView;
{
   dispatch_async(dispatch_get_main_queue(), ^{
      [_collectionView reloadData];
   });
   [self sendActionsForControlEvents:(UIControlEvents)customControlEventContentsUpdated];
}

- (BOOL)raiseIndexLimit;
{
   if (_upperIndex == [_photoArray count] - 1) {
      return NO;
   }
   if (_upperIndex + 50 < [_photoArray count] - 1)
      _upperIndex = _upperIndex + 50;
   else
      _upperIndex = [_photoArray count] - 1;
   return YES;
}


@end
