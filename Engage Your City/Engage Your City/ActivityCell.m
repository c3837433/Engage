//
//  ActivityCell.m
//  Engage Your City
//
//  Created by Angela Smith on 2/27/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

#import "ActivityCell.h"
#import "Utility.h"
#import "ApplicationKeys.h"

@implementation ActivityCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setActivity:(PFObject*) activity {
    self.thisActivity = activity;
    // GET AND SET THE TIME STAMP
    NSDate* timeCreated = self.thisActivity.createdAt;
    Utility* utility = [[Utility alloc] init];
    NSString* timestamp = [utility stringForTimeIntervalSinceCreated:timeCreated];
    self.timeLabel.text = timestamp;
    
    // Prepare the from user
    PFUser* fromUser = [self.thisActivity objectForKey:aActivityFromUser];
    if ([fromUser objectForKey:aUserImage]) {
        // NSLog(@"The author HAS profile image");
        PFFile* imageFile = [fromUser objectForKey:aUserImage];
        if ([imageFile isDataAvailable]) {
            //[cell.image loadInBackground];
            self.profileImageView.file = imageFile;
            [self.profileImageView loadInBackground];
        } else {
            self.profileImageView.file = imageFile;
            [self.profileImageView loadInBackground];
        }
    } else {
        //  NSLog(@"The author has NO profile image");
        self.profileImageView.image = [UIImage imageNamed:@"placeholder"];
    }

}



@end
