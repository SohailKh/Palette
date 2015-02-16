//
//  PaletteView.m
//  Pallete
//
//  Created by Sohail Khanifar on 2/6/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import "PaletteView.h"
#import <Colours/Colours.h>
@implementation PaletteView

-(instancetype)initWithColorArray:(NSArray*)arrayOfColors andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self createColorsButtonsInView:arrayOfColors];
    }
    return self;
}

-(void)createColorsButtonsInView:(NSArray*)colors
{
    colors = [self sortColors:colors];
    int index = 0;
    CGRect frame = self.bounds;
    frame.size.width = frame.size.width/5;
    
    for (UIColor* color in colors)
    {
        int xposition = index % 5;
        int yposition = index / 5;
        frame.origin.x = (xposition * self.frame.size.width/5);
        frame.origin.y = yposition * self.frame.size.width/5;
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button addTarget:self.delegate action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = color;
        
        NSString* hex =[self hexStringFromColor:color];
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        label.text = hex;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:12.f];
        label.textAlignment = kCTCenterTextAlignment;
        [label sizeToFit];
        [self addSubview:button];
        [self addSubview:label];
        index += 1;
    }
}

-(NSArray*)sortColors:(NSArray*)colors
{
    NSArray *sorted = [colors sortedArrayUsingComparator:^NSComparisonResult(UIColor* obj1, UIColor* obj2) {
        CGFloat distance = [obj1 distanceFromColor:obj2 type:ColorDistanceCIE94];
        if (distance < 8)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
        
    }];
    return sorted;
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    NSString* returnString= [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
//    NSLog(returnString);
    return returnString;
}

@end
