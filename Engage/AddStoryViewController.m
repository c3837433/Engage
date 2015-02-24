//
//  AddStoryViewController.m
//  Engage
//
//  Created by Angela Smith on 8/10/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "AddStoryViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "DataHelper.h"

@interface AddStoryViewController ()

@end

@implementation AddStoryViewController

@synthesize enteredPostStory, enteredPostTitle, mediaDataFile, mediaThumbDataFile, mediaThumbnail, fromPanel;

- (void)viewDidLoad
{
    // see what sent the view over
    if (fromPanel == false) {
        // remove side button
        NSLog(@"This is not from the panel");
        if (self.thisSaying != nil) {
            NSLog(@"This is an update for a previous saying");
            [self setUpStoryForEdits];
        }
       // self.navigationItem.leftBarButtonItem = nil;
       // self.navigationItem.hidesBackButton = NO;
    } else {
        NSLog(@"This is not from the panel");
    }
    
    // Recognize when the user taps off the text areas
    UITapGestureRecognizer* tapOffField = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapOffField];
    
    // Add a Done button that will dismiss the keyboard when touched
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:enteredPostStory action:@selector(resignFirstResponder)];
    // Create a flexible space to mofe the button to the right
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    flexSpace.width = 240.0f;
    // Create the keyboard toolbar
    UIToolbar* keyboardBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
    // Add items to the toolbar
    keyboardBar.items = [NSArray arrayWithObjects:flexSpace, doneButton, nil];
    enteredPostStory.inputAccessoryView = keyboardBar;
    
    // Access the save button
    saveButton = self.navigationItem.rightBarButtonItem;
    // Set the background image
    UIImage* backgroundImage = [UIImage imageNamed:@"MainBg"];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [backgroundImage drawInRect:self.view.bounds];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:newimage];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITEXTFIELD AND UITEXTVIEW METHODS
-(void)setUpStoryForEdits {
    enteredPostTitle.text = [self.thisSaying objectForKey:@"title"];
    enteredPostStory.text = [self.thisSaying objectForKey:@"story"];
    if (![[self.thisSaying objectForKey:@"media"] isEqual:@"text"]) {
        // GET AND SET THE MEDIA
        PFFile* storyMedia = [self.thisSaying objectForKey:@"mediaThumb"];
        if ([storyMedia isDataAvailable]) {
            //[cell.image loadInBackground];
            PFFile* mediaImageFile = [self.thisSaying objectForKey:@"mediaThumb"];
            [self toggleButtonOptions:true];
           // self.mediaThumbnail.file = storyMedia;
           // [self.postImage loadInBackground];
        } else {
           // self.postImage.file = storyMedia;
            //[self.postImage loadInBackground];
        }
    }


}


-(void)hideKeyBoard
{
    // Close keyboard
    [enteredPostTitle resignFirstResponder];
    [enteredPostStory resignFirstResponder];
}
// Listen to when the user taps on the textview to move the keyboard
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self moveView:YES thisView:textView];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self moveView:NO thisView:textView];
}

// Move the view up so the user can enter into the fields behind the keyboard
- (void) moveView:(BOOL)outOfWay thisView:(UITextView*)thisView
{
    // How far to move the view on iPhone
    int distanceToMove = 70;
    // See which model is being used
    NSString *deviceModel = (NSString*)[UIDevice currentDevice].model;
    // If ipad
    if ([[deviceModel substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"iPad"])
    {
        //  reset the distance the keyboard would need to move on an ipad
        distanceToMove = 80;
    }
    // Move the view the distance it is necessary
    int viewMoves = viewMoves = (outOfWay ? - distanceToMove : distanceToMove);
    // Create the annimagion to move the view
    [UIView beginAnimations: @"keyboardAnnimation" context: nil];
    //Start from the current position,set speed and move vertically
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.4f];
    self.view.frame = CGRectOffset(self.view.frame, 0, viewMoves);
    [UIView commitAnimations];
}

-(void)viewDidAppear:(BOOL)animated
{
    // Check if user has given permission to share stories
    userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults != nil)
    {
        NSString* permission = [userDefaults objectForKey:@"sharePermission"];
        if (![permission isEqualToString:@"YES"])
        {
            [[[UIAlertView alloc] initWithTitle:@"Permission to Share" message:@"By submitting this story I am giving consent for it to be shared with Engage users." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"I Agree", nil] show];
        }
    }
}

// If the user gave permission, change the default and store that value as a PFUser value
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // user denied consent return to story feed view
        [self.navigationController popViewControllerAnimated:YES];
        //self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    }
    else if (buttonIndex == 1)
    {
        // Update the default
        [userDefaults setObject:@"YES" forKey:@"sharePermission"];
        [userDefaults synchronize];
        // Update the user on parse
        PFUser* user = [PFUser currentUser];
        if (user != nil)
        {
            user[@"sharePermission"] = @"YES";
            [user saveEventually:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"%@", error.description);
                }
            }];
        }
    }
}
-(IBAction)onClick:(UIButton*)button
{
    if (button.tag == 10)
    {
        // Return to feed
        //[self dismissViewControllerAnimated:TRUE completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (button.tag == 4)
    {
        // This was the cancel media button, remove media and return to main view
        mediaThumbnail.image = nil;
        [self toggleButtonOptions:NO];
    }
    else
    {
        // Create the picker controller and open it based on which button was selected
        pickerVC = [[UIImagePickerController alloc] init];
        if (pickerVC != nil) {
            
            if (button.tag == 1)
            {
                // Camera button
                pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerVC.allowsEditing = FALSE;
            }
            else if (button.tag == 2)
            {
                // Video button
                pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
                // Select the media type
                pickerVC.mediaTypes = @[(NSString*) kUTTypeMovie];
            }
            else if (button.tag == 3)
            {
                // album button
                pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                pickerVC.allowsEditing = FALSE;
                // Be able to view both video and photo's in the library
                pickerVC.mediaTypes = @[(NSString*) kUTTypeImage, (NSString*)kUTTypeMovie];
            }
            // set the delegate and display the picker
            pickerVC.delegate = self;
            //pickerVC.navigationBar.tintColor = [UIColor whiteColor];
            /*NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor],NSForegroundColorAttributeName,
                                                       [UIColor lightGrayColor], NSShadowAttributeName,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], NSShadowAttributeName, nil];
            [pickerVC.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
            [pickerVC.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
             */
            [self presentViewController:pickerVC animated:true completion:nil];
        }
    }

}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Show HUD view as the image is prepated 
    [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    // Check the sourceType
    NSLog(@"%@", info.description);
    NSString* sourceType = [info objectForKey:@"UIImagePickerControllerMediaType"];
    NSLog(@"the source type = %@", sourceType);
    if ([sourceType isEqualToString:@"public.movie"])
    {
        // A movie was recorded
        storyType = @"video";
        // Get the url
        movieUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        // To make a thumbnail image of this video, initialize the video as an AV asset
        AVURLAsset* avAsset = [[AVURLAsset alloc] initWithURL:movieUrl options:nil];
        NSParameterAssert(avAsset);
        // Generate an image from the video track
        AVAssetImageGenerator* aImgGen = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
        // If the video was taken in portrait mode transform the video so the pic will be right side up
        aImgGen.appliesPreferredTrackTransform = YES;
        // Do not apply apperature encoding
        aImgGen.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        
        // Create an empty image reference
        CGImageRef thumbnailImageRef = NULL;
        
        // Take the image 2 seconds into the movie
        //CFTimeInterval imageAtSecond = 2;
        thumbnailImageRef = [aImgGen copyCGImageAtTime:CMTimeMake(2, 60) actualTime:NULL error:nil];
        // If we have a thumbnail image ref, create UIImage from it.
        UIImage* thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
        : nil;
        // Convert the video path to a string
        NSString* moviePath = [movieUrl path];
        // Pass the video to the next view
        if (moviePath != nil)
        {
            // If this video can be saved to the album, save it.
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath))
            {
                UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
            }
            // Close the picker, pass the path to and open the next vc
            [picker dismissViewControllerAnimated:YES completion:^{
                // create a jpeg data image of the thumbnail to save as a PFFile
                mediaThumbDataFile = UIImageJPEGRepresentation(thumbnailImage, 1.0);
                // create the video data file
                mediaDataFile = [[NSData alloc] initWithContentsOfURL:movieUrl];
                //NSLog(@" movie media info = %@", mediaDataFile.description);
                // set the thumbnail image into the imageview
                mediaThumbnail.image = thumbnailImage;
                // display the image and cancel button
                [self toggleButtonOptions:true];
                // Remove the hud
                [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            }];
        }
    }
    // If the user selected an image
    else if ([sourceType isEqualToString:@"public.image"])
    {
        // Set the story type to photo
        storyType = @"image";
        NSLog(@"%@", info.description);
        // Get the image for the image view
        // Origional Image
        UIImage* imageData = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //UIImage* dataThumbnail = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        if (imageData != nil)
        {   // Create a png data image for the PFFile and close the picker
            mediaThumbDataFile = UIImageJPEGRepresentation(imageData, 1.0);
            [picker dismissViewControllerAnimated:YES completion:^{
                // Set the thumbnail image in the chosen image view
                mediaThumbnail.image = imageData;
                [self toggleButtonOptions:true];
                // Hide the hud
                [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            }];
        }
        
    }
}

-(void)toggleButtonOptions:(BOOL)value
{
    // If we added an image, toggle between control views
    addMediaView.hidden = (value) ? YES : NO;
    cancelMediaView.hidden = (value) ? NO : YES;
    // If they cancel, reset the story type to text so we don't save it incorrectly
    if (!value) {
        storyType = @"text";
    }
}
#pragma mark SAVE STORIES TO PARSE

-(IBAction)checkStoryForSave:(UIButton*)button
{
    // Remove access to the view while saving
    saveButton.enabled = NO;

    // get the values for each item
    NSString* storyTitle = enteredPostTitle.text;
    NSString* storytext = enteredPostStory.text;
    if ((storytext.length == 0 || storyTitle.length == 0))
    {
        // Not saving, so restore access
        saveButton.enabled = YES;
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
        [self saveStory:mediaDataFile mediaImage:mediaThumbDataFile title:storyTitle text:storytext hashtags:hashtagArray];
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



-(void)saveStory:(NSData*)videoData mediaImage:(NSData*)mediaImage title:(NSString*)title text:(NSString*)text hashtags:(NSArray*)hashtags
{
    //NSLog(@"The hashtag array equals %@ ", hashtags);
    PFUser* user = [PFUser currentUser];
    PFObject* newStory = [PFObject objectWithClassName:@"Testimonies"];
    // Set main data
    [newStory setObject:user forKey:@"author"];
    [newStory setObject:title forKey:@"title"];
    [newStory setObject:text forKey:@"story"];
    
    // set media type
    [newStory setObject:storyType forKey:@"media"];
    // If this is not a text story, save the image
    if (![storyType isEqualToString:@"text"])
    {
        PFFile* mediaThumb = [PFFile fileWithData:mediaImage];
        [newStory setObject:mediaThumb forKey:@"mediaThumb"];
    }
    // If Video, save the video
    if ([storyType isEqualToString:@"video"])
    {
        PFFile* videoFile = [PFFile fileWithName:@"video.mov" data:videoData];
        [newStory setObject:videoFile forKey:@"uploadedMedia"];
    }
    // set the acl
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:true];
    [acl setWriteAccess:true forRoleWithName:@"Admin"];
    [acl setWriteAccess:true forUser:[PFUser currentUser]];
    [acl setWriteAccess:true forRoleWithName:@"GroupLead"];
    [newStory setACL:acl];
    // Save the story
    [newStory saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         // if there were hashtags, save them
         if (hashtags.count > 0) {
             
             for (NSString* tag in hashtags) {
                 PFObject* hashtag = [PFObject objectWithClassName:@"Hashtags"];
                 [hashtag setObject:tag forKey:@"tag"];
                 [hashtag setObject: newStory forKey:@"Story"];
                  NSString* storyId = newStory.objectId;
                 [hashtag setObject:storyId forKey:@"PointerString"];
                 [hashtag setObject: [PFUser currentUser] forKey:@"StoryAuthor"];
                 [hashtag saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (error) {
                         NSLog(@"Error: %@", error.description);
                     }
                 }];
             }
         }
         // Alert the user the story is saved
         [self storySavedAlert:succeeded];
         //   NSLog(@"The save was successful");
     }];
    // add the media options back to the view
    [self toggleButtonOptions:false];
    //Save complete restore button access
}


-(void)storySavedAlert:(BOOL)saved
{
    // Remove the hud
    [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
    // Create alerts based on if saved or not
    NSString* alertTitle = (saved) ? @"Story Posted" : @"Couldn't Post Story";
    NSString* alertMessage = (saved) ? @"Thank you for sharing your story with Engage!" : @"Please try sharing your story again later";
    // Display the alert
    [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    // If it did save, the fields need to be emptied, otherwise leave the data to try again
    if (saved)
    {
        // Clear the current cells out
        enteredPostTitle.text = @"";
        enteredPostStory.text = @"";
        mediaThumbnail.image = nil;
    }
    // ReEnable the button
    saveButton.enabled = YES;

    
}

#pragma mark UITEXTFIELD DEEGATE METHODS
// Close keyboard when user touches off text field or
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // If the user hits return on the title field
    if(textField == enteredPostTitle)
    {
        // Move the user to the story field
        [enteredPostStory becomeFirstResponder];
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
