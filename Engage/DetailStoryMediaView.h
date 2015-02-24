//
//  DetailStoryMediaView.h
//  Engage
//
//  Created by Angela Smith on 7/21/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface DetailStoryMediaView : UIView

@property (nonatomic, strong) IBOutlet PFImageView* storyImage;
@property (nonatomic, strong) PFFile* mediaImageFile;
@property (nonatomic, strong) NSString* mediaType;
@property (nonatomic, strong) PFFile* videoFile;
@property (nonatomic, strong) IBOutlet UIButton* playMovieButton;

-(void)setDetailStoryMedia:(PFObject*)story;
+ (id)detailMediaView;
@end
