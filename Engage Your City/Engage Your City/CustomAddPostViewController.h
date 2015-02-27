//
//  CustomAddPostViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 2/26/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSImagePickerViewController.h"
#import <Parse/Parse.h>

@protocol CustomAddPostDelegate <NSObject>

- (void)viewController:(UIViewController *)viewController returnPostSaved:(BOOL)saved;

@end

@interface CustomAddPostViewController : UIViewController  <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate, JSImagePickerViewControllerDelegate, UITextViewDelegate> {
    
    IBOutlet UIButton* cancelButton;
    UIImagePickerController* pickerVC;
    NSURL* movieUrl;
    UIImage* thumbnail;
    NSString* storyType;
    
}

@property (nonatomic, assign) BOOL showStatusBar;
@property (nonatomic, strong) IBOutlet UITextField* titleField;
@property (nonatomic, strong) IBOutlet UITextView* storyView;
@property (nonatomic, strong) IBOutlet UIImageView* validateTextImage;
@property (nonatomic, strong) IBOutlet UIImageView* returnedMediaImageView;
@property (nonatomic, strong) IBOutlet UIImageView* validateStoryImage;
@property (nonatomic, strong) IBOutlet UIButton* addPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton* cancelPhotoButton;
@property (nonatomic, strong) IBOutlet UIButton* shareStoryButton;
@property (nonatomic, strong) UIToolbar* keyboardToolbar;
@property (nonatomic, strong) NSData* mediaDataFile;
@property (nonatomic, strong) NSData* mediaThumbDataFile;
@property (nonatomic, strong) PFObject* thisStory;
@property (nonatomic) BOOL updatingStory;

@property (nonatomic, strong) NSString* searchString;
@property (nonatomic, weak) id <CustomAddPostDelegate> delegate;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@end
