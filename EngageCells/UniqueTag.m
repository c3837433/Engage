//
//  UniqueTag.m
//  EngageCells
//
//  Created by Angela Smith on 2/23/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "UniqueTag.h"

@implementation UniqueTag
@dynamic tagName, tagCount;


+(void)load {
    [self registerSubclass];
}

+(NSString*) parseClassName {

    return @"UniqueTags";
}

@end
