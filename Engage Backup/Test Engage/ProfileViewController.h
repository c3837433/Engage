//
//  ProfileViewController.h
//  Test Engage
//
//  Created by Angela Smith on 8/17/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : PFQueryTableViewController  <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate>

{
    BOOL editProfile;
    BOOL imageWasUpdated;
    UIBarButtonItem* editBtn;
    UIBarButtonItem* saveBtn;
    UIBarButtonItem* menuBtn;
    UIBarButtonItem* cancelBtn;
    NSString* currentUsername;
    NSString* currentLocation;
    UIImagePickerController* pickerVC;
    IBOutlet UITableView* userStoriesTableview;
    IBOutlet UIButton* storiesButton;
    IBOutlet UIButton* followersButton;
    IBOutlet UIButton* followingButton;
}
@property (nonatomic, strong) IBOutlet UILabel* authorName;
@property (nonatomic, strong) IBOutlet UILabel* numberOfStoriesLabel;
@property (nonatomic, strong) IBOutlet UIButton* authorHomeGroup;
//@property (nonatomic, strong) IBOutlet UILabel* authorLocation;
@property (nonatomic, strong) IBOutlet PFImageView* authorPic;
@property (nonatomic, strong) IBOutlet UIView* headerView;

@property (nonatomic, strong) IBOutlet UIButton* editProfilePictureBtn;
//@property (nonatomic, strong) IBOutlet UITextField* editUserNameField;
//@property (nonatomic, strong) IBOutlet UITextField* editUserLocationField;

@property (nonatomic, strong) NSData* imageData;

-(void)updateUserProfileInfo;
- (id)initWithUser:(PFUser *)aUser;
@property (nonatomic, strong) PFUser *user;

@end
