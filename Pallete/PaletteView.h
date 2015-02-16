//
//  PaletteView.h
//  Pallete
//
//  Created by Sohail Khanifar on 2/6/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PaletteViewDelegate <NSObject>
-(void)colorPicked:(UIButton*)button;
@end

@interface PaletteView : UIView
@property (weak, nonatomic) id<PaletteViewDelegate> delegate;
-(instancetype)initWithColorArray:(NSArray*)arrayOfColors andFrame:(CGRect)frame;
@property (strong,nonatomic)UILabel* hex;

@end
