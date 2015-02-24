//
//  AppDelegate.m
//  Engage
//
//  Created by Angela Smith on 8/17/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PanelViewController.h"
#import "LogInViewController.h"
#import "DataHelper.h"
#import "Utility.h"
#import "Cache.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "GroupRegionsViewController.h"
#import "RootViewController.h"


@implementation AppDelegate
@synthesize followTimer, progressHud;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSLog(@"Launching application from app delegate");
    // PARSE SOCIAL
    [Parse setApplicationId:@"3ifWZJRVr3Gv7SIvM1KCseAt8c0FPAKY0sPH6x2j"
                  clientKey:@"v8Ne000q83DP8xnae5YoE4aSBM5LjsFeKr1sLfs9"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // SET FACEBOOK OAUTH
    [PFFacebookUtils initializeFacebook];
    
    // Set default ACLs for parse so users can read data
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    // Override point for customization after application launch.
    
    // APPEARANCE
    // Change nav bar tint color
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.07 green:0.57 blue:0.76 alpha:1]];
    [self checkLogIn];
    userDefaults = [NSUserDefaults standardUserDefaults];
    return YES;
}

// FACEBOOK OAUTH
// Facebook Test User Log In
// email:       sherlock_cpfkskw_holmes@tfbnw.net
// password:    sherlock
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

-(void)checkLogIn
{
    // NAVIGATION AND LOG IN
    // Check if user is logged in or not
    if (![PFUser currentUser])
    {
        [self switchToLogInView];
    }
    else
    {
        // see if home group has been set
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* groupString = [defaults objectForKey:@"HomeGroupSet"];
        //NSLog(@"Group string = %@", groupString);
        if (([groupString isEqualToString:@"inGroup"]) ||([groupString isEqualToString:@"noGroup"])) {
            //NSLog(@"Group string has been set");
            [self switchToMainView];
            }
        else {
            //NSLog(@"Group string has not been set");
            // Run a user check
            PFQuery* userQuery = [PFUser query];
            [userQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
            [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                // this is a previously registered user
                if (object)
                {
                    // Find out if this is a new user by checkinf if permission default was set
                    NSString* homeGroupName = [object objectForKey:@"group"];
                    NSLog(@"Home Group = %@", homeGroupName);
                    if (homeGroupName != nil) {
                        NSLog(@"Home group set");
                        [userDefaults setObject:@"inGroup" forKey:@"HomeGroupSet"];
                        [userDefaults synchronize];
                        [self switchToMainView];
                    } else {
                        NSLog(@"Need to set home group");
                        needToSelectHomeGroup = true;
                        [self loadHomeGroupSelect];
                    }
                }
            }];

        }
    }
}
// MILESTONE 1:3 (Facebook Log In), and 1:6 (manual and facebook email match error)
// WHEN USER LOG IN IS SUCCESSFUL
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    // Check to see if user is linked with facebook
    BOOL userLinkedWithFacebook = [PFFacebookUtils isLinkedWithUser:user];
    needToSelectHomeGroup = false;
    if (userLinkedWithFacebook)
    {
        //NSLog(@"The user logged in through Facebook");
        // If the user is linked, make a request for their data
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 // get the result
                 NSLog(@"%@", result);
                 facebookUserName = [result objectForKey:@"name"];
                 facebookUserEmail = [[result objectForKey:@"email"] lowercaseString]; // For case insensitivity
                 NSString* userId = [result objectForKey:@"id"];
                 // get the user's current profile picture
                 NSURL* userProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",userId]];
                 // Make the request for the image, and set it to expire in 10 days (per Facebook policy)
                 NSURLRequest* profilePicURLRequest = [NSURLRequest requestWithURL:userProfilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
                 // Send the request
                 [NSURLConnection connectionWithRequest:profilePicURLRequest delegate:self];
                 // Use the NSURLConnectionDataDelegate to get the data
                 
                 // Make a query to verify that the user has not tried to connect with a Facebook email address that was user to register manually
                 PFQuery* userQuery = [PFUser query];
                 [userQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
                 [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                     // this is a previously registered user
                     if (object)
                     {
                         // Find out if this is a new user by checkinf if permission default was set
                         NSString* permissionString = [object objectForKey:@"sharePermission"];
                         NSString* fbLinkable = [object objectForKey:@"FBLinkable"];
                         NSString* homeGroupName = [object objectForKey:@"group"];
                         //NSLog(@"Permission = %@, Facebook linkable = %@, Home Group = %@", permissionString, fbLinkable, homeGroupName);
                         needToSelectHomeGroup = false;
                         if (homeGroupName != nil) {
                             NSLog(@"Home group set");
                             [userDefaults setObject:@"inGroup" forKey:@"HomeGroupSet"];
                             [userDefaults synchronize];
                             needToSelectHomeGroup = false;
                        } else {
                             //NSLog(@"Need to set home group");
                             needToSelectHomeGroup = true;
                             //[self loadHomeGroupSelect];
                         }
                         // If not there, this is a new user
                         if (permissionString == nil)
                         {
                             //NSLog(@"This is a new user");
                             // User this persons facebook name, email, and id to register them
                             user.email = facebookUserEmail;
                             [user setObject:facebookUserName forKey:@"UsersFullName"];
                             [user setObject:userId forKey:@"facebookId"];
                             [user setObject:@"NO" forKey:@"sharePermission"];
                             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                 if (error) {
                                     
                                     // If the error code is 203, then we already have this user's email in the database, alert the user they can connect this account in settings (prevents double log ins)
                                     NSLog(@"%ld", (long)error.code);
                                     if (error.code == 203)
                                     {
                                         // this email is already registered
                                         [[[UIAlertView alloc] initWithTitle:@"Wow, you're awesome!"  message:@"Looks like you have registered already. You can sign in with your username then link to Facebook in your Profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                     }
                                     // delete the user that was created as part of Parse's Facebook login
                                     [user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (succeeded)
                                         {
                                             // Remove Facebook information too
                                             [[FBSession activeSession] closeAndClearTokenInformation];
                                         }
                                     }];
                                 } else if (succeeded)
                                 {
                                     [userDefaults setObject:@"NO" forKey:@"sharePermission"];
                                     [userDefaults synchronize];
                                     //NSLog(@"saving %@ for full name, and %@ for email", facebookUserName, facebookUserEmail);
                                     // Get their list of friends
                                     [self findFacebookFriends];
                                     // Finally, close the log in view and present the next view
                                     //[self facebookRequestDidLoad:result];
                                     if (needToSelectHomeGroup) {
                                         // load home group page
                                         [self loadHomeGroupSelect];
                                     } else {
                                         //switch to main view
                                         [self switchToMainView];
                                     }
                                 }
                             }];
                             
                         }
                         else
                         {
                             //NSLog(@"This person already registered");
                             // Update the cache with their facebook friends
                             [self findFacebookFriends];
                             // This person already registered, update the user permission default for this device
                             [userDefaults setObject:permissionString forKey:@"sharePermission"];
                             [userDefaults setObject:fbLinkable forKey:@"FBLinkable"];
                             [userDefaults synchronize];
                             if (needToSelectHomeGroup) {
                                 // load home group page
                                 [self loadHomeGroupSelect];
                             } else {
                                 //switch to main view
                                 [self switchToMainView];
                             }
                         }
                         
                     }
                 }];
             }
             else
                 //Find out what went wrong
             {
                 NSLog(@"%@", error);
             }
         }];
    }
    else if (!userLinkedWithFacebook)
    {   // User logged in manually, find their current permission and fblinkable status
        //NSLog(@"The user logged in manually");
        
        PFQuery* userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            // this is a previously registered user
            if (object)
            {
                // Update the nsuser defaults
                NSString* permissionString = [object objectForKey:@"sharePermission"];
                NSString* fbLinkable = [object objectForKey:@"FbLinkable"];
                NSString* homeGroupName = [object objectForKey:@"group"];
                //NSLog(@"Permission = %@, Facebook linkable = %@, Home Group = %@", permissionString, fbLinkable, homeGroupName);
                [userDefaults setObject:permissionString forKey:@"sharePermission"];
                [userDefaults setObject:fbLinkable forKey:@"FBLinkable"];
                [userDefaults synchronize];
                if (homeGroupName != nil) {
                    needToSelectHomeGroup = false;
                    [userDefaults setObject:@"inGroup" forKey:@"HomeGroupSet"];
                    [userDefaults synchronize];
                } else {
                    //NSLog(@"Need to set home group");
                    needToSelectHomeGroup = true;
                }
                if (needToSelectHomeGroup) {
                    //NSLog(@"Loading Home Group");
                    // load home group page
                    [self loadHomeGroupSelect];
                } else {
                    //NSLog(@"Loading Main View");
                    //switch to main view
                    [self switchToMainView];
                }
            }
        }];
    }
}



-(void)loadHomeGroupSelect
{
    //NSLog(@"Loading test view from App Delegate");
    GroupRegionsViewController* regionsTVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupRegionsVC"];
    self.window.rootViewController = regionsTVC;
}

-(void)switchToMainView
{
    RootViewController* rootVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootView"];
    self.window.rootViewController = rootVC;
}

-(void)switchToLogInView
{
    // Create the log in screen, and set this as the delegate
    LogInViewController* logInVc = [[LogInViewController alloc] init];
    [logInVc setDelegate:self];
    
    // Add FACEBOOK Permissions and the fields for them
    logInVc.facebookPermissions = @[@"public_profile", @"email"];
    logInVc.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsFacebook | PFLogInFieldsLogInButton | PFLogInFieldsPasswordForgotten;
    self.window.rootViewController = logInVc;
}

-(void)logOutUser
{
    // Clear created NSUserDefaults
    [userDefaults removeObjectForKey:@"sharePermission"];
    [userDefaults removeObjectForKey:@"FBLinkable"];
    [userDefaults removeObjectForKey:@"HomeGroupSet"];
    [userDefaults synchronize];
    
    // Log out of parse
    [PFUser logOut];
    // Remove the stack
    //[self.navigationController popToRootViewControllerAnimated:NO];
    [self checkLogIn];
    // Move back to log in screen
    //AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //[appDelegate switchToLogInView];
    
    //UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UINavigationController* mainNavControl = [storyboard instantiateViewControllerWithIdentifier:@"launchNavController"];
    //[[UIApplication sharedApplication].keyWindow setRootViewController:mainNavControl];
}

// WHEN USER LOG IN FAILS
-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    // Find the error that was sent
    NSDictionary* errorDictionary = [error userInfo];
    // Get the error string
    NSString* errorString = [errorDictionary objectForKey:@"NSLocalizedDescription"];
    NSLog(@"The error is: %@", errorString);
    // Alert the user there was a problem logging in
    [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Email and Password are not valid. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
/*

// When the user wants to sync facebook data on the settings view
-(void)updateFacebookDataForUser:(PFUser*)user
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (!error)
         {
             // get the returned data
             NSLog(@"%@", result);
             facebookUserName = [result objectForKey:@"name"];
             facebookUserEmail = [[result objectForKey:@"email"] lowercaseString]; // For case insensitivity
             NSString* userId = [result objectForKey:@"id"];
             NSString* currentUserId = [user objectForKey:@"facebookId"];
             // make sure we have the right user
             if ([userId isEqualToString:currentUserId])
             {
                 // Update the remaining data
                 // get the user's current profile picture
                 NSURL* userProfilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",userId]];
                 // Make the request for the image with the timeout interval
                 NSURLRequest* profilePicURLRequest = [NSURLRequest requestWithURL:userProfilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
                 // Send the request
                 [NSURLConnection connectionWithRequest:profilePicURLRequest delegate:self];
                 // Use the NSURLConnectionDataDelegate to get the data
                 
                 user.email = facebookUserEmail;
                 [user setObject:facebookUserName forKey:@"UsersFullName"];
                 [user setObject:userId forKey:@"facebookId"];
                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (error)
                     {
                         NSLog(@"%ld", (long)error.code);
                     }
                     else if (succeeded)
                     {
                         NSLog(@"User data was updated");
                     }
                 }];
             }
         }
         else
         {
             //Find out what went wrong
             NSLog(@"%@", error);
         }
     }];    
}
*/
-(void)findFacebookFriends {
    //NSLog(@"Finding Users Facebook friends");
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            //NSLog(@"facebook friends in cache: %@", friendObjects.description);
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            // cache friend data
            [[Cache sharedCache] setFacebookFriends:friendIds];
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            //PFQuery *friendQuery = [PFUser query];
            //[friendQuery whereKey:@"fbId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
           // NSArray *friendUsers = [friendQuery findObjects];
            // cache friend data
            //[[Cache sharedCache] setFacebookFriends:friendUsers];
        }
    }];
}
/*
- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    NSArray *data = [result objectForKey:@"data"];
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[Cache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if ([user objectForKey:@"facebookFriends"]) {
                [user removeObjectForKey:@"facebookFriends"];
            }
            
            if (![user objectForKey:@"autoFollowFB"]) {
                // self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                //   firstLaunch = YES;
                
                [user setObject:@YES forKey:@"autoFollowFB"];
                NSError *error = nil;
                
                // find common Facebook friends already using Engage
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:@"facebookId" containedIn:facebookIds];
                
                // auto-follow Main Engage Group
                PFQuery* mainEngageQuery = [PFUser query];
                [mainEngageQuery whereKey:@"objectId" equalTo:@"etU15Wombo"];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:facebookFriendsQuery, mainEngageQuery, nil]];
                
                NSArray* engageFriends = [query findObjects:&error];
                NSLog(@"Engage Friends: %@", engageFriends.description);
                
                if (!error) {
                    [engageFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:@"Activity"];
                        [joinActivity setObject:user forKey:@"fromUser"];
                        [joinActivity setObject:newFriend forKey:@"toUser"];
                        [joinActivity setObject:@"joined" forKey:@"activityType"];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [Utility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.followTimer) {
                                    [self.followTimer invalidate];
                                }
                                
                                //self.followTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                //                if (![self shouldProceedToMainInterface:user]) {
                //                    [self logOut];
                //                    return;
                //                }
                //
                //                if (!error) {
                //                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                //                    if (anypicFriends.count > 0) {
                //                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                //                        self.hud.dimBackground = YES;
                //                        self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                //                    } else {
                //                        [self.homeViewController loadObjects];
                //                    }
                //                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            // [self logOut];
        }
    } else {
        progressHud.labelText = NSLocalizedString(@"Creating Profile", nil);
        
        if (user) {
            //            NSString *facebookName = result[@"name"];
            //            if (facebookName && [facebookName length] != 0) {
            //                [user setObject:facebookName forKey:@"displayName"];
            //            } else {
            //                [user setObject:@"Someone" forKey:@"displayName"];
            //            }
            if ([user objectForKey:@"UserProfileName"] == nil) {
                // set the name until the city is found
                [user setObject:result[@"name"] forKey:@"UserProfileName"];
            }
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:@"facebookId"];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                // [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}
*/

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


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Facebook callback
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
