//
//  VenueItem.m
//  purch_01
//
//  Created by Admin on 3/26/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import "VenueItem.h"

@implementation VenueItem

@synthesize       venue_id;
@synthesize       logo_image;
@synthesize       name;
@synthesize       venue_image;
@synthesize       website;
@synthesize       phone_number;
@synthesize       address;

@synthesize       latitude;
@synthesize       longitude;

- (id) initWithTitle:(NSString *)_title
{

    self = [self init];
    
    if (self != nil) {
        
        self.venue_id = -1;
        self.logo_image = @"";
        self.venue_image = @"";
        self.name = @"";
        self.website = @"";
        self.phone_number = @"";
        self.address = @"";
        
        self.latitude = 0.0f;
        self.longitude = 0.0f;

    }
    
    return self;
}

@end
