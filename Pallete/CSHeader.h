//
//  CSHeader.h
//  Palette
//
//  Created by Sohail Khanifar on 2/7/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CSHeaderDelegate <NSObject>
-(void)addImage;
@end


@interface CSHeader : UICollectionViewCell
@property (weak, nonatomic) id<CSHeaderDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *addImage;

@end
