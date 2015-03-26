//
//  CustomAdminCreateViewController.h
//  Engage Your City
//
//  Created by Angela Smith on 3/25/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@protocol AdminCreateDelegate <NSObject>

-(void) viewController:(UIViewController *)viewController returnRoleCreated:(BOOL)created withMessage:(NSString*)message;

@end
@interface CustomAdminCreateViewController : UIViewController  <UITextFieldDelegate> {

    IBOutlet UIButton* cancelButton;
    IBOutlet UIButton* searchButton;
    IBOutlet UIButton* createButton;
    IBOutlet UIView* userView;
}

@property (nonatomic, strong) IBOutlet UILabel* regionGroupLabel;
@property (nonatomic, strong) IBOutlet UILabel* searchUserLabel;

@property (nonatomic, strong) IBOutlet UITextField* nameField;
@property (nonatomic, strong) IBOutlet UITextField* userNameField;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* userEmailLable;
@property (nonatomic, strong) IBOutlet PFImageView* userProfileImageView;
@property (nonatomic, assign) BOOL showStatusBar;
@property (nonatomic) NSInteger viewType;
@property (nonatomic, strong) PFUser* chosenUser;
@property (nonatomic) BOOL hasUserChosen;


@property (nonatomic, weak) id <AdminCreateDelegate> delegate;

@end
