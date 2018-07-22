//
//  ProfilePhotoStreamView.h
//  MMCM2
//
//  Created by Richard Montricul on 2/19/17.
//  Copyright © 2017 Shadow Prodigy. All rights reserved.
//

#import "Global.h"

@interface ProfilePhotoStreamView : UIControl
   <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSMutableDictionary *thumbnailDictionary;
@property (strong, nonatomic) NSString *streamTag;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) UICollectionView *collectionView;
@property NSInteger lowerIndex;
@property NSInteger upperIndex;

- (id)init:(NSString *)Tag photoArray:(NSArray *)array delegate:(id)Delegate;
- (void)reload;
@end
