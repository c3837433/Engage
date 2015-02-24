//
//  TextCell.m
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "TextCell.h"
#import "UserProfileImageView.h"
#import "Utility.h"

@interface TextCell () {
    BOOL hideSeparator; // True if the separator shouldn't be shown
}

/* Private static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;
@end

@implementation TextCell

@synthesize mainView, nameButton, userImageButton, userImageView, cellInsetWidth, storyTextLabel, storyTitleLabel, timeStampLabel, separatorImage, delegate, user;



#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        // Initialization code

        
        cellInsetWidth = 0.0f;
        hideSeparator = NO;
        self.clipsToBounds = YES;
        horizontalSpace =  [TextCell horizontalTextSpaceForInsetWidth:cellInsetWidth];
        
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [mainView setBackgroundColor:[UIColor whiteColor]];
        
        self.userImageView = [[UserProfileImageView alloc] init];
        [self.userImageView setBackgroundColor:[UIColor clearColor]];
        [self.userImageView setOpaque:YES];
        self.userImageView.layer.cornerRadius = 16.0f;
        self.userImageView.layer.masksToBounds = YES;
        [mainView addSubview:self.userImageView];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        
        if ([reuseIdentifier isEqualToString:@"TextCell"]) {
            [self.nameButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [self.nameButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        } else {
            [self.nameButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [self.nameButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        }
        [self.nameButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:self.nameButton];
        
        self.storyTextLabel = [[UILabel alloc] init];
        [self.storyTextLabel setFont:[UIFont systemFontOfSize:13.0f]];
        if ([reuseIdentifier isEqualToString:@"TextCell"]) {
            [self.storyTextLabel setTextColor:[UIColor whiteColor]];
        } else {
            [self.storyTextLabel setTextColor:[UIColor lightGrayColor]];
        }
        [self.storyTextLabel setNumberOfLines:0];
        [self.storyTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.storyTextLabel setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:self.storyTextLabel];
        
        self.timeStampLabel = [[UILabel alloc] init];
        [self.timeStampLabel setFont:[UIFont systemFontOfSize:11]];
        [self.timeStampLabel setTextColor:[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f]];
        [self.timeStampLabel setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:self.timeStampLabel];
        
        
        self.userImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.userImageButton setBackgroundColor:[UIColor clearColor]];
        [self.userImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [mainView addSubview:self.userImageButton];
        
        self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        //[mainView addSubview:separatorImage];
        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width-2*cellInsetWidth, self.contentView.frame.size.height)];
    
    // Layout avatar image
    [self.userImageView setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];
    [self.userImageButton setFrame:CGRectMake(avatarX, avatarY + 5.0f, avatarDim, avatarDim)];
    
    // Layout the name button
    CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                                 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                                                    context:nil].size;
    [self.nameButton setFrame:CGRectMake(nameX, nameY + 6.0f, nameSize.width, nameSize.height)];
    
    // Layout the content
    CGSize contentSize = [self.storyTextLabel.text boundingRectWithSize:CGSizeMake(horizontalSpace, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                              context:nil].size;
    [self.storyTextLabel setFrame:CGRectMake(nameX, vertTextBorderSpacing + 5.0f, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label
    CGSize timeSize = [self.timeStampLabel.text boundingRectWithSize:CGSizeMake(horizontalSpace, CGFLOAT_MAX)
                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0f]}
                                                        context:nil].size;
    [self.timeStampLabel setFrame:CGRectMake(timeX, storyTextLabel.frame.origin.y + storyTextLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];
    
    // Layour separator
    [self.separatorImage setFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width-cellInsetWidth*2, 1)];
    [self.separatorImage setHidden:hideSeparator];
}


#pragma mark - Delegate methods

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }
}


#pragma mark - TextCell

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [TextCell heightForCellWithName:name contentString:content cellInsetWidth:0];
}

/* Static helper to get the height for a cell if it had the given name, content and horizontal inset */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name boundingRectWithSize:nameSize
                                         options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                         context:nil].size;
    
    NSString *paddedString = [TextCell padString:content withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [TextCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString boundingRectWithSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin // word wrap?
                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                    context:nil].size;
    
    CGFloat singleLineHeight = [@"test" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f]}
                                                     context:nil].size.height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = (contentSize.height - singleLineHeight) > 0 ? (contentSize.height - singleLineHeight) : 0;
    
    return horiBorderSpacing + avatarDim + horiBorderSpacingBottom + multilineHeightAddition;
}

/* Static helper to obtain the horizontal space left for name and content after taking the inset and image in consideration */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return (320-(insetWidth*2)) - (horiBorderSpacing+avatarDim+horiElemSpacing+horiBorderSpacing);
}

/* Static helper to pad a string with spaces to a given beginning offset */
+ (NSString *)padString:(NSString *)string withFont:(UIFont *)font toWidth:(CGFloat)width {
    // Find number of spaces to pad
    NSMutableString *paddedString = [[NSMutableString alloc] init];
    while (true) {
        [paddedString appendString:@" "];
        CGSize resultSize = [paddedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                       options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:font}
                                                       context:nil].size;
        if (resultSize.width >= width) {
            break;
        }
    }
    
    // Add final spaces to be ready for first word
    [paddedString appendString:[NSString stringWithFormat:@" %@",string]];
    return paddedString;
}

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Set name button properties and avatar image
    if ([Utility userHasProfilePictures:self.user]) {
        [self.userImageView setProfileImageFile:[self.user objectForKey:@"profilePictureSmall"]];
    } else {
        [self.userImageView setProfileImageView:[Utility defaultProfilePicture]];
    }
    
    [self.nameButton setTitle:[self.user objectForKey:@"UsersFullName"] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:@"UsersFullName"] forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.storyTextLabel.text) {
        [self setStoryText:self.storyTextLabel.text];
    }
    [self setNeedsDisplay];
}

-(void)setstoryTitle:(NSString *)titleString {


}


- (void)setStoryText:(NSString *)contentString {
    // If we have a user we pad the content with spaces to make room for the name
    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text boundingRectWithSize:CGSizeMake(nameMaxWidth, CGFLOAT_MAX)
                                                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]}
                                                                        context:nil].size;
        NSString *paddedString = [TextCell padString:contentString withFont:[UIFont systemFontOfSize:13] toWidth:nameSize.width];
        [self.storyTextLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.storyTextLabel setText:contentString];
    }
    [self setNeedsDisplay];
}

- (void)setTime:(NSDate *)date {
    // Set the label with a human readable tim
    // Set the time interval
    Utility* utility = [[Utility alloc] init];
    NSString* timeStampString = [utility stringForTimeIntervalSinceCreated:date];
    [self.timeStampLabel setText:timeStampString];
    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    // Change the mainView's frame to be insetted by insetWidth and update the content text space
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake(insetWidth, mainView.frame.origin.y, mainView.frame.size.width-2*insetWidth, mainView.frame.size.height)];
    horizontalSpace = [TextCell horizontalTextSpaceForInsetWidth:insetWidth];
    [self setNeedsDisplay];
}

/* Since we remove the compile-time check for the delegate conforming to the protocol
 in order to allow inheritance, we add run-time checks. */
- (id<TextCellDelegate>)delegate {
    return (id<TextCellDelegate>)delegate;
}

- (void)setDelegate:(id<TextCellDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)hideSeparator:(BOOL)hide {
    hideSeparator = hide;
}

@end
