//
//  TextCell.h
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class UserProfileImageView;
@protocol TextCellDelegate;

@interface TextCell : UITableViewCell {
    NSUInteger horizontalSpace;
    id _delegate;
}

@property (nonatomic, strong) id delegate;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser* user;

/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
@property (nonatomic, strong) UIView* mainView;
@property (nonatomic, strong) UIButton* nameButton;
@property (nonatomic, strong) UIButton* userImageButton;
@property (nonatomic, strong) UserProfileImageView *userImageView;
@property (nonatomic, strong) UILabel* storyTitleLabel;
@property (nonatomic, strong) UIButton* homeGroupButton;
@property (nonatomic, strong) UILabel* storyTextLabel;
@property (nonatomic, strong) UILabel* timeStampLabel;
@property (nonatomic, strong) UIButton* likeButton;
@property (nonatomic, strong) UIButton* commentButton;
@property (nonatomic, strong) UIImageView* separatorImage;

/*! The horizontal inset of the cell */
@property (nonatomic) CGFloat cellInsetWidth;

/*! Setters for the cell's content */
- (void)setStoryText:(NSString *)contentString;
- (void)setTime:(NSDate *)date;
- (void)setstoryTitle:(NSString *)titleString;

- (void)setCellInsetWidth:(CGFloat)insetWidth;
- (void)hideSeparator:(BOOL)hide;

/*! Static Helper methods */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content;
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset;
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width;

@end

/*! Layout constants */
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
@protocol TextCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(TextCell *)cellView didTapUserButton:(PFUser *)aUser;

@end
