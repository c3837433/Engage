//
//  CustomAddPostViewController.m
//  Engage Your City
//
//  Created by Angela Smith on 2/26/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "CustomAddPostViewController.h"
#import "MZFormSheetController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface CustomAddPostViewController () <MBProgressHUDDelegate>
@property (nonatomic, strong) MBProgressHUD* HUD;
@end

@implementation CustomAddPostViewController

- (void)viewDidLoad {
    self.updatingStory = false;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem* stopBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onClick:)];
    stopBtn.tag = 0;
    // create the two buttons
    self.navigationItem.rightBarButtonItem = stopBtn;
    
    // add a border to the textview
    [[self.storyView layer] setBorderColor:[[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:0.5] CGColor]];
    [[self.storyView layer] setBorderWidth:1];
    [[self.storyView layer] setCornerRadius:8];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    //UIBarButtonItem* flexSpace = [[]
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(finishEditingStory)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
    self.storyView.inputAccessoryView = keyboardDoneButtonView;
    
    if (self.thisStory != nil) {
        NSLog(@"This is an update for a previous saying");
        [self setUpStoryForEdits];
    }
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

-(void)setUpStoryForEdits {
    self.updatingStory = true;
    self.titleField.text = [self.thisStory objectForKey:@"title"];
    self.storyView.text = [self.thisStory objectForKey:@"story"];
    if (![[self.thisStory objectForKey:@"media"] isEqual:@"text"]) {
        // GET AND SET THE MEDIA
        PFFile* storyMedia = [self.thisStory objectForKey:@"mediaThumb"];
        if ([storyMedia isDataAvailable]) {
            //[cell.image loadInBackground];
            PFFile* file = [self.thisStory objectForKey:@"mediaThumb"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    // set in view
                    self.returnedMediaImageView.image = image;
                    [self toggleToAddImage:true];
                }
            }];
        }
    }
}

-(IBAction)onClick:(UIButton* )button {
    if (button.tag == 0) {
        NSLog(@"User wants to cancel add item");
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
        [imagePicker showImagePickerInController:self animated:YES];
    
    } else if (button.tag == 3) {
        // user wants to cancel image
        NSLog(@"User wants to cancel image");
        self.mediaDataFile = nil;
        self.mediaThumbDataFile = nil;
        self.returnedMediaImageView.image = nil;
        [self toggleToAddImage:false];
        storyType = @"test";
    }
    
}

#pragma mark - JSImagePikcerViewControllerDelegate

-(void) imagePickerDidSelectImageForType:(NSString *)type imageData:(NSData*)imageData  andImage:(UIImage *)image {
    // set the image in the view
    [self toggleToAddImage:true];
    self.returnedMediaImageView.image = image;
    self.mediaThumbDataFile = imageData;
    storyType = type;
}

-(void) imagePickerDidCreateVideoForType:(NSString *)type videoData:(NSData*)videoData  videoThumbData:(NSData*)videothumbData  withImage:(UIImage *)image {
    [self toggleToAddImage:true];
    self.returnedMediaImageView.image = image;
    self.mediaThumbDataFile = videothumbData;
    self.mediaDataFile = videoData;
    storyType = type;

}

-(void)toggleToAddImage:(BOOL)value {

        self.returnedMediaImageView.hidden = (value) ? NO : YES;
        self.cancelPhotoButton.hidden = (value) ? NO : YES;
        self.cancelPhotoButton.enabled = (value) ? YES : NO;
        self.addPhotoButton.enabled = (value) ? NO : YES;
        self.addPhotoButton.hidden = (value) ? YES : NO;
}


#pragma mark SAVE STORIES TO PARSE

-(void)checkStoryForSave
{
    // Remove access to the view while saving
    self.shareStoryButton.enabled = NO;
    
    // get the values for each item
    NSString* storyTitle = self.titleField.text;
    NSString* storytext = self.storyView.text;
    if ((storytext.length == 0 || storyTitle.length == 0))
    {
        // Not saving, so restore access
        self.shareStoryButton.enabled = YES;
        // Alert the user one of the fields is empty
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Please check that you have both a Title and Story" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
    else
    {
        // check for hashtags
        NSMutableArray* hashtagArray = [self checkForHashtag:storytext];
        NSLog(@"Hashtags found: %lu", (unsigned long)hashtagArray.count);
        // Start Hud
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        // make sure each story has a type
        NSLog(@"Storytype = %@", storyType);
        if (!([storyType isEqualToString:@"video"]) && (![storyType isEqualToString:@"image"])) {
            // then this is a text story
            storyType = @"text";
            NSLog(@"This must be a text story");
        }
        // Save the story
        [self saveStory:self.mediaDataFile mediaImage:self.mediaThumbDataFile title:storyTitle text:storytext hashtags:hashtagArray];
    }
    
}

- (NSMutableArray*) checkForHashtag :(NSString*)storyText{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:storyText options:0 range:NSMakeRange(0, storyText.length)];
    NSMutableArray* newTags = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [storyText substringWithRange:wordRange];
        NSLog(@"Found tag %@", word);
        [newTags addObject:word];
        //NSLog(@"Current Hashtags found: %lu", (unsigned long)newTags.count);
    }
    
    //NSLog(@"Total Hashtags found: %lu", (unsigned long)newTags.count);
    return newTags;
}



-(void)saveStory:(NSData*)videoData mediaImage:(NSData*)mediaImage title:(NSString*)title text:(NSString*)text hashtags:(NSArray*)hashtags {
    PFObject* newStory;
    BOOL removeMedia = false;
    //NSLog(@"The hashtag array equals %@ ", hashtags);
    PFUser* user = [PFUser currentUser];
    if (self.updatingStory) {
        newStory = self.thisStory;
        if ((![[self.thisStory objectForKey:@"media"] isEqualToString:@"text"])  && ([storyType isEqualToString:@"text"])){
            // need to delete current video and image file associated with this story after it saves
            removeMedia = true;
        }
    } else {
        newStory = [PFObject objectWithClassName:@"Testimonies"];
    }
    // Set main data
    [newStory setObject:user forKey:@"author"];
    [newStory setObject:title forKey:@"title"];
    [newStory setObject:text forKey:@"story"];
    
    // set the acl
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:true];
    [acl setWriteAccess:true forRoleWithName:@"Admin"];
    [acl setWriteAccess:true forUser:[PFUser currentUser]];
    [acl setWriteAccess:true forRoleWithName:@"GroupLead"];
    [newStory setACL:acl];
    
    // set media type
    [newStory setObject:storyType forKey:@"media"];
    // If this is not a text story, save the image
    // set the saves based on story type
    if ([storyType isEqualToString:@"text"]) {
        // save what we got
        [self savePreparedStory:newStory withHashtags:hashtags];
    }
    if ([storyType isEqualToString:@"image"]) {
        // Remove the origional hud
        [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
        // first save the image
        PFFile* mediaThumb = [PFFile fileWithName:@"postImage.png" data:mediaImage];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.delegate = self;
        hud.labelText = @"Uploading Image";
        [mediaThumb saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Handle success or failure here ...
            if (succeeded) {
                [hud hide:YES];
                //and save the rest
                [newStory setObject:mediaThumb forKey:@"mediaThumb"];
                [self savePreparedStory:newStory withHashtags:hashtags];
                NSLog(@"image saved");
            }
        } progressBlock:^(int percentDone) {
            // Update your progress spinner here. percentDone will be between 0 and 100.
            hud.progress = (float)percentDone/100;
            NSLog(@"Percent done: %d", percentDone);
        }];
        
    }
    // If Video, save the video
    if ([storyType isEqualToString:@"video"]) {
        // first save image
        // Remove the origional hud
        [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
        PFFile* mediaThumb = [PFFile fileWithData:mediaImage];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.delegate = self;
        hud.labelText = @"Preparing Video";
        [mediaThumb saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Handle success or failure here ...
            if (succeeded) {
                [hud hide:YES];
                 NSLog(@"video image uploaded");
                //and save the rest
                [newStory setObject:mediaThumb forKey:@"mediaThumb"];
                // then save video
                MBProgressHUD *videoHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                videoHud.mode = MBProgressHUDModeAnnularDeterminate;
                videoHud.delegate = self;
                videoHud.labelText = @"Uploading Video";
                PFFile* videoFile = [PFFile fileWithName:@"video.mov" data:videoData];
                [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    // Handle success or failure here ...
                    // Handle success or failure here ...
                    if (succeeded) {
                        [videoHud hide:YES];
                        [newStory setObject:videoFile forKey:@"uploadedMedia"];
                        NSLog(@"video saved");
                        [self savePreparedStory:newStory withHashtags:hashtags];
                    }
                } progressBlock:^(int percentDone) {
                    // Update your progress spinner here. percentDone will be between 0 and 100.
                    videoHud.progress = (float)percentDone/100;
                }];
            }
        } progressBlock:^(int percentDone) {
            // Update your progress spinner here. percentDone will be between 0 and 100.
            hud.progress = (float)percentDone/100;
        }];
    }
}

-(void)savePreparedStory:(PFObject*)story  withHashtags:(NSArray*)hashtags {
    // Save the story
    [story saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         // if there were hashtags, save them
         if (hashtags.count > 0) {
             for (NSString* tag in hashtags) {
                 PFObject* hashtag = [PFObject objectWithClassName:@"Hashtags"];
                 [hashtag setObject:tag forKey:@"tag"];
                 [hashtag setObject: story forKey:@"Story"];
                 NSString* storyId = story.objectId;
                 [hashtag setObject:storyId forKey:@"PointerString"];
                 [hashtag setObject: [PFUser currentUser] forKey:@"StoryAuthor"];
                 [hashtag saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (error) {
                         NSLog(@"Error: %@", error.description);
                     }
                 }];
             }
         }
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
    if (self.updatingStory) {
        // display their alert
        // Create alerts based on if saved or not
        alertTitle = (saved) ? @"Story Updated" : @"Couldn't Update Story";
        alertMessage = (saved) ? nil : @"Please try updating your story again later";
    } else {
        // Create alerts based on if saved or not
        alertTitle = (saved) ? @"Story Posted" : @"Couldn't Post Story";
        alertMessage = (saved) ? @"Thank you for sharing your story with Engage!" : @"Please try sharing your story again later";
    }
    // Display the alert
    [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    // If it did save, the fields need to be emptied, otherwise leave the data to try again
    if (saved) {
        // Clear the current cells out
        self.titleField.text = @"";
        self.storyView.text = @"";
        self.returnedMediaImageView.image = nil;
        // return true
        if ([self.delegate respondsToSelector:@selector(viewController:returnPostSaved:)]) {
            [self.delegate viewController:self returnPostSaved:true];
        }
        
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            
        }];
    }
    // ReEnable the button
    self.shareStoryButton.enabled = YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleField) {
        self.validateTextImage.hidden = true;
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![self.titleField.text isEqualToString:@""]) {
        self.validateTextImage.image = [UIImage imageNamed:@"valid"];
        self.validateTextImage.hidden = NO;
        [self.storyView becomeFirstResponder];
        return false;
    } else {
        self.validateTextImage.image = [UIImage imageNamed:@"invalid"];
        self.validateTextImage.hidden = NO;
        return false;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.validateStoryImage.hidden = YES;
}


-(void)finishEditingStory {
    if (![self.storyView.text isEqualToString:@""]) {
        self.validateStoryImage.image = [UIImage imageNamed:@"valid"];
        self.validateStoryImage.hidden = NO;
            [self.storyView resignFirstResponder];
    } else {
        self.validateStoryImage.image = [UIImage imageNamed:@"invalid"];
        self.validateStoryImage.hidden = NO;
            [self.storyView resignFirstResponder];
    }
}


- (NSUInteger)supportedInterfaceOrientations
{
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
    return UIStatusBarStyleLightContent; // your own style
}

- (BOOL)prefersStatusBarHidden {
    //    return self.showStatusBar; // your own visibility code
    return NO;
}


@end
