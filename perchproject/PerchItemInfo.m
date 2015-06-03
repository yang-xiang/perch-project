//
//  PerchItemInfo.m
//  purch_01
//
//  Created by Admin on 3/20/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import "PerchItemInfo.h"

@implementation PerchItemInfo

@synthesize       nid;
@synthesize       title;
@synthesize       info;
@synthesize       venue_id;
@synthesize       category;
@synthesize       days;
@synthesize       start_time;
@synthesize       end_time;
@synthesize       image;

- (id) initWithTitle:(NSString *)_title
{
    self = [self init];
    
    if (self != nil) {
        
        self.nid = -1;
        self.category = @"";
        
        self.venue_id = -1;

        self.title = @"";
        self.info = @"";
        self.days = @"";
        self.start_time = @"";
        self.end_time = @"";
        self.image = @"";
    }
    
    
    return self;
}



@end
