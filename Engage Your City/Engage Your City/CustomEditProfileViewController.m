//
//  CustomEditProfileViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 3/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "CustomEditProfileViewController.h"
#import "MZFormSheetController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "ApplicationKeys.h"
#import "UIImage+ResizeAdditions.h"

@interface CustomEditProfileViewController ()<MBProgressHUDDelegate> {
    BOOL changedName;
    BOOL changedLocation;
    BOOL changedAboutMe;
    BOOL changedImage;
    BOOL hadImage;
    BOOL hasImage;

}
@property (nonatomic, strong) MBProgressHUD* HUD;
@property (nonatomic, strong) PFUser* user;


@end

@implementation CustomEditProfileViewController

- (void)viewDidLoad {
    hadImage = false;
    hasImage = false;
    changedName = false;
    changedLocation = false;
    changedAboutMe = false;
    changedImage = false;
    self.updateProfileButton.enabled = NO;
    self.user = [PFUser currentUser];
    [super viewDidLoad];
    [self setUpStoryForEdits];
    // Do any additional setup after loading the view.
    UIBarButtonItem* stopBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onClick:)];
    stopBtn.tag = 0;
    // create the two buttons
    self.navigationItem.rightBarButtonItem = stopBtn;
    
    // add a border to the textview
    [[self.aboutMeView layer] setBorderColor:[[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:0.5] CGColor]];
    [[self.aboutMeView layer] setBorderWidth:1];
    [[self.aboutMeView layer] setCornerRadius:8];
    // set up edit listeners
    // begin listening for change events
    [self.nameField addTarget:self action:@selector(userChangedField:) forControlEvents:UIControlEventEditingChanged];
    [self.locationField addTarget:self action:@selector(userChangedField:) forControlEvents:UIControlEventEditingChanged];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    //UIBarButtonItem* flexSpace = [[]
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(finishEditingStory)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
    self.aboutMeView.inputAccessoryView = keyboardDoneButtonView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Access to form sheet controller
    MZFormSheetController *controller = self.navigationController.formSheetController;
    controller.shouldDismissOnBackgroundViewTap = YES;
    
}

-(void) userChangedField:(UITextField*)field {
    // Display the button to allow saying update
    self.updateProfileButton.enabled = YES;
    // see what was changed
    switch (field.tag) {
        case 1: // Name
            changedName = YES;
            NSLog(@"The user changed name field");
            break;
        case 2: // location
            changedLocation = YES;
            NSLog(@"The user changed location field");
            break;
        default:
            break;
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    NSLog(@"The user updated the saying");
    changedAboutMe = YES;
    // Display the button to update
    self.updateProfileButton.enabled = YES;
    
}

-(void)setUpStoryForEdits {
    self.updatingProfile = true;
    
    self.nameField.text = [self.user objectForKey:aUserName];
    if ([self.user objectForKey:aUserLocationName]) {
        self.locationField.text = [self.user objectForKey:aUserLocationName];
    }
    if ([self.user objectForKey:aUserAboutMe]) {
        self.aboutMeView.text = [self.user objectForKey:aUserAboutMe];
    }
    if ([self.user objectForKey:aUserImage]) {
        hadImage = true;
       // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [self.user objectForKey:aUserImage];
        if ([imageFile isDataAvailable]) {
            self.userImageView.file = imageFile;
            [self.userImageView loadInBackground];
        } else {

            self.userImageView.file = imageFile;
            [self.userImageView loadInBackground];
        }
    } else {
        self.userImageView.image = [UIImage imageNamed:@"placeholder"];
    }
    [self toggleToAddImage:true];
   
}

-(IBAction)onClick:(UIButton* )button {
    if (button.tag == 0) {
        NSLog(@"User wants to cancel edit profile");
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        }];
    }
    else if (button.tag == 1) {
        NSLog(@"User pressed save button");
        // get entered text
        [self checkStoryForSave];
    } else if (button.tag == 2) {
        
        JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
        imagePicker.delegate = self;
        imagePicker.doesNeedVideo = false;
        [imagePicker showImagePickerInController:self animated:YES];
        
    } else if (button.tag == 3) {
        // user wants to cancel image
        NSLog(@"User wants to cancel image");
        self.mediaDataFile = nil;
        self.mediaThumbDataFile = nil;
        self.userImageView.image = nil;
        [self toggleToAddImage:false];
        changedImage = true;
        //hasImage = false;
        self.updateProfileButton.enabled = YES;
    }
    
}

#pragma mark - JSImagePikcerViewControllerDelegate
-(void) imagePickerDidSelectImageForType:(NSString *)type imageData:(NSData*)imageData  andImage:(UIImage *)image {
    // set the image in the view
    [self toggleToAddImage:true];
    if (image != nil) {
        // Crop the image corners and make it the right size
        UIImage* resizedImage = [image thumbnailImage:75 transparentBorder:0 cornerRadius:8 interpolationQuality:kCGInterpolationMedium];
        // Create a png thumbnail of this resized image to display in the user registration view
        imageData = UIImagePNGRepresentation(resizedImage);
        self.userImageView.image = resizedImage;
        self.mediaThumbDataFile = imageData;
        //hasImage = true;
        self.updateProfileButton.enabled = YES;
        if (hadImage) {
            changedImage = true;
        }
    }
}


-(void)toggleToAddImage:(BOOL)value {
    NSLog(value ? @"Image is attached" : @"Image is not attached");
    hasImage = value;
    self.userImageView.hidden = (value) ? NO : YES;
    self.cancelPhotoButton.hidden = (value) ? NO : YES;
    self.cancelPhotoButton.enabled = (value) ? YES : NO;
    self.addPhotoButton.enabled = (value) ? NO : YES;
    self.addPhotoButton.hidden = (value) ? YES : NO;
}


#pragma mark SAVE STORIES TO PARSE
-(void)checkStoryForSave {
    // Remove access to the view while saving
    self.updateProfileButton.enabled = NO;
    
    // get the values for each item
    NSString* userName = self.nameField.text;
    if (userName.length == 0) {
        // Not saving, so restore access
        self.updateProfileButton.enabled = YES;
        // Alert the user one of the fields is empty
        [[[UIAlertView alloc] initWithTitle:@"Missing Name" message:@"Please check that you have a name entered" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    } else {
        // get remaining fields
        NSString* userLocation = self.locationField.text;
        NSString* aboutUser = self.aboutMeView.text;
        // Start Hud
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        // Save the story
        [self saveStory:self.mediaDataFile mediaImage:self.mediaThumbDataFile name:userName location:userLocation aboutMe:aboutUser];
    }
    
}




-(void)saveStory:(NSData*)videoData mediaImage:(NSData*)mediaImage name:(NSString*)name location:(NSString*)location  aboutMe:(NSString*)aboutMe {

    // Make sure we are updating the current user
    PFUser* user = [PFUser currentUser];
    // Set main data
    if (changedName) {
        [user setObject:name forKey:aUserName];
        NSLog(@"Updating name");
    }
    if (changedLocation) {
                NSLog(@"Updating location");
        if ([location isEqualToString:@""]) {
            [user setObject:[NSNull null] forKey:aUserLocationName];
        } else {
            [user setObject:location forKey:aUserLocationName];
        }
    }
    if (changedAboutMe) {
        NSLog(@"Updating about me");
        if ([aboutMe isEqualToString:@""]) {
            [user setObject:[NSNull null] forKey:aUserAboutMe];
        } else {
            [user setObject:aboutMe forKey:aUserAboutMe];
        }

    }

    // see if the user updated the image
    if (changedImage) {
        NSLog(@"User needs to update their image");
        if ((hadImage) && (!hasImage)) {
            NSLog(@"User had an image at the start, but removed it");
            // need to delete the origional image
            [user removeObjectForKey:aUserImage];
            [user saveEventually];
        } else if (hasImage) {
            // get the image
            NSLog(@"Updating the user's profile image");
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            // first save the image
            PFFile* mediaThumb = [PFFile fileWithData:mediaImage];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            hud.delegate = self;
            hud.labelText = @"Saving Proile Image";
            [mediaThumb saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                // Handle success or failure here ...
                if (succeeded) {
                    [hud hide:YES];
                    //and save the rest
                    [user setObject:mediaThumb forKey:aUserImage];
                    [self updateUserProfile:user];
                    NSLog(@"image saved");
                }
            } progressBlock:^(int percentDone) {
                // Update the progress spinner
                hud.progress = (float)percentDone/100;
            }];
        }
    } else {
        NSLog(@"No image to update, but the user saved something else");
         [self updateUserProfile:user];
    }
}

-(void)updateUserProfile:(PFUser*)user  {
    // Save the story
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // Remove the hud
        [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
        if (succeeded) {
            // add the media options back to the view
            [self toggleToAddImage:false];
        }
        // Alert the user the story is saved
        [self storySavedAlert:succeeded];
        //   NSLog(@"The save was successful");
    }];
    
    
    
    
}
-(void)storySavedAlert:(BOOL)saved {
    
    NSString* alertTitle;
    NSString* alertMessage;
    alertTitle = (saved) ? @"Profile Updated" : @"Couldn't Update Profile";
    alertMessage = (saved) ? nil : @"Please try updating your profile again later";
    
    // Display the alert
    [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    // If it did save, the fields need to be emptied, otherwise leave the data to try again
    if (saved)
    {
        // Clear the current cells out
        self.nameField.text = @"";
        self.locationField.text = @"";
        self.aboutMeView.text = @"";
        self.userImageView.image = nil;
        // return true
        if ([self.delegate respondsToSelector:@selector(viewController:returnPostUpdated:)]) {
            [self.delegate viewController:self returnPostUpdated:true];
        }
        
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            
        }];
    }
    // ReEnable the button
    self.updateProfileButton.enabled = YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.nameField) {
        self.validateTextImage.hidden = true;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField == self.nameField) {
        [self.locationField becomeFirstResponder];
        if (![self.nameField.text isEqualToString:@""]) {
            self.validateTextImage.image = [UIImage imageNamed:@"valid"];
            self.validateTextImage.hidden = NO;
        } else {
            self.validateTextImage.image = [UIImage imageNamed:@"invalid"];
            self.validateTextImage.hidden = NO;
        }
    } else if (textField == self.locationField) {
        [self.aboutMeView becomeFirstResponder];
    }
    
    return NO;
}

// Stop the user from entering too long of a message
 - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
     
     return textView.text.length + (text.length - range.length) <= 175;
 }


-(void)finishEditingStory {
    [self.aboutMeView resignFirstResponder];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.showStatusBar = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.formSheetController setNeedsStatusBarAppearanceUpdate];
    }];
    
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}




@end
