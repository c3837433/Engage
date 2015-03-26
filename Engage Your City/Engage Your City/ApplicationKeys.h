//
//  ApplicationKeys.h
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
// Font Definitions
#define aFont @"AvenirNext-Regular"
#define aFontBold @"AvenirNext-Bold"
#define aFontMed @"AvenirNext-Medium"
#define aFontItalic @"AvenirNext-Italic"
#define aFontHeavyItalic @"AvenirNext-HeavyItalic"


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
#define aUserAboutMe @"AboutMe"
#define aUserLocationName @"Location"



#pragma mark HOME GROUPS CLASS
#define aHomeGroupClass @"HomeGroups"
#define aHomeGroupAbout @"AboutUs"
#define aHomeGroupLocation @"locationAddress"
#define aHomeGroupMeetDate @"meetingDates"
#define aHomeGroupMeetTime @"meetingTime"
#define aHomeGroupRegion @"Region"
#define aHomeGroupRegionPointer @"region"
#define aHomeGroupNation @"Nation"
#define aHomeGroupCity @"City"
#define aHomeGroupLeader @"resident"
#define aHomegroupLeadersArray @"Leaders"
#define aHomeGroupJoinable @"Joinable"
#define aHomeGroupGeoLocation @"location"
#define aHomeGroupLinks @"SocialLinks"
#define aHomeGroupPhone @"Phone"
#define aHomeGroupTitle @"groupHeader"


#pragma mark ACTIVITY CLASS
#define aActivityClass @"Activity"
#define aActivityType @"activityType"
#define aActivityFromUser @"fromUser"
#define aActivitytoGroup @"toGroup"
#define aActivityToUser @"toUser"
#define aActivityCommentText @"commentText"
#define aActivityStory @"Testimony"
#define aActivityFollow @"follow"
#define aActivityJoin @"join"
#define aActivityLike @"like"
#define aActivityComment @"comment"
#define aActivityFollowGroup @"followGroup"
#define aActivityJoinGroup @"joinGroup"

#pragma mark HASHTAGS CLASS
#define aHashTagClass @"Hashtags"
#define aHashtagTag @"tag"
#define aHashtagStory @"Story"
#define aHashtagStoryAuthor @"StoryAuthor"

#pragma mark REGION CLASS
#define aRegionClass @"Region"
#define aRegionName @"RegionName"
#define aRegionHomeGroupsCount @"LocalGroups"
#define aRegionDirector @"Director"

#pragma mark ROLE
#define aRoleName

#pragma mark - NSNotification
extern NSString *const UtilityUserFollowingChangedNotification;
extern NSString *const UtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const UtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const StoryMainFeedViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const AppDelegateApplicationDidReceiveRemoteNotification;

// Local Map
static NSString * const LocalFilterDistanceDidChangeNotification = @"FilterDistanceDidChangeNotification";
static NSString * const LocalCurrentLocationDidChangeNotification = @"CurrentLocationDidChangeNotification";
static NSString * const LocalPostCreatedNotification = @"PostCreatedNotification";

static NSString * const LocalFilterDistanceKey = @"filterDistance";
static NSString * const LocalLocationKey = @"location";
static NSString * const UserDefaultsFilterDistanceKey = @"filterDistance";


static double const LocalDefaultFilterDistance = 1000.0;
static double const LocalMaximumSearchDistance = 100.0;

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


#define iPhoneVersion ([[UIScreen mainScreen] bounds].size.height == 568 ? 5 : ([[UIScreen mainScreen] bounds].size.height == 480 ? 4 : ([[UIScreen mainScreen] bounds].size.height == 667 ? 6 : ([[UIScreen mainScreen] bounds].size.height == 736 ? 61 : 999))))
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)