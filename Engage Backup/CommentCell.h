//
//  CommentCell.h
//  Engage
//
//  Created by Angela Smith on 7/18/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>

@interface CommentCell : PFTableViewCell
{

}
@property (nonatomic, strong) IBOutlet UILabel* commentAuthor;
@property (nonatomic, strong) IBOutlet UILabel* commentTime;
@property (nonatomic, strong) IBOutlet UILabel* commentText;
@property (nonatomic, strong) IBOutlet PFImageView* commentAuthorPic;

-(void)setComment:(PFObject*)story;

@end
