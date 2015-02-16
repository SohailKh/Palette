//
//  FirstViewController.h
//  Palette
//
//  Created by Sohail Khanifar on 2/10/15.
//  Copyright (c) 2015 Sohail Khanifar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end
