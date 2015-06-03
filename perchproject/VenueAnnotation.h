//
//  VenueAnnotation.h
//  purch_01
//
//  Created by Admin on 3/20/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "VenueItem.h"

@interface VenueAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D      coordinate;
    NSString                    *title;
    NSString                    *subtitle;

    VenueItem                   *info;
    NSInteger                   type;
}

@property(nonatomic, assign)    CLLocationCoordinate2D      coordinate;
@property(nonatomic, copy)      NSString                    *title;
@property(nonatomic, copy)      NSString                    *subtitle;

@property(nonatomic, retain)    VenueItem                   *info;
@property(nonatomic)            NSInteger                   type;

@end
