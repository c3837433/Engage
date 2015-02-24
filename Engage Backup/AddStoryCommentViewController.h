//
//  AddStoryCommentViewController.h
//  Test Engage
//
//  Created by Angela Smith on 8/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "StoryDetailsInfoHeaderView.h"

@interface AddStoryCommentViewController : PFQueryTableViewController <UITextFieldDelegate>

@property (nonatomic, strong) PFObject* thisStory;
@property (nonatomic, strong) IBOutlet StoryDetailsInfoHeaderView* headerView;
@property (nonatomic, strong) UITextField *commentTextField;

- (id)initWithStory:(PFObject*)story;

@end
