//
//  CustomEditProfileViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSImagePickerViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@protocol CustomEditProfileDelegate <NSObject>

- (void)viewController:(UIViewController *)viewController returnPostUpdated:(BOOL)updated;

@end

@interface CustomEditProfileViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, JSImagePickerViewControllerDelegate, UITextViewDelegate> {
    
    IBOutlet UIButton* cancelButton;
    UIImagePickerController* pickerVC;
    UIImage* thumbnail;    
}

@property (nonatomic, assign) BOOL showStatusBar;
@property (nonatomic, strong) IBOutlet UITextField* nameField;
@property (nonatomic, strong) IBOutlet UITextField* locationField;
@property (nonatomic, strong) IBOutlet UITextView* aboutMeView;
@property (nonatomic, strong) IBOutlet UIImageView* validateTextImage;
@property (nonatomic, strong) IBOutlet PFImageView * userImageView;
@property (nonatomic, strong) IBOutlet UIButton* addPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton* cancelPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton* updateProfileButton;
@property (nonatomic, strong) UIToolbar* keyboardToolbar;
@property (nonatomic, strong) NSData* mediaDataFile;
@property (nonatomic, strong) NSData* mediaThumbDataFile;
@property (nonatomic) BOOL updatingProfile;

@property (nonatomic, strong) NSString* searchString;
@property (nonatomic, weak) id <CustomEditProfileDelegate> delegate;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@end
