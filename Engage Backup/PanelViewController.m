//
//  PanelViewController.m
//  Test Engage
//
//  Created by Angela Smith on 8/17/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "PanelViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface PanelViewController ()
@end

@implementation PanelViewController

@synthesize userName, userProfileImage, userProfileNameLabel, homeGroupName, userObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    // FIRST VERIFY USER IS LOGGED IN
    // If the user is not logged in
    if (![PFUser currentUser]){
        NSLog(@"User is NOT logged in as current user, Presenting the log in screen");
        // Move to the log in screen
        [self viewLoginScreen];
    }
    
    else  {
        NSLog(@"User is logged in, checking user object");
        // SECOND, VERIFY USER HAS A HOME GROUP SELECTED
        //if (userObject == nil) {
          //  [self getUserProfileValues];
        //}
        //else {
            [self loadUser];
        //}
    }
}

-(void)loadUser
{
    NSLog(@"Loading User Data");
    // Check if the default has been set
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* groupString = [userDefaults objectForKey:@"HomeGroupSet"];
    if ((![groupString isEqualToString:@"inGroup"]) ||(![groupString isEqualToString:@"noGroup"])) {
        // NSUSER DEFAULT NOT SET
        // we need to launch the selece a home group page
        [self viewHomeGroupSelectView];
    } else {
        NSLog(@"ready to load controller");
        // reset the controller
        //self.airMenuController = nil;
        //[self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        // Open the main view
                /*
        // and set the views
        PFFile* userImageFile = [userObject objectForKey:@"profilePictureSmall"];
        userProfileImage.file = userImageFile;
        [userProfileImage loadInBackground];
        userName = [userObject objectForKey:@"UserProfileName"];
        userProfileNameLabel.text = userName;
         */
    }
}
-(void)getUserProfileValues
{
    NSLog(@"Getting user object info");\
    PFQuery* userInfoQuery = [PFUser query];
    [userInfoQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [userInfoQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        // this is a previously registered user
        if (object)
        {
            // set the user object
            userObject = object;
        }
    }];
    [self loadUser];
}

-(void)viewHomeGroupSelectView
{
    // switch to the main view to have the user select a group
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate loadHomeGroupSelect];
}

#pragma mark LOG IN METHODS
// LOAD LOG IN SCREEN
-(void)viewLoginScreen
{
    // Create the log in view controller
    //LogInViewController *logInViewController = [[LogInViewController alloc] init];
    LogInViewController* logInVc = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"logInVC"];
    [logInVc setDelegate:self]; // Set ourselves as the delegate
    logInVc.facebookPermissions = @[@"public_profile", @"email"];
    logInVc.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten;
    
    // Present the log in view controller
    [self presentViewController:logInVc animated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
