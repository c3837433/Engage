//
//  ImageView.h
//  EngageCells
//
//  Created by Angela Smith on 1/29/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageView : UIImageView

// Create the view for the users profile picture
@property (nonatomic, strong) UIImage* placeHolderImage;
@property (nonatomic, strong) PFFile* usersFile;
@property (nonatomic, strong) NSString* imageUrl;

// Set the users image file in the view
-(void) setImageFile:(PFFile*)imageFile;
@end
