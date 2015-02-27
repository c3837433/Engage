//
//  PostImageCell.h
//  EngageCells
//
//  Created by Angela Smith on 2/15/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "PostTextCell.h"

@interface PostImageCell : PostTextCell

@property (nonatomic, strong) IBOutlet PFImageView* postImage;
@property (nonatomic, strong) IBOutlet UIButton* playButton;

-(void)setPostImageFrom:(PFObject*)post;

@end
