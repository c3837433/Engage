//
//  CommentCell.h
//  Engage
//
//  Created by Angela Smith on 7/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@protocol CommentCellDelegate;

@interface CommentCell : PFTableViewCell
{

}
@property (nonatomic, strong) IBOutlet UIButton* commentAuthorButton;
@property (nonatomic, strong) IBOutlet UILabel* commentTime;
@property (nonatomic, strong) IBOutlet UILabel* commentText;
@property (nonatomic, strong) IBOutlet PFImageView* commentAuthorPic;
@property (nonatomic, strong) IBOutlet UIButton* commentAuthorPicButton;
@property (nonatomic, strong) IBOutlet PFUser* thisCommentUser;

-(void)setComment:(PFObject*)story;

@property (nonatomic,weak) id <CommentCellDelegate> delegate;

@end

@protocol CommentCellDelegate <NSObject>

@optional

- (void)detailCommentCell:(CommentCell*)detailCommentCell didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end
