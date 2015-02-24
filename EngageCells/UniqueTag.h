//
//  UniqueTag.h
//  EngageCells
//
//  Created by Angela Smith on 2/23/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import <Parse/Parse.h>

@interface UniqueTag : PFObject<PFSubclassing>

@property (retain) NSString* tagName;
@property int tagCount;

+(NSString*)parseClassName;

@end
