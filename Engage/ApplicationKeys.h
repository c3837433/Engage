//
//  ApplicationKeys.h
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//


// Font Definitions
#define aFont @"AvenirNext-Regular"


// Segmented Controller 
#define _allowAppearance    NO
#define _bakgroundColor     [UIColor colorWithRed:0/255.0 green:87/255.0 blue:173/255.0 alpha:1.0]
#define _tintColor          [UIColor colorWithRed:20/255.0 green:200/255.0 blue:255/255.0 alpha:1.0]
#define _hairlineColor      [UIColor colorWithRed:0/255.0 green:36/255.0 blue:100/255.0 alpha:1.0]


#pragma mark TESTIMONIES CLASS
#define aPostClass  @"Testimony"
#define aPostAuthor  @"author"
#define aPostAuthorGroup @"Group"
#define aPostTitle @"title"
#define aPostText @"story"
#define aPostLikes @"Likes"
#define aPostComments @"Comments"
#define aPostMediaType  @"media"
#define aPostMediaUrl  @"mediaUrl"
#define aPostMediaRelease  @"release"
#define aPostVideoFile  @"uploadedMedia"
#define aPostVideoThumb  @"mediaThumb"
#define aPostFlag  @"Flagged"


#pragma mark USER CLASS
#define aUserImage @"profilePictureSmall"
#define aUserName @"UsersFullName"
#define aUserProfileName @"UserProfileName"
#define aUserGroup @"group"
#define aUserUserName @"username"
#define aUserEmail @"email"
#define aUserSharePermission @"sharePermission"
#define aUserFBLinkable @"FBLInkable"
#define aUserFaceBookId @"facebookId"
#define aUserAutoFollowFB @"autoFollowFB"



#pragma mark HOME GROUPS CLASS
#define aHomeGroupClass @"HomeGroups"
#define aHomeGroupNotes @"groupNotes"
#define aHomeGroupLocation @"locationAddress"
#define aHomeGroupMeetDate @"meetingDates"
#define aHomeGroupMeetTime @"meetingTime"
#define aHomeGroupRegion @"region"
#define aHomeGroupCity @"City"
#define aHomeGroupLeader @"resident"
#define aHomeGroupJoinable @"Joinable"
#define aHomeGroupGeoLocation @"location"
#define aPostAuthorGroupTitle @"groupHeader"


#pragma mark ACTIVITY CLASS
#define aActivityClass @"Activity"
#define aActivityType @"activityType"
#define aActivityFromUser @"fromUser"
#define aActivityToUser @"toUser"
#define aActivityCommentText @"commentText"
#define aActivityStory @"Testimony"
#define aActivityFollow @"follow"
#define aActivityJoin @"join"
#define aActivityLike @"like"
#define aActivityComment @"comment"

#pragma mark HASHTAGS CLASS
#define aHashTagClass @"Hashtags"
#define aHashtagTag @"tag"
#define aHashtagStory @"Story"
#define aHashtagStoryAuthor @"StoryAuthor"


#pragma mark - NSNotification
extern NSString *const UtilityUserFollowingChangedNotification;
extern NSString *const UtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const UtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const StoryMainFeedViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const AppDelegateApplicationDidReceiveRemoteNotification;

#pragma mark - Installation Class

// Field keys
extern NSString *const InstallationUserKey;

#pragma mark - PFPush Notification Payload Keys
extern NSString *const PushPayloadActivityTypeKey;
extern NSString *const PushPayloadActivityLikeKey;
extern NSString *const PushPayloadActivityCommentKey;
extern NSString *const PushPayloadActivityFollowKey;

extern NSString *const PushPayloadFromUserObjectIdKey;
extern NSString *const PushPayloadToUserObjectIdKey;
extern NSString *const PushPayloadPhotoObjectIdKey;