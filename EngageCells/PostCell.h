//
//  PostCell.h
//  EngageCells
//
//  Created by Angela Smith on 1/30/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>
#import "ProfileImageView.h"
#import "STTweetLabel.h"


@protocol PostCellDelegate;

static NSString *aStoryKey   = @"story";
static NSString *aTitleKey    = @"title";
static NSString *aUserKey   = @"author";
static NSString *aAuthorName    = @"UsersFullName";
static NSString *aProfilePictureId = @"profilePictureSmall";
static NSString *aCellIdentifier = @"storyCellId";

@interface PostCell : PFTableViewCell {
    NSUInteger horizontalTextSpace;
    id _delegate;
}

@property (nonatomic, strong) id delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser* storyAuthor;
@property (nonatomic) PFObject* postStory;

@property (weak, nonatomic) IBOutlet UIButton* sAuthorButton;
@property (weak, nonatomic) IBOutlet UIButton* sLocalButton;
@property (nonatomic, strong) UIView* sMainView;
@property (nonatomic, strong) UIButton* sAvatarImageButton;
@property (nonatomic, strong) ProfileImageView* sAvatarImageView;
@property (nonatomic, strong) UILabel* sTitleLabel;
@property (nonatomic, strong) STTweetLabel* sStoryTextLabel;
@property (nonatomic, strong) UILabel* sTimeLabel;
/*! The horizontal inset of the cell */
@property (nonatomic) CGFloat cellInsetWidth;

/*! Setters for the cell's content */
//- (void)setContentText:(NSString *)contentString;
//- (void)setDate:(NSDate *)date;

- (void)setCellInsetWidth:(CGFloat)insetWidth;
//- (void)hideSeparator:(BOOL)hide;

/*! Static Helper methods */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content;
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset;
//+ (NSString *)padString:(NSString *)string withFont:(UI
//+ (void)setTableViewWidth:(CGFloat)tableWidth;
//+ (id)storyPostCellForTableWidth:(CGFloat)width;
- (void)configurePostCellForStory:(PFObject *)story;
//+ (CGFloat)cellHeightForCell:(NSString *)text title:(NSString *)title;
//+ (CGFloat)heightForTitle:(NSString *)title;
//+ (CGFloat)heightForText:(NSString *)text;
@end

#define vertBorderSpacing 8.0f
#define vertElemSpacing 0.0f

#define horiBorderSpacing 8.0f
#define horiBorderSpacingBottom 9.0f
#define horiElemSpacing 5.0f

#define vertTextBorderSpacing 10.0f

#define avatarX horiBorderSpacing
#define avatarY vertBorderSpacing
#define avatarDim 33.0f

#define nameX avatarX+avatarDim+horiElemSpacing
#define nameY vertTextBorderSpacing
#define nameMaxWidth 200.0f

#define timeX avatarX+avatarDim+horiElemSpacing

/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */

@protocol PostCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(PostCell *)cellView didTapUserButton:(PFUser *)aUser;

@end
