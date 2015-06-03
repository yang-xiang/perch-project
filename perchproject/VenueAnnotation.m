//
//  VenueAnnotation.m
//  purch_01
//
//  Created by Admin on 3/20/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import "VenueAnnotation.h"

@implementation VenueAnnotation

@synthesize       coordinate;
@synthesize       title;
@synthesize       subtitle;

@synthesize       info;
@synthesize       type;

- (id)init {
    self = [super init];
    if (self != nil) {
        self.title = @"Monitored Region";
        self.subtitle = @"";
        self.info = nil;
        self.coordinate = CLLocationCoordinate2DMake(0, 0);
        self.type = 0;
    }
    
    return self;	
}


@end
