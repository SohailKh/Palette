//
//  CSCell.m
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by Jamz Tang on 8/1/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//

#import "CSCell.h"

@implementation CSCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)shareButtonPress:(UIButton *)sender {
    
}
- (IBAction)lightButtonPress:(UIButton *)sender {
    [self.delegate getLightColors];
}
- (IBAction)darkButtonPress:(UIButton *)sender {
    [self.delegate getDarkColors];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
