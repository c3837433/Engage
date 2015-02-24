//
//  ProfileImageView.h
//  Engage
//
//  Created by Angela Smith on 1/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ProfileImageView : PFImageView

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) PFImageView *profileImageView;

- (void)setFile:(PFFile *)file;
- (void)setImage:(UIImage *)image;

@end
