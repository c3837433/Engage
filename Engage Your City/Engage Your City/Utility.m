//
//  Utility.m
//  Engage
//
//  Created by Angela Smith on 7/14/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import "Utility.h"
#import "UIImage+ResizeAdditions.h"
#import "Cache.h"
#import "ApplicationKeys.h"

@implementation Utility


#pragma mark Facebook

+(void)saveFacebookImageData:(NSData*)imageData
{
    if (imageData != nil)
    {
        // We have data, create an image out of it
        UIImage* pictureImage = [UIImage imageWithData:imageData];
        // Resize the image so it is small enough to work in both the profile view and list views. Aldo round the corners
        UIImage* resizedImage = [pictureImage thumbnailImage:75 transparentBorder:0 cornerRadius:8 interpolationQuality:kCGInterpolationMedium];
        
        //Turn the image into data, and a PFFile
        NSData* newImageData = UIImagePNGRepresentation(resizedImage);
        if (newImageData != nil)
        {
            // Save this to parse
            PFFile* profilePicFile = [PFFile fileWithData:newImageData];
            [profilePicFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    // Set the picture to the current user's profile picture
                    [[PFUser currentUser] setObject:profilePicFile forKey:@"profilePictureSmall"];
                    // Save this whenever the user has internet
                    [[PFUser currentUser] saveEventually];
                }
            }];
        }
    }
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:@"facebookId"];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:@"profilePictureMedium"];
    PFFile *profilePictureSmall = [user objectForKey:@"profilePictureSmall"];
    
    return (profilePictureMedium && profilePictureSmall);
}
+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)likeStoryInBackground:(id)story block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery* queryExistingLikes = [PFQuery queryWithClassName:aActivityClass];
    NSLog(@"Searching for previous likes");
    [queryExistingLikes whereKey:aActivityStory equalTo:story];
    [queryExistingLikes whereKey:aActivityType equalTo:aActivityLike];
    [queryExistingLikes whereKey:aActivityFromUser equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray* likes, NSError *error) {
        if (!error) {
            for (PFObject* like in likes) {
                [like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"Deleting previous like");
                }];
            }
        }
        NSLog(@"Creating a new activity like");
        // proceed to creating new like
        PFObject* likeActivity = [PFObject objectWithClassName:aActivityClass];
        [likeActivity setObject:[PFUser currentUser] forKey:aActivityFromUser];
        [likeActivity setObject:[story objectForKey:aPostAuthor] forKey:aActivityToUser];
        [likeActivity setObject:story forKey:aActivityStory];
        [likeActivity setObject:aActivityLike forKey:aActivityType];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[story objectForKey:aPostAuthor]];
        likeActivity.ACL = likeACL;
        NSLog(@"Saving new like");
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Like saved");
            } else if (error) {
                NSLog(@"Error saving: %@", error.description);
            }
            if (completionBlock) {
                completionBlock(succeeded,error);
            }
            // refresh cache
            NSLog(@"Updating story likes in cache");
            PFQuery *query = [Utility queryForLikersForStory:story cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    BOOL isLikedByCurrentUser = NO;
                    for (PFObject* liker in objects) {
                        if ([[[liker objectForKey:aActivityFromUser] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            isLikedByCurrentUser = YES;
                        }
                        // add the story liker to the list of likers
                        [likers addObject:[liker objectForKey:aActivityFromUser]];
                    }
                    [[Cache sharedCache] setLikeAttributesForStory:story likers:likers likedByCurrentUser:isLikedByCurrentUser];
                } else {
                    NSLog(@"Error updating cache");
                }
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:UtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:story userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:StoryMainFeedViewControllerUserLikedUnlikedPhotoNotification]];
            }];
            
        }];
    }];
    
}

+ (void)unlikeStoryInBackground:(id)story block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    // Find the origional like
    NSLog(@"Searching for previous likes");
    PFQuery* likeQuery = [PFQuery queryWithClassName:aActivityClass];
    [likeQuery whereKey:aActivityStory equalTo:story];
    [likeQuery whereKey:aActivityType equalTo:aActivityLike];
    [likeQuery whereKey:aActivityFromUser equalTo:[PFUser currentUser]];
    [likeQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        if (!error) {
            for (PFObject* like in likes) {
                //[activity delete
                [like delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            // refresh cache
            NSLog(@"Updating story likes in cache");
            PFQuery *query = [Utility queryForLikersForStory:story cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    BOOL isLikedByCurrentUser = NO;
                    for (PFObject* liker in objects) {
                        if ([[[liker objectForKey:aActivityFromUser] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            isLikedByCurrentUser = YES;
                        }
                        // add the story liker to the list of likers
                        [likers addObject:[liker objectForKey:aActivityFromUser]];
                    }
                    [[Cache sharedCache] setLikeAttributesForStory:story likers:likers likedByCurrentUser:isLikedByCurrentUser];
                }
                
                //     [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}
/*
+ (PFQuery *)queryForActivitiesOnStory:(PFObject *)story cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:@"Activity"];
    [queryLikes whereKey:@"Testimony" equalTo:story];
    [queryLikes whereKey:@"activityType" equalTo:@"like"];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:@"Activity"];
    [queryComments whereKey:@"Testimony"  equalTo:story];
    [queryComments whereKey:@"activityType" equalTo:@"comment"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:@"fromUser"];
    [query includeKey:@"Testimony"];
    
    return query;
}
*/
/*
+ (PFQuery *)queryForLikesOnStory:(PFObject *)story cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"onStory" equalTo:story];
    [query includeKey:@"fromUser"];
    [query includeKey:@"onStory"];
    return query;
}
*/
+ (PFQuery *)queryForLikersForStory:(PFObject *)story cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery* queryLikes = [PFQuery queryWithClassName:aActivityClass];
    [queryLikes whereKey:aActivityStory equalTo:story];
    [queryLikes includeKey:aActivityFromUser];
    return queryLikes;
}

+ (PFQuery *)queryForTopFollowers:(PFCachePolicy)cachePolicy {
    PFQuery *followersQuery = [PFQuery queryWithClassName:aActivityClass];
    [followersQuery whereKey:aActivityType equalTo:aActivityFollow];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:followersQuery,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:aActivityFromUser];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
    }];
    
    return query;
}

+ (UIImage *)defaultProfilePicture {
    return [UIImage imageNamed:@"placeholder"];
}

#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:aActivityClass];
    [followActivity setObject:[PFUser currentUser] forKey:aActivityFromUser];
    [followActivity setObject:user forKey:aActivityToUser];
    [followActivity setObject:aActivityFollow forKey:aActivityType];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[Cache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:aActivityClass];
    [followActivity setObject:[PFUser currentUser] forKey:aActivityFromUser];
    [followActivity setObject:user forKey:aActivityToUser];
    [followActivity setObject:aActivityFollow forKey:aActivityType];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[Cache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [Utility followUserEventually:user block:completionBlock];
        [[Cache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:aActivityClass];
    [query whereKey:aActivityFromUser equalTo:[PFUser currentUser]];
    [query whereKey:aActivityToUser equalTo:user];
    [query whereKey:aActivityType equalTo:aActivityFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[Cache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:aActivityClass];
    [query whereKey:aActivityFromUser equalTo:[PFUser currentUser]];
    [query whereKey:aActivityToUser containedIn:users];
    [query whereKey:aActivityType equalTo:aActivityFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[Cache sharedCache] setFollowStatus:NO user:user];
    }
}

- (NSString *)stringForTimeIntervalSinceCreated:(NSDate *)dateTime
{
    NSDictionary *timeScale = @{@"second":@1,
                                @"minute":@60,
                                @"hour":@3600,
                                @"day":@86400,
                                @"week":@605800,
                                @"month":@2629743,
                                @"year":@31556926};
    NSString *scale;
    int timeAgo = 0-(int)[dateTime timeIntervalSinceNow];
    if (timeAgo < 60) {
        scale = @"second";
    } else if (timeAgo < 3600) {
        scale = @"minute";
    } else if (timeAgo < 86400) {
        scale = @"hour";
    } else if (timeAgo < 605800) {
        scale = @"day";
    } else if (timeAgo < 2629743) {
        scale = @"week";
    } else if (timeAgo < 31556926) {
        scale = @"month";
    } else {
        scale = @"year";
    }
    
    timeAgo = timeAgo/[[timeScale objectForKey:scale] integerValue];
    NSString *s = @"";
    if (timeAgo > 1) {
        s = @"s";
    }
    return [NSString stringWithFormat:@"%d %@%@ ago", timeAgo, scale, s];
}



@end
