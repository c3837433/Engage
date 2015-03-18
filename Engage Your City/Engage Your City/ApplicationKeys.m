//
//  ApplicationKeys.m
//  Engage
//
//  Created by Angela Smith on 2/17/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "ApplicationKeys.h"



#pragma mark - NSNotification

NSString *const AppDelegateApplicationDidReceiveRemoteNotification           = @"com.Smith.Angela.Engage.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const UtilityUserFollowingChangedNotification                      = @"com.Smith.Angela.Engage.utility.userFollowingChanged";
NSString *const UtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.Smith.Angela.Engage.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const UtilityDidFinishProcessingProfilePictureNotification         = @"com.Smith.Angela.Engage.utility.didFinishProcessingProfilePictureNotification";
//NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification            = @"com.Smith.Angela.Engage.tabBarController.didFinishEditingPhoto";
//NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"com.Smith.Angela.Engage.tabBarController.didFinishImageFileUploadNotification";
//NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.Smith.Angela.Engage.photoDetailsViewController.userDeletedPhoto";
NSString *const StoryMainFeedViewControllerUserLikedUnlikedPhotoNotification  = @"com.Smith.Angela.Engage.storyMainFeedViewController.userLikedUnlikedPhotoInDetailsViewNotification";
//NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.Smith.Angela.Engage.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";

NSString *const InstallationUserKey = @"user";


NSString *const PushPayloadActivityTypeKey     = @"t";
NSString *const PushPayloadActivityLikeKey     = @"l";
NSString *const PushPayloadActivityCommentKey  = @"c";
NSString *const PushPayloadActivityFollowKey   = @"f";

NSString *const PushPayloadFromUserObjectIdKey = @"fu";
NSString *const PushPayloadToUserObjectIdKey   = @"tu";
NSString *const PushPayloadPhotoObjectIdKey    = @"pid";
