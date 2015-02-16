//
//  CSCell.h
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by Jamz Tang on 8/1/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CSCellDelegate <NSObject>
@optional
-(void)share;
-(void)getDarkColors;
-(void)getLightColors;
@end

@interface CSCell : UICollectionViewCell
@property (weak, nonatomic) id<CSCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *darkButton;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;

@property (weak, nonatomic) IBOutlet UILabel *paletteName;

@end
