//
//  PaletteCollectionViewController.h
//  Palette
//
//  Created by Sohail Khanifar on 2/6/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaletteCollectionViewController : UICollectionViewController
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic,strong) UIImage* image;
-(void)getLightColors;
@end
