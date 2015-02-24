//
//  UserProfileImageView.m
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "UserProfileImageView.h"
#import "ParseUI/ParseUI.h"

@implementation UserProfileImageView
@synthesize profileButton, profileImageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.profileImageView = [[PFImageView alloc] initWithFrame:frame];
        [self addSubview:self.profileImageView];
        
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.profileButton];
        
       // [self addSubview:self.borderImageview];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    //[self bringSubviewToFront:self.borderImageview];
    
    self.profileImageView.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    //self.borderImageview.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}


#pragma mark - ProfileImageView
- (void)setProfileImageFile:(PFFile *)profileFile {
    if (!profileFile) {
        return;
    }
    self.profileImageView.image = [UIImage imageNamed:@"placeholder"];
    self.profileImageView.file = profileFile;
    [self.profileImageView loadInBackground];

}

- (void)setProfileImage:(UIImage *)profileImage {
     self.profileImageView.image = profileImage;
}
@end
