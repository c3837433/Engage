//
//  AppDelegate.h
//  Engage Your City
//
//  Created by Angela Smith on 2/24/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "MBProgressHUD.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, NSURLConnectionDataDelegate>

{
    // User Name and email
    NSString* facebookUserName;
    NSString* facebookUserEmail;
    // URLRequest data for Facebook image
    NSMutableData* facebookUserProfilePictureData;
    NSUserDefaults* userDefaults;
    BOOL needToSelectHomeGroup;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSTimer* followTimer;
@property (nonatomic, strong) MBProgressHUD* progressHud;

@property (nonatomic, readonly) int networkStatus;

- (BOOL)isParseReachable;

-(void)switchToMainView;
-(void)checkLogIn;
//-(void)loadHomeGroupSelect;
-(void)switchToLogInView;
-(void)logOutUser;
@end