//
//  SettingsTableViewController.m
//  Engage
//
//  Created by Angela Smith on 8/10/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "SettingsTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DataHelper.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    
     [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* linkable = [userDefaults objectForKey:@"FBLinkable"];
    // IF the user is linkable, then they can link
    canLink = (linkable) ? YES : NO;
    user = [PFUser currentUser];
    // See if the current user is connected with Facebook yet
    connectedToFacebook = ([PFFacebookUtils isLinkedWithUser:user]) ? YES : NO;
    // check if the user is connected to facebook (for sync button)
    
    // Set up the toggle button
    [self setUpFacebookToggle];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TABLEVIEW DATA SOURCE METHODS
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (connectedToFacebook)
        {
            return 2;
        }
        return 1;
    }
    return  1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Change the color of the header text in each section
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.textColor = [UIColor colorWithRed:0.07 green:0.57 blue:0.76 alpha:1];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (canLink)
    {
        // keep it the same
        return [super tableView:tableView heightForHeaderInSection:section];
    }
    else
    {
        // Hide the first section
        if (section == 0)
        {
            return 0;
        }
        else
        {
            // keet it the same
            return [super tableView:tableView heightForHeaderInSection:section];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            // Updating user information
            //NSLog(@"Updating user information");
            [self updateFacebookDataForUser];
        }
        // toggle connect to facebook
    }
    else if (indexPath.section == 1)
    {
        // log out the user
        [self logOutUser];
    }
}

-(void)setUpFacebookToggle
{
    // Set switch based on whether the user is logged in with facebook or not
    // See if the current user is connected with Facebook yet
    if (![PFFacebookUtils isLinkedWithUser:user])
    {
        //NSLog(@"They can connect, toggle should be off");
        [toggleFBConnect setOn:FALSE animated:TRUE];
        
    }
    else if ([PFFacebookUtils isLinkedWithUser:user])
    {
        //NSLog(@"They are connected, toggle should be on");
        [toggleFBConnect setOn:TRUE animated:TRUE];
        
    }
}

- (IBAction)linkToFacebook:(id)sender
{
    /*
     NSString* linkable = [userDefaults objectForKey:@"FBLinkable"];
     if (![linkable isEqualToString:@"YES"])
     {
     [[[UIAlertView alloc] initWithTitle:@"Unable to Disconnect" message:@"Sorry, this account was registered through Facebook and can not be unlinked." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
     }
     */
    if (![PFFacebookUtils isLinkedWithUser:user])
    {
        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 NSLog(@"Connected user with Facebook!");
                 [toggleFBConnect setOn:TRUE animated:TRUE];
                 // reload the table so the sync buton is available
                 [settingsTable reloadData];
             }
             else
             {
                 NSLog(@"Error connecting user with Facebook!");
                 [toggleFBConnect setOn:FALSE animated:TRUE];
                 // If this email does not match the current one
                 if (error.code == 208)
                 {
                     // Alert user
                     [[[UIAlertView alloc] initWithTitle:@"Different Accounts"  message:@"The current Facebook account does not match the registered email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 }
             }
         }];
    }
    // When the user is linked with Facebook already
    else if ([PFFacebookUtils isLinkedWithUser:user])
    {
        
        [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL Success,NSError *unlinkError)
         {
             if(!unlinkError)
             {
                 NSLog(@"Disconnected user with Facebook!");
                 [toggleFBConnect setOn:FALSE animated:TRUE];
                 // reload table to hide sync button
                 [settingsTable reloadData];
             }
             else
             {
                 NSLog(@"Error disconnecting user with Facebook!");
                 [toggleFBConnect setOn:TRUE animated:TRUE];
             }
         }];
    }
    [self.view setNeedsDisplay];
    [settingsTable reloadData];
}
// When the user wants to sync facebook data on the settings view
-(void)updateFacebookDataForUser
{
    // Show HUD view as the data is gathered
    [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    // Get the current user from parse
    PFQuery* query = [PFUser query];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    NSLog(@"Making query");
    [query getFirstObjectInBackgroundWithBlock:^(PFObject* userInfo, NSError* queryError) {
        if (!queryError) {
            NSLog(@"No query error");
            // Get the Facebook Data
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
             {   NSLog(@"Getting Result");
                 if (!error)
                 {
                     // get the returned data
                     NSLog(@"%@", result);
                     NSString* facebookUserName = [result objectForKey:@"name"];
                     NSString* facebookUserEmail = [[result objectForKey:@"email"] lowercaseString]; // For case insensitivity
                     NSString* userId = [result objectForKey:@"id"];
                     // Update the remaining data
                     // get the user's current profile picture
                     NSURL* userProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",userId]];
                     // Make the request for the image with the timeout interval
                     NSURLRequest* profilePicURLRequest = [NSURLRequest requestWithURL:userProfilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
                     // Send the request
                     [NSURLConnection connectionWithRequest:profilePicURLRequest delegate:self];
                     // Use the NSURLConnectionDataDelegate to get the data
                     
                     [userInfo setObject:facebookUserEmail forKey:@"email"];
                     [userInfo setObject:facebookUserName forKey:@"UsersFullName"];
                     NSLog(@"Saving info");
                     [userInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (error)
                         {
                             NSLog(@"%ld", (long)error.code);
                             // Alert user
                             [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"We are unable to sync your profile with Facebook right not. Try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil]show];
                             // Deselect the row
                             [settingsTable deselectRowAtIndexPath:[settingsTable indexPathForSelectedRow] animated:YES];
                         }
                         else if (succeeded)
                         {
                             //NSLog(@"User data was updated");
                             // Alert user
                             [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Great! Your Engage profile was synced with Facebook" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil]show];
                             // Deselect the row
                             [settingsTable deselectRowAtIndexPath:[settingsTable indexPathForSelectedRow] animated:YES];
                             
                         }
                     }];
                     // Remove the hud
                     [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
                 } else
                 {
                     NSLog(@" Error = %@", error);
                 }
             }];
            
            // Save
            //[userInfo saveInBackground];
        } else {
            // Error for query
            NSLog(@"Error: %@", queryError);
        }
        
    }];
}

#pragma mark - NSURLConnectionDataDelegate
// If the user profile image data came back, begin creating the data object
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    facebookUserProfilePictureData = [[NSMutableData alloc] init];
}

// Add any new data to the object until it is completed
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [facebookUserProfilePictureData appendData:data];
}

// When the data has finished loading, save this to the current user
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Save the image to the current user
    [DataHelper saveFacebookImageData:facebookUserProfilePictureData];
}

-(void)logOutUser
{
    // Clear created NSUserDefaults
  //  [userDefaults removeObjectForKey:@"sharePermission"];
  //  [userDefaults removeObjectForKey:@"FBLinkable"];
  //  [userDefaults removeObjectForKey:@"HomeGroupSet"];
  //  [userDefaults synchronize];
    // Log out of parse
   // [PFUser logOut];
    // Remove the stack
    [self.navigationController popToRootViewControllerAnimated:NO];
    // Move back to log in screen
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //[appDelegate switchToLogInView];
    [appDelegate logOutUser];
    
    //UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UINavigationController* mainNavControl = [storyboard instantiateViewControllerWithIdentifier:@"launchNavController"];
    //[[UIApplication sharedApplication].keyWindow setRootViewController:mainNavControl];
}

@end
