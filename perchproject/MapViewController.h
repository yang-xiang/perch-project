//
//  MapViewController.h
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SlideNavigationController.h"
#import "VenueItem.h"


@interface MapViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate>

@property(nonatomic, weak) IBOutlet MKMapView *mapView;

@property(nonatomic, retain) CLLocationManager       *locationMgr;
@property(nonatomic, retain) CLLocation              *lastScannedLocation;

@property(nonatomic, weak) IBOutlet UILabel   *venue_label;
@property(nonatomic, weak) IBOutlet UILabel   *address_label;

@property(nonatomic, weak) IBOutlet UITextField    *searchBar;
@property(nonatomic, weak) IBOutlet UIButton       *searchCancel_button;

@property(nonatomic)                    NSInteger   nSelectedVenueId;
@property(nonatomic, retain)                    VenueItem   *selectedVenue;



- (void)locate:(NSInteger) venue_id;


@end
