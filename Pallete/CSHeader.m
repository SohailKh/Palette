//
//  CSHeader.m
//  Palette
//
//  Created by Sohail Khanifar on 2/7/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import "CSHeader.h"

@implementation CSHeader
- (IBAction)addImagePress:(UIButton *)sender {
    [self.delegate addImage];
}

@end
