//
//  MapViewController.m
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "VenueAnnotation.h"
#import "PerchItemInfo.h"
#import "WebSiteViewController.h"
#import "GPUberViewController.h"


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.mapView = self;
    
    [self.searchCancel_button setHidden:YES];
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.nSelectedVenueId = -1;
    self.selectedVenue = nil;
    
    self.locationMgr = [[CLLocationManager alloc] init];
    self.locationMgr.delegate = self;
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationMgr.distanceFilter = 2000.0f; //2000 meter
    
    //[self.locationMgr startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    MKCoordinateRegion visibleRegion;
    MKCoordinateSpan visibleSpan;
    visibleSpan.latitudeDelta = 25;
    visibleSpan.longitudeDelta = 25;
    
    CLLocationCoordinate2D home_location = self.mapView.userLocation.coordinate;
    //home_location.latitude = -33.8696;
    //home_location.longitude = 151.2070;
    
    visibleRegion.span = visibleSpan;
    visibleRegion.center = home_location;
    
    [self.mapView setRegion:visibleRegion animated:YES];
    [self.mapView regionThatFits:visibleRegion];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.locationMgr startUpdatingLocation];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.location_updated == YES && appDelegate.pass_login == YES)
    {
        [self drawAnnotation];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.locationMgr stopUpdatingLocation];
    self.locationMgr = nil;
}

- (void) setLocationToHere
{
    [self.locationMgr startUpdatingLocation];
}

- (void) drawAnnotation
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:1];
    for (id annotation in self.mapView.annotations) {
        if (annotation != self.mapView.userLocation) {
            [toRemove addObject:annotation];
        }
        
    }
    NSLog(@"remove %lu annotations", (unsigned long)[toRemove count]);
    [self.mapView removeAnnotations:toRemove];
    
    MKMapRect flyTo = MKMapRectNull;
    for (int i = 0; i < [appDelegate.venueArray count]; i++) {
        VenueItem *venueItem = (VenueItem*)[appDelegate.venueArray objectAtIndex:i];
        double latitude = venueItem.latitude;
        double longitude = venueItem.longitude;
        VenueAnnotation *venue_annotation = [[VenueAnnotation alloc] init];
        venue_annotation.info = venueItem;
        for (int j = 0; j < [appDelegate.perchArray count]; j++)
        {
            PerchItemInfo *perchItem = (PerchItemInfo*)[appDelegate.perchArray objectAtIndex:j];
            NSInteger ven_id = perchItem.venue_id;
            if (ven_id == venue_annotation.info.venue_id) {
                venue_annotation.type = 1;
                break;
            }
        }
        venue_annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint annotationPoint = MKMapPointForCoordinate(venue_annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
        [self.mapView addAnnotation:venue_annotation];
    }
    
    self.mapView.visibleMapRect = flyTo;
}

- (void) redrawAnnotation
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:1];
    for (id annotation in self.mapView.annotations) {
        if (annotation != self.mapView.userLocation) {
            [toRemove addObject:annotation];
        }
        
    }
    NSLog(@"remove %lu annotations", (unsigned long)[toRemove count]);
    [self.mapView removeAnnotations:toRemove];
    
    MKMapRect flyTo = MKMapRectNull;
    for (int i = 0; i < [appDelegate.venueArray count]; i++) {
        VenueItem *venueItem = (VenueItem*)[appDelegate.venueArray objectAtIndex:i];
        double latitude = venueItem.latitude;
        double longitude = venueItem.longitude;
        VenueAnnotation *venue_annotation = [[VenueAnnotation alloc] init];
        venue_annotation.info = venueItem;
        venue_annotation.type = 0;
        for (int j = 0; j < [appDelegate.perchArray count]; j++)
        {
            PerchItemInfo *perchItem = (PerchItemInfo*)[appDelegate.perchArray objectAtIndex:j];
            NSInteger ven_id = perchItem.venue_id;
            if (ven_id == venue_annotation.info.venue_id) {
                venue_annotation.type = 1;
                break;
            }

        }
        if (venueItem.venue_id == self.selectedVenue.venue_id) {
            venue_annotation.type = 2;
            
            venue_annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            MKMapPoint annotationPoint = MKMapPointForCoordinate(venue_annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
            if (MKMapRectIsNull(flyTo)) {
                flyTo = pointRect;
            } else {
                flyTo = MKMapRectUnion(flyTo, pointRect);
            }
            
            [self.mapView addAnnotation:venue_annotation];
            
            self.mapView.visibleMapRect = flyTo;
        }

        
    }

}

#pragma mark - location delegate -

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *new_location = [locations lastObject];
    NSString *strInfo = [NSString stringWithFormat:@"didUpdateToLocation:latitude=%f, longitude=%f", new_location.coordinate.latitude, new_location.coordinate.longitude];
    NSLog(@"%@", strInfo);
    
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(new_location.coordinate, 2000, 2000);
    
    MKCoordinateRegion adjustRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustRegion animated:YES];
    
    
    [self.locationMgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager error!");
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                    message:@"Cannot find your current location. Please confirm the if the option (Setting->Privacy->Location Service) is active."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"ok", nil];
    [alert show];
     */
    [self.locationMgr stopUpdatingLocation];
}

#pragma mark - annotation delegate -
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == self.mapView.userLocation) {
        [self.mapView.userLocation setTitle:@"Current Location"];
        return nil;
    }
    
    VenueAnnotation *venueAnnotation = (VenueAnnotation *)annotation;
    MKAnnotationView *annotationView = nil;
    static NSString *reusePinId = @"VenueAnnotation";
    
    annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reusePinId];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusePinId];
    }
    
    UIButton *info_btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.userInteractionEnabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = info_btn;
    annotationView.tag = 1987 + venueAnnotation.info.venue_id;
    if (venueAnnotation.type == 0) {
        annotationView.image = [UIImage imageNamed:@"map_pos_black.png"];
    }
    else if (venueAnnotation.type == 1) {
        annotationView.image = [UIImage imageNamed:@"map_pos_red.png"];
    }
    else if (venueAnnotation.type == 2) {
        annotationView.image = [UIImage imageNamed:@"map_pos_white.png"];
    }
    
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSInteger venue_id = view.tag - 1987;
    self.nSelectedVenueId = venue_id;
    
    for (int i = 0; i < [appDelegate.venueArray count]; i++)
    {
        VenueItem *item = (VenueItem*)[appDelegate.venueArray objectAtIndex:i];
        NSInteger vId = item.venue_id;
        if (self.nSelectedVenueId == vId) {
            self.selectedVenue = item;
            break;
        }
    }
    
    if (self.selectedVenue != nil) {
        
        [self.venue_label setText:self.selectedVenue.name];
        [self.address_label setText:self.selectedVenue.address];
    }
    
    //redraw annotations to mapview
    [self redrawAnnotation];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (self.selectedVenue != nil) {
        
        [self.venue_label setText:self.selectedVenue.name];
        [self.address_label setText:self.selectedVenue.address];
    }

}

#pragma mark - IBAction Events -
- (IBAction)call_uber:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSInteger venueId = self.selectedVenue.venue_id;
    CLLocationCoordinate2D venuePos = CLLocationCoordinate2DMake(0, 0);
    for (int i = 0; i < [appDelegate.venueArray count]; i++)
    {
        VenueItem *venueItem = [appDelegate.venueArray objectAtIndex:i];
        NSInteger vId = venueItem.venue_id;
        if (venueId == vId) {
            venuePos.latitude = venueItem.latitude;
            venuePos.longitude = venueItem.longitude;
            break;
        }
    }
    
    
    GPUberViewController *uber = [[GPUberViewController alloc] initWithServerToken:UBER_SERVER_TOKEN];
    
    uber.startLocation = CLLocationCoordinate2DMake(appDelegate.current_latitude, appDelegate.current_longitude);
    uber.endLocation = venuePos;
    
    [uber showInViewController:self];

}

- (IBAction)call_home:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSInteger venueId = self.selectedVenue.venue_id;
    NSString *websiteUrl;
    for (int i = 0; i < [appDelegate.venueArray count]; i++)
    {
        VenueItem *venueItem = [appDelegate.venueArray objectAtIndex:i];
        NSInteger vId = venueItem.venue_id;
        if (venueId == vId) {
            websiteUrl = venueItem.website;
            break;
        }
    }
    
    if (websiteUrl == nil || [websiteUrl isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"There's no website address."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];
        
        return;
    }
    if (![websiteUrl containsString:@"http://"]) {
        websiteUrl = [NSString stringWithFormat:@"http://%@", websiteUrl];
        
    }

    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    WebSiteViewController *websiteViewController = (WebSiteViewController*)[mainStoryboard
                                                                            instantiateViewControllerWithIdentifier: @"WebSiteViewController"];
    
    [websiteViewController loadWebsite:websiteUrl];
    [self presentViewController:websiteViewController animated:YES completion:nil];

}

- (IBAction)call_refresh:(id)sender
{
    
}

- (IBAction)call_phone:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSInteger venueId = self.selectedVenue.venue_id;
    NSString *phoneNumber;
    for (int i = 0; i < [appDelegate.venueArray count]; i++)
    {
        VenueItem *venueItem = [appDelegate.venueArray objectAtIndex:i];
        NSInteger vId = venueItem.venue_id;
        if (venueId == vId) {
            phoneNumber = venueItem.phone_number;
            break;
        }
    }
    
    if (phoneNumber == nil || [phoneNumber isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"There's no phone number."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];
        return;
    }

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", phoneNumber]]];

}

- (IBAction)locateMe:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    CLLocationCoordinate2D userLocationCoord = CLLocationCoordinate2DMake(appDelegate.current_latitude, appDelegate.current_longitude);

    [self.mapView setCenterCoordinate:userLocationCoord];
}

- (void)locate:(NSInteger) venue_id
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    for (int i = 0; i < [appDelegate.venueArray count]; i++)
    {
        VenueItem *venueItem = [appDelegate.venueArray objectAtIndex:i];
        NSInteger vId = venueItem.venue_id;
        if (venue_id == vId) {
            self.selectedVenue = venueItem;
            
            [self.venue_label setText:self.selectedVenue.name];
            [self.address_label setText:self.selectedVenue.address];
            
            break;
        }
    }
    
    [self redrawAnnotation];

    /*
    MKCoordinateRegion visibleRegion;
    MKCoordinateSpan visibleSpan;
    visibleSpan.latitudeDelta = 0.1;
    visibleSpan.longitudeDelta = 0.1;
    
    visibleRegion.span = visibleSpan;
    visibleRegion.center = CLLocationCoordinate2DMake(self.selectedVenue.latitude, self.selectedVenue.longitude);
    
    [self.mapView setRegion:visibleRegion animated:YES];
    [self.mapView regionThatFits:visibleRegion];
     */
}

- (IBAction)search_cancel:(id)sender
{
    [self.searchBar setText:@""];
    [self.searchBar resignFirstResponder];
    
}

- (void) searchVenue:(NSString *)search_str
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    for (int i = 0; i < [appDelegate.venueArray count]; i++)
    {
        VenueItem *venueItem = [appDelegate.venueArray objectAtIndex:i];
        NSString *venueName = venueItem.name;
        if ([venueName containsString:search_str] || [[venueName lowercaseString] containsString:search_str]) {
            self.selectedVenue = venueItem;
            
            [self.venue_label setText:self.selectedVenue.name];
            [self.address_label setText:self.selectedVenue.address];
            
            break;
        }
    }
    
    //redraw annotations to mapview
    [self redrawAnnotation];
}

#pragma textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.searchBar) {
        [self.searchBar resignFirstResponder];
        
        [self searchVenue:self.searchBar.text];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.searchCancel_button setHidden:NO];
}

@end
