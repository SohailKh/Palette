//
//  PaletteCollectionViewController.m
//  Palette
//
//  Created by Sohail Khanifar on 2/6/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import "PaletteCollectionViewController.h"
#import "CSCell.h"
#import "CSHeader.h"
#import "CSStickyHeaderFlowLayout.h"
#import <AVFoundation/AVFoundation.h>
#import "CCColorCube.h"
#import <ChameleonFramework/Chameleon.h>
#import "PaletteView.h"
#import <STHTTPRequest/STHTTPRequest.h>
#import <EDColor/EDColor.h>
@interface PaletteCollectionViewController () < PaletteViewDelegate,CSCellDelegate,CSHeaderDelegate, CSStickyHeaderFlowLayoutDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UINib *headerNib;
@property (strong, nonatomic) NSArray *imageColors;
@property (strong, nonatomic) CCColorCube *colorCube;
@end


@implementation PaletteCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sections = @[];
        self.headerNib = [UINib nibWithNibName:@"CSGrowHeader" bundle:nil];
        self.colorCube = [[CCColorCube alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;
    
    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
    }
    
    // If we want to disable the sticky header effect
    layout.disableStickyHeaders = YES;
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    [self.collectionView registerNib:self.headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];
    
    
}



#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *obj = self.sections[indexPath.section];
    CSCell *cell;
    
    if ([[obj allKeys][0] isEqualToString:@"foundColors"]){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"foundColors"
                                                         forIndexPath:indexPath];
        cell.delegate = self;
        [cell addSubview:[obj allValues][0]];
        return cell;
    } else if ([[obj allKeys][0] isEqualToString:@"generatedColor"]){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"generatedColor"
                                                         forIndexPath:indexPath];
        cell.delegate = self;
        [cell addSubview:[obj allValues][0][0]];
        cell.paletteName.text = [obj allValues][0][1];
        return cell;
    }
    
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSDictionary *obj = self.sections[indexPath.section];
        CSCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"imageCell"
                                                                 forIndexPath:indexPath];
        
        return cell;
    } else if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        CSHeader *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
        if (self.image){
            cell.image.image = self.image;
            cell.image.contentMode = UIViewContentModeScaleAspectFill;
            cell.clipsToBounds = YES;
            cell.image.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            cell.autoresizingMask =  UIViewAutoresizingNone;
            return cell;
        } else {
            cell.delegate = self;
            return cell;
        }

    }
    return nil;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *obj = self.sections[indexPath.section];
    return CGSizeMake(self.view.frame.size.width, 300);
    
}

-(void)colorPicked:(UIButton *)button
{
    self.sections = [self.sections subarrayWithRange:NSMakeRange(0, 2)];
    NSMutableArray *colorArray = [[NSMutableArray alloc] initWithArray:ColorScheme(ColorSchemeTriadic, button.backgroundColor, NO)];
    NSMutableArray *colorArray2 = [[NSMutableArray alloc] initWithArray:ColorScheme(ColorSchemeComplementary, button.backgroundColor, NO)];
    NSMutableArray *colorArray3 = [[NSMutableArray alloc] initWithArray:ColorScheme(ColorSchemeAnalogous, button.backgroundColor, NO)];
    PaletteView* view = [[PaletteView alloc] initWithColorArray:colorArray andFrame:CGRectMake(0, 16,self.view.frame.size.width, 60)];
    PaletteView* view2 = [[PaletteView alloc] initWithColorArray:colorArray2 andFrame:CGRectMake(0, 16,self.view.frame.size.width, 60)];
    PaletteView* view3 = [[PaletteView alloc] initWithColorArray:colorArray3 andFrame:CGRectMake(0, 16,self.view.frame.size.width, 60)];
    self.sections = [self.sections arrayByAddingObject:@{@"generatedColor":@[view, @"Triadic"]}];
    self.sections = [self.sections arrayByAddingObject:@{@"generatedColor":@[view2, @"Complementary Colors"]}];
    self.sections = [self.sections arrayByAddingObject:@{@"generatedColor":@[view3, @"Analogous"]}];
    [self getPalettesFromImage:[self imageWithColor:button.backgroundColor]];
    [self.collectionView reloadData];
}

-(void)getPalettesFromImage:(UIImage*)image{
    __weak PaletteCollectionViewController *wself = self;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://pictaculous.com/api/1.0/"];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    [r addDataToUpload:data parameterName:@"image"];
    
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:nil];
        for (NSDictionary* color in [jsonResponse objectForKey:@"cl_themes"])
        {
            NSArray* colorArray = @[];
            for (NSString* colorString in [color objectForKey:@"colors"]){
                UIColor* color = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%@", colorString]];
                colorArray = [colorArray arrayByAddingObject:color];
            }
            PaletteView* view = [[PaletteView alloc] initWithColorArray:colorArray andFrame:frame];
            view.delegate = wself;
            NSString* title = [color objectForKey:@"title"];
            wself.sections = [wself.sections arrayByAddingObject:@{@"generatedColor":@[view, title]}];
        }
        for (NSDictionary* color in [jsonResponse objectForKey:@"kuler_themes"])
        {
            NSArray* colorArray = @[];
            for (NSString* colorString in [color objectForKey:@"colors"]){
                UIColor* color = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%@", colorString]];
                colorArray = [colorArray arrayByAddingObject:color];
            }
            PaletteView* view = [[PaletteView alloc] initWithColorArray:colorArray andFrame:frame];
            view.delegate = wself;
            NSString* title = [color objectForKey:@"title"];
            wself.sections = [wself.sections arrayByAddingObject:@{@"generatedColor":@[view, title]}];
        }
        [wself.collectionView reloadData];
    };
    
    r.errorBlock = ^(NSError *error) {
        NSLog(@"-- error: %@", error);
    };
    
    [r startAsynchronous];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma mark - Color extraction
-(void)getLightColors{
    [self computeImageColorsWithMode:0];
}

-(void)getDarkColors{
    [self computeImageColorsWithMode:1];
}

- (void)computeImageColorsWithMode:(NSUInteger)mode
{
    __weak PaletteCollectionViewController *wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage* image = wself.image;
        NSArray *darkColors = [wself.colorCube extractDarkColorsFromImage:image avoidColor:nil count:10];
        NSArray *lightColors = [wself.colorCube extractBrightColorsFromImage:image avoidColor:nil count:20];
        NSArray* colors = [darkColors arrayByAddingObjectsFromArray:lightColors];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, 60);
            newFrame.size.height = ([colors count]/6 + 1) * 60;
            PaletteView* view1 = [[PaletteView alloc] initWithColorArray:colors andFrame:newFrame];
            view1.delegate = wself;
            wself.sections = [NSArray array];
            wself.sections = [wself.sections arrayByAddingObject:@{@"foundColors":view1}];
            [wself.collectionView reloadData];
        });
    });
    
}
@end
