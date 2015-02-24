//
//  Utility.h
//  Engage
//
//  Created by Angela Smith on 7/14/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//  Origionally Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface Utility : NSObject

+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasProfilePictures:(PFUser *)user;
+ (UIImage *)defaultProfilePicture;
+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)likeStoryInBackground:(id)story block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikeStoryInBackground:(id)story block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
//+ (PFQuery *)queryForActivitiesOnStory:(PFObject *)story cachePolicy:(PFCachePolicy)cachePolicy ;

// find friends
+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;
- (NSString *)stringForTimeIntervalSinceCreated:(NSDate *)dateTime;
//+ (PFQuery *)queryForLikesOnStory:(PFObject *)story cachePolicy:(PFCachePolicy)cachePolicy;
+ (PFQuery *)queryForLikersForStory:(PFObject *)story cachePolicy:(PFCachePolicy)cachePolicy;
@end
