//
//  FirstViewController.m
//  Palette
//
//  Created by Sohail Khanifar on 2/10/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import "FirstViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import "DZNPhotoEditorViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "PaletteCollectionViewController.h"
#import "DZNPhotoPickerController.h"
#import "UIImagePickerController+Edit.h"

@interface FirstViewController () {
    UIPopoverController *_popoverController;
    UIActionSheet *_actionSheet;
    NSDictionary *_photoPayload;
}

@property (weak, nonatomic) IBOutlet UIButton *camera;
@property (strong, nonatomic) CAGradientLayer *gradient;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addGradient];
}

-(void)addGradient{
    UIColor* color = RandomFlatColorWithShade(UIShadeStyleDark);
    UIColor* darkColor = ComplementaryFlatColorOf(color);
    
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.view.bounds;
    self.gradient.colors = @[(id)color.CGColor,
                             (id)darkColor.CGColor];
    
    [self.view.layer insertSublayer:self.gradient atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    [self animateLayer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.05
                                                  target:self
                                                selector:@selector(animateLayer)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void)animateLayer
{
    UIColor* color = RandomFlatColorWithShade(UIShadeStyleDark);
    UIColor* darkColor = ComplementaryFlatColorOf(color);
    color = (arc4random_uniform(8)> 1 ) ? (id)color.CGColor : [self.gradient.colors firstObject];
    darkColor = (arc4random_uniform(8)>1) ? (id)darkColor.CGColor : [self.gradient.colors lastObject];
    
    NSArray *fromColors = self.gradient.colors;
    NSArray *toColors = @[(id)color,
                          (id)darkColor];
    
    [self.gradient setColors:toColors];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    
    animation.fromValue             = fromColors;
    animation.toValue               = toColors;
    animation.duration              = 2.0;
    animation.removedOnCompletion   = YES;
    animation.fillMode              = kCAFillModeForwards;
    animation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.delegate              = self;
    
    // Add the animation to our layer
    
    [self.gradient addAnimation:animation forKey:@"animateGradient"];
}


- (IBAction)cameraButtonPress:(UIButton *)sender {
    [self showImportActionSheet:sender];
}

- (void)showImportActionSheet:(id)sender
{
    _actionSheet = [UIActionSheet new];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [_actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo", nil)];
    }
    
    [_actionSheet addButtonWithTitle:NSLocalizedString(@"Choose Photo", nil)];
    [_actionSheet addButtonWithTitle:NSLocalizedString(@"Search Photo", nil)];
    
    [_actionSheet setCancelButtonIndex:[_actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [_actionSheet setDelegate:self];
    [_actionSheet showInView:self.view];
}

- (void)presentPhotoSearch:(id)sender
{
    DZNPhotoPickerController *picker = [DZNPhotoPickerController new];
    picker.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGoogleImages;
    picker.allowsEditing = NO;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    picker.initialSearchTerm = @"California";
    picker.enablePhotoDownload = YES;
    picker.allowAutoCompletedSearch = YES;
    
    [picker setFinalizationBlock:^(DZNPhotoPickerController *picker, NSDictionary *info){
        [self updateImageWithPayload:info];
        [self dismissController:picker];
    }];
    
    [picker setFailureBlock:^(DZNPhotoPickerController *picker, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    [picker setCancellationBlock:^(DZNPhotoPickerController *picker){
        [self dismissController:picker];
    }];
    
    [self presentController:picker sender:sender];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType sender:(id)sender
{
    __weak __typeof(self)weakSelf = self;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    
    picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        // Dismiss when the crop mode was disabled
        if (picker.cropMode == DZNPhotoEditorViewControllerCropModeNone) {
            [weakSelf handleImagePicker:picker withMediaInfo:info];
        }
    };
    
    picker.cancellationBlock = ^(UIImagePickerController *picker) {
        [weakSelf dismissController:picker];
    };
    
    [self presentController:picker sender:sender];
}

- (void)handleImagePicker:(UIImagePickerController *)picker withMediaInfo:(NSDictionary *)info
{
    [self updateImageWithPayload:info];
    [picker dismissViewControllerAnimated:YES completion:^{
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        PaletteCollectionViewController* pvc = [storyboard instantiateViewControllerWithIdentifier:@"pvc"];
        pvc.image = _photoPayload[UIImagePickerControllerEditedImage];
        [self.navigationController presentViewController:pvc animated:YES completion:^{
            [pvc getLightColors];
        }];
    }];
//    [self dismissController:picker];
}
- (void)presentPhotoEditor:(id)sender
{
    UIImage *image = _photoPayload[UIImagePickerControllerOriginalImage];
    if (!image) image = self.imageView.image;
    
    DZNPhotoEditorViewControllerCropMode cropMode = [_photoPayload[DZNPhotoPickerControllerCropMode] integerValue];
    
    DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image];
    editor.cropMode = (cropMode != DZNPhotoEditorViewControllerCropModeNone) ? : DZNPhotoEditorViewControllerCropModeSquare;
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:editor];
    
    [editor setAcceptBlock:^(DZNPhotoEditorViewController *editor, NSDictionary *userInfo){
        [self updateImageWithPayload:userInfo];
        [self dismissController:editor];
    }];
    
    [editor setCancelBlock:^(DZNPhotoEditorViewController *editor){
        [self dismissController:editor];
    }];
    
    [self presentController:controller sender:sender];
}

- (void)updateImageWithPayload:(NSDictionary *)payload
{
    _photoPayload = payload;
    
    NSLog(@"OriginalImage : %@", payload[UIImagePickerControllerOriginalImage]);
    NSLog(@"EditedImage : %@", payload[UIImagePickerControllerEditedImage]);
    NSLog(@"MediaType : %@", payload[UIImagePickerControllerMediaType]);
    NSLog(@"CropRect : %@", NSStringFromCGRect([ payload[UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"ZoomScale : %f", [ payload[DZNPhotoPickerControllerCropZoomScale] floatValue]);
    
    NSLog(@"CropMode : %@", payload[DZNPhotoPickerControllerCropMode]);
    NSLog(@"PhotoAttributes : %@", payload[DZNPhotoPickerControllerPhotoMetadata]);
    
    UIImage *image = payload[UIImagePickerControllerEditedImage];
    if (!image) image = payload[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = image;
//    [self saveImage:image];
}

- (void)saveImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)resetContent
{
    _photoPayload = nil;
    self.imageView.image = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)presentController:(UIViewController *)controller sender:(id)sender
{
    if (_popoverController.isPopoverVisible) {
        [_popoverController dismissPopoverAnimated:YES];
        _popoverController = nil;
    }
    
    if (_actionSheet.isVisible) {
        _actionSheet = nil;
    }
    
   [self presentViewController:controller animated:YES completion:NULL];
}

- (void)dismissController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self handleImagePicker:picker withMediaInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self handleImagePicker:picker withMediaInfo:nil];
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Take Photo", nil)]) {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera sender:self.camera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Choose Photo", nil)]) {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary sender:self.camera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Search Photo",nil)]) {
        [self presentPhotoSearch:self.camera];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
