//
//  VenueItem.h
//  purch_01
//
//  Created by Admin on 3/26/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueItem : NSObject
{
    NSInteger                   venue_id;

    NSString                    *name;
    NSString                    *logo_image;
    NSString                    *venue_image;

    NSString                    *website;
    NSString                    *phone_number;
    NSString                    *address;
    
    double                      latitude;
    double                      longitude;

}

@property(nonatomic)           NSInteger                    venue_id;
@property(nonatomic, retain)   NSString                    *logo_image;
@property(nonatomic, retain)   NSString                    *name;
@property(nonatomic, retain)   NSString                    *venue_image;
@property(nonatomic, retain)   NSString                    *website;
@property(nonatomic, retain)   NSString                    *phone_number;
@property(nonatomic, retain)   NSString                    *address;

@property(nonatomic)   double                      latitude;
@property(nonatomic)   double                      longitude;

- (id) initWithTitle:(NSString *)_title;

@end
