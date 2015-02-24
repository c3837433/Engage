//
//  ProfileViewController.m
//  Test Engage
//
//  Created by Angela Smith on 8/17/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "ProfileViewController.h"
//#import "XDKAirMenuController.h"
//#import "SettingsTableViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+ResizeAdditions.h"
#import "ProfileTextStoryCell.h"
#import "ProfileMediaStoryCell.h"
#import "ProfileStoryDetailViewController.h"
#import "ProfileTextDetailViewController.h"
@interface ProfileViewController ()

@end

@implementation ProfileViewController
//@synthesize authorPic, authorLocation, authorName, headerView, editProfilePictureBtn, editUserLocationField, editUserNameField, imageData;

@synthesize authorPic, authorName, headerView, editProfilePictureBtn, imageData, authorHomeGroup, numberOfStoriesLabel;

#pragma mark - PARSE METHODS
- (id)initWithUser:(PFUser *)aUser {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.user = aUser;
        
        if (!aUser) {
            [NSException raise:NSInvalidArgumentException format:@"PAPAccountViewController init exception: user cannot be nil"];
        }
        
    }
    return self;
}

// Parse requires initWithCoder when using storyboards
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Testimonies"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"Testimonies";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // The number of user stories to show per page
        self.objectsPerPage = 5;
    }
    return self;
}
// Search parse for Stories to be displayed withing the table
- (PFQuery *)queryForTable {
    // If this is not the current user, do not return anythign
    if (![PFUser currentUser])
    {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    // Find all stories on Parse
    PFQuery* query = [PFQuery queryWithClassName:self.parseClassName];
    // Where the current user is the author or passed in user
    if (self.user == nil) {
        self.user = [PFUser currentUser];
    }
    [query whereKey:@"author" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    return query;
}

#pragma mark - LOADING METHODS
- (void)viewDidLoad
{
    // Add the background image to the view
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MainBg"]];
    
    // Initialize the two buttons for editing and saving the user's profile data
    editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(switchToEditProfile)];
    self.navigationItem.rightBarButtonItem = editBtn;
    
    saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAndUpdateUserProfile)];
    
    cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditProfile)];
    
    // Set default for edit profile button
    editProfile = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateUserProfileInfo];
    [headerView setNeedsDisplay];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
}

-(void)updateUserProfileInfo
{
    PFQuery* userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [userQuery includeKey:@"group"];
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         if (object)
         {
             // Get and set the user data for both the labels and textfields
             // USER NAME
             currentUsername = [object objectForKey:@"UsersFullName"];
             // set the new object data to view
             //NSLog(@"This user's name = %@", currentUsername);
             authorName.text = currentUsername;
             //editUserNameField.text = currentUsername;
             // USER LOCATION
             //currentLocation = [object objectForKey:@"UserLocation"];
             //editUserLocationField.text = currentLocation;
             //authorLocation.text = currentLocation;
             
             // Get number of stries
             //NSInteger numberOfStories = self.objects.count;
             //numberOfStoriesLabel.text = [NSString stringWithFormat:@"%d",numberOfStories];
             // HomeGroup
             PFObject* group = [object objectForKey:@"group"];
             NSString* homeGpString = [group objectForKey:@"groupHeader"];
             NSString* homegroup = [NSString stringWithFormat:@"  %@",[group objectForKey:@"groupHeader"]];
             if (homeGpString == nil) {
                 [authorHomeGroup setTitle:@"  Add a Home Group" forState:UIControlStateNormal];
                 [authorHomeGroup setTitle:@"  Add a Home Group" forState:UIControlStateSelected];
             } else {
                 [authorHomeGroup setTitle:homegroup forState:UIControlStateNormal];
                 [authorHomeGroup setTitle:homegroup forState:UIControlStateSelected];
             }
             // Create a file for the image
             PFFile* imageFile = [object objectForKey:@"profilePictureSmall"];
             // Set the corner radius
             authorPic.layer.cornerRadius = 8;
             // add and load the image
             authorPic.file = imageFile;
             [authorPic loadInBackground];
             // Keep it behind the cropped imageview
             authorPic.clipsToBounds = YES;
             // make sure the view is updated when it returns from the settings screen
             [headerView setNeedsDisplay];
             
         }
     }];
    PFQuery *query = [PFQuery queryWithClassName:@"Testimonies"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        numberOfStoriesLabel.text = [NSString stringWithFormat:@"%d",count];
        
    }];
    
}

#pragma mark - UITABLEVIEW DELEGATE
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    // If more stories are available
    if (indexPath.row == self.objects.count)
    {
        // Get the load more cell
        UITableViewCell* loadMoreCell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return loadMoreCell;
    }
    else
    {
        // Check what type of story we have
        NSString* mediaType = [object objectForKey:@"media"];
        // If it is a text, use the dext cell
        if ([mediaType isEqualToString:@"text"])
        {
            ProfileTextStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileTextCell"];
            if (cell != nil)
            {
                [cell setProfileTextStory:object];
            }
            return cell;
        }
        // Otherwise use the media cell
        else
        {
            ProfileMediaStoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"profileMediaCell"];
            if (cell != nil)
            {
                // Set the remaining object details
                [cell setProfileMediaStory:object];
            }
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the selection placed on the cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Set the load more cell when the user has additional stories
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    return cell;
}


-(IBAction)toggleTableViews:(UIButton*)button
{
    if (button.tag == 0)
    {
        // This is the main feed
        storiesButton.selected = YES;
        followersButton.selected = NO;
        followingButton.selected = NO;
        
    }
    else if (button.tag == 1)
    {
        // Pull list of followers
        storiesButton.selected = NO;
        followersButton.selected = YES;
        followingButton.selected = NO;
    }
    else if (button.tag == 2)
    {
        // Pull list of following
        storiesButton.selected = NO;
        followersButton.selected = NO;
        followingButton.selected = YES;
    }

}
/*
#pragma mark - TEXTFIELD DELEGATE
// Move the user to the next field or remove the keyboard when done editing
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(textField == editUserNameField)
    {
        [editUserLocationField becomeFirstResponder];
    }
    else if (textField == editUserLocationField)
    {
        [editUserLocationField resignFirstResponder];
    }
    return NO;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if this is the load more cell
    if (indexPath.row >= self.objects.count)
    {
        return 44.0f;
    }
    else
    {
        // height for remaining cells
        return 100.0f;
    }
}

#pragma mark - EDIT AND SAVE PROFILE METHODS
-(void)switchToEditProfile
{
    // Display the editing fields
    editProfilePictureBtn.hidden = NO;
    //editUserNameField.hidden = NO;
    //editUserLocationField.hidden = NO;
    
    // change the nav buttons
    self.navigationItem.rightBarButtonItem = saveBtn;
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    // reset the image book
    imageWasUpdated = NO;
}

-(void)cancelEditProfile
{
    // clear the cells and remove the fields and button
    //editUserLocationField.text = @"";
    //editUserLocationField.hidden = YES;
    //editUserNameField.text = @"";
    //editUserNameField.hidden = YES;
    editProfilePictureBtn.hidden = YES;
    // change the nav button back
    self.navigationItem.rightBarButtonItem = editBtn;
    self.navigationItem.leftBarButtonItem = menuBtn;
    
}
-(void)saveAndUpdateUserProfile
{
    BOOL needToSave = NO;
    // check the fields to see if anything was entered
    //NSString* enteredName = editUserNameField.text;
    //NSString* enteredLocation = editUserLocationField.text;
    PFUser *user = [PFUser currentUser];
    //[user setObject:imageFile forKey:@"profilePic"];
    
    // Make sure the user's full name is not empty
    /*
    if ([enteredName isEqualToString:@""])
    {
        // Alert user the field cannot be empty
        [[[UIAlertView alloc] initWithTitle:@"User Name Missing" message:@"You must have a name to use Engage." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    }
    else
    {
     
        // Make sure this is a new name
        if (![enteredName isEqualToString:currentUsername])
        {
            //NSLog(@"This is a new name");
            needToSave = YES;
            [user setObject:enteredName forKey:@"UsersFullName"];
        }
        // Make sure the location is not blank or the same as before
        if ((![enteredLocation isEqualToString:@""]) && (![enteredLocation isEqualToString:currentUsername]))
        {
            // If not, get this info
            // NSLog(@"This is a new location");
            needToSave = YES;
            [user setObject:enteredLocation forKey:@"UserLocation"];
        }
    */
        if (imageWasUpdated)
        {
            needToSave = YES;
            PFFile* newProfilePic = [PFFile fileWithData:imageData];
            [user setObject:newProfilePic forKey:@"profilePictureSmall"];
        }
        if (needToSave)
        {
            // Show HUD view as we update this user
            [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
            // Save the user information
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                // When done, remove the hud
                // Show HUD view as we save this user
                [MBProgressHUD hideAllHUDsForView:self.view.superview animated:YES];
                if (succeeded)
                {
                    
                    // clear the cells and remove the fields and button
                /*    editUserLocationField.text = @"";
                    editUserLocationField.hidden = YES;
                    editUserNameField.text = @"";
                    editUserNameField.hidden = YES;*/
                    editProfilePictureBtn.hidden = YES;
                    // change the nav button back
                    self.navigationItem.rightBarButtonItem = editBtn;
                    self.navigationItem.leftBarButtonItem = menuBtn;
                    // And update the view
                    [self updateUserProfileInfo];
                }
            }];
        }
        else
        {
            // Reset back to normal as we are not saving anything
            //editUserLocationField.hidden = YES;
            //editUserNameField.hidden = YES;
            editProfilePictureBtn.hidden = YES;
            // change the nav button back
            self.navigationItem.rightBarButtonItem = editBtn;
        }
   // }
}


-(IBAction)userTapsEditPicture:(UIButton*)button
{
    // Launch the camera
    pickerVC = [[UIImagePickerController alloc] init];
    if (pickerVC != nil)
    {
        // Get the camera and set it for editing
        pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerVC.allowsEditing = TRUE;
        pickerVC.delegate = self;
        // present the camera
        [self presentViewController:pickerVC animated:YES completion:nil];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //NSLog(@"%@", info.description);
    // get the edited image
    UIImage* profileImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (profileImage != nil) {
        // Crop the image corners and make it the right size
        UIImage* updatedImage = [profileImage thumbnailImage:75 transparentBorder:0 cornerRadius:8 interpolationQuality:kCGInterpolationMedium];
        // Create a png of this image for the view
        imageData = UIImagePNGRepresentation(updatedImage);
        [picker dismissViewControllerAnimated:YES completion:^{
            // Add the image to the view and change the image bool
            authorPic.image = updatedImage;
            imageWasUpdated = YES;
            
        }];
        
    }
}

#pragma mark - NAVIGATION METHODS
/*
-(IBAction)navButtonClick:(UIBarButtonItem*)button
{
    // Move to Settings view
    [self performSegueWithIdentifier:@"segueToSettings" sender:button];
    
}
*/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToSettings"] )
    {
        // Just continue the segue
    }
    else
    {
        // Get the row that triggered the segue, and the story in it
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        PFObject* thisStory = [self.objects objectAtIndex:indexPath.row];
        // Get the segue to the right view
        if ([segue.identifier isEqualToString:@"segueForMediaDetail"] )
        {
            // Pass the story to the detail view controller
            ProfileStoryDetailViewController* profileVC = segue.destinationViewController;
            profileVC.selectedObject = thisStory;
        }
        else if ([segue.identifier isEqualToString:@"segueForTextDetail"])
        {
            ProfileTextDetailViewController* textStoryDVC = segue.destinationViewController;
            textStoryDVC.selectedObject = thisStory;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Change status bar to dark text color
- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


@end
