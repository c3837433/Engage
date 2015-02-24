//
//  HomeGroupTableViewCell.h
//  Engage
//
//  Created by Angela Smith on 7/14/14.
//  Copyright (c) 2014 Angela Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeGroupTableViewCell : UITableViewCell
{

}
@property (strong, nonatomic) IBOutlet UILabel* groupLocation;
@property (strong, nonatomic) IBOutlet UILabel* groupLeaders;
@property (strong, nonatomic) IBOutlet UILabel* groupMeeting;

-(void)refreshGroupList:(NSString*)location leader:(NSString*)leader meets:(NSString*)meets;


@end
