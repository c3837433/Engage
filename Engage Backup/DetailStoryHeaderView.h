//
//  DetailStoryHeaderView.h
//  Engage
//
//  Created by Angela Smith on 7/21/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DetailStoryHeaderView : UIView
@property (nonatomic, strong) IBOutlet UILabel* storyAuthor;
@property (nonatomic, strong) IBOutlet UILabel* storyTime;
@property (nonatomic, strong) IBOutlet UILabel* storyTitle;
@property (nonatomic, strong) IBOutlet UILabel* storyGroup;
@property (nonatomic, strong) IBOutlet PFImageView* storyAuthorPic;
@property (nonatomic, strong) IBOutlet UIButton* userButton;


-(void)setDetailHeaderInfo:(PFObject*)story;
+ (id)detailHeaderView;
@end
