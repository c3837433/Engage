//
//  UserProfileImageView.h
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageView.h"
#import <ParseUI/ParseUI.h>

@interface UserProfileImageView : UIView

@property (nonatomic, strong) UIButton* profileButton;
@property (nonatomic, strong) PFImageView* profileImageView;

- (void)setProfileImageFile:(PFFile *)profileFile;
- (void)setProfileImage:(UIImage *)profileImage;

@end
