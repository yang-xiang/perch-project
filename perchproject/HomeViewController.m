//
//  HomeViewController.m
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "IntroViewController.h"
#import "WebSiteViewController.h"
#import "StashLoginViewController.h"
#import "SlideNavigationControllerAnimatorSlideAndFade.h"
#import "AppDelegate.h"
#import "PerchItemInfo.h"
#import "VenueItem.h"
#import <Social/Social.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "GPUberViewController.h"

@interface HomeViewController ()

@property(nonatomic) NSInteger      nSelectedRow;
@property (nonatomic, weak) IBOutlet UITableView *mTableView;
@property (nonatomic, retain) UIActivityIndicatorView *progress;
@property (nonatomic, retain) UIView                    *whiteSurfaceView;
@property (nonatomic, weak) IBOutlet UIView             *blueSurfaceView;


@property (nonatomic) CLLocationManager *locationMgr;

@property (nonatomic) BOOL          bDataLoaded;
@property (nonatomic, assign) BOOL  bLoadPerch_lock;
@property (nonatomic, retain) NSMutableArray *preload_array;

@property (nonatomic) BOOL          bLoadMore;
@property (nonatomic, assign) BOOL  bLocalNot_locationUpdated;

@property (nonatomic) NSInteger nScreenWidth;
@property (nonatomic) NSInteger nScreenHeight;

@property (nonatomic, retain) NSMutableArray *backImageArray;
@property (nonatomic, retain) NSMutableArray *logoImageArray;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bLocalNot_locationUpdated = NO;
    
    self.nScreenWidth = self.view.frame.size.width;
    self.nScreenHeight = self.view.frame.size.height;

    self.backImageArray = [[NSMutableArray alloc] init];
    self.logoImageArray = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if (IS_IPHONE_6_IOS8) {
        appDelegate.KEYBOARD_HEIGHT = 250;
    }
    else if (IS_IPHONE_6P_IOS8) {
        appDelegate.KEYBOARD_HEIGHT = 300;
    }
    
    id <SlideNavigationControllerAnimator> revealAnimator;
    CGFloat animationDuration = 0;
    
    revealAnimator = [[SlideNavigationControllerAnimatorSlideAndFade alloc] initWithMaximumFadeAlpha:.8 fadeColor:[UIColor blackColor] andSlideMovement:100];
    animationDuration = .19;

    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = animationDuration;
    [SlideNavigationController sharedInstance].menuRevealAnimator = revealAnimator;

    self.nSelectedRow = -1;
    
    self.locationMgr = [[CLLocationManager alloc] init];
    self.locationMgr.delegate = self;
    self.locationMgr.distanceFilter = kCLLocationAccuracyHundredMeters;
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationMgr requestWhenInUseAuthorization];
    
    [self.locationMgr startUpdatingLocation];
    
    
    appDelegate.homeView = self;

    //appDelegate.current_latitude = -33.8696;
    //appDelegate.current_longitude = 151.2070;
    //appDelegate.location_updated = YES;

    self.bDataLoaded = NO;
    self.bLoadMore = NO;
    
    self.progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.progress setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    self.whiteSurfaceView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.whiteSurfaceView setBackgroundColor:[UIColor blackColor]];
    [self.whiteSurfaceView setAlpha:1.0f];
    
    self.preload_array = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}


#pragma mark - urlConnection -
- (void) getPerchList
{
    [self.view addSubview:self.whiteSurfaceView];
    [self.view addSubview:self.progress];
    [self.progress startAnimating];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate enablePanGesture:NO];
 
    self.bLoadPerch_lock = YES;
    
    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/getlisting.php";
    //NSString *body = [NSString stringWithFormat:@"latitude=%f&longitude=%f", appDelegate.current_latitude, appDelegate.current_longitude];
    
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:[NSNumber numberWithDouble:appDelegate.current_latitude] forKey:@"latitude"];
    [bodyString setValue:[NSNumber numberWithDouble:appDelegate.current_longitude] forKey:@"longitude"];
    [bodyString setValue:self.preload_array forKey:@"idarray"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyString options:NSJSONWritingPrettyPrinted error:&error];
    NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSURL *callUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:callUrl];
    [urlRequest setTimeoutInterval:180.0f];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self parseResponseOfGetList:data];
                                   });
                               }
                               else if ([data length] == 0 && error == nil){
                                   NSLog(@"Empty Response, not sure why?");
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];
                                   [self.progress stopAnimating];
                                   [self.progress removeFromSuperview];
                                   [self.whiteSurfaceView removeFromSuperview];
                                   [appDelegate enablePanGesture:YES];


                               }
                               else if (error != nil){
                                   NSLog(@"not again, what is the error = %@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];
                                   [self.progress stopAnimating];
                                   [self.progress removeFromSuperview];
                                   [self.whiteSurfaceView removeFromSuperview];
                                   [appDelegate enablePanGesture:YES];

                               }
                               
                           }];
}

- (void) parseResponseOfGetList:(NSData *)data
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    NSError *error = nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil) {
        NSLog(@"Successfully deserialized...");
        
        NSNumber *success = [jsonObject objectForKey:@"result"];
        if ([success integerValue] == 0) {
            NSArray *array = [jsonObject objectForKey:@"listing"];
            for(NSDictionary *item in array)
            {
                PerchItemInfo *info = [[PerchItemInfo alloc] initWithTitle:@""];
                info.nid = [[item objectForKey:@"id"] integerValue];
                info.venue_id = [[item objectForKey:@"venue_id"] integerValue];
                info.title = [item objectForKey:@"title"];
                info.info = [item objectForKey:@"info"];
                info.category = [item objectForKey:@"category"];
                info.days = [item objectForKey:@"days"];
                info.start_time = [item objectForKey:@"list_start"];
                info.end_time = [item objectForKey:@"list_end"];
                info.image = [item objectForKey:@"image"];
                
                [appDelegate.perchArray addObject:info];
                
                if (info.image != nil) {
                    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                           [NSURL URLWithString:info.image]]];
                    
                    if (img != nil) {
                        [self.backImageArray addObject:img];
                    }
                    else {
                        [self.backImageArray addObject:[UIImage imageNamed:@"noImageAvailable.jpg"]];
                    }
                }
                else {
                    [self.backImageArray addObject:[UIImage imageNamed:@"noImageAvailable.jpg"]];
                }
                

            }
            
            
        }
        
    }
    else {
        NSLog(@"error = %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"Server Error"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];

    }
    
    [self.preload_array removeAllObjects];
    for(int i = 0; i < [appDelegate.perchArray count]; i++)
    {
        PerchItemInfo *item = [appDelegate.perchArray objectAtIndex:i];
        
        [self.preload_array addObject:[NSNumber numberWithInteger:item.nid]];

    }
    
    if (self.bLoadMore == NO) {
        [self getVenueList];
    }
    else {
        [self.progress stopAnimating];
        [self.progress removeFromSuperview];
        [self.whiteSurfaceView removeFromSuperview];
        [appDelegate enablePanGesture:YES];
        
        self.bLoadPerch_lock = NO;
        self.bDataLoaded = YES;
        [self.mTableView reloadData];

    }
}

- (void) getVenueList
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/getvenue.php";
    NSURL *callUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:callUrl];
    [urlRequest setTimeoutInterval:120.0f];
    [urlRequest setHTTPMethod:@"POST"];
    //[urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self parseResponseOfGetVenue:data];
                                   });
                               }
                               else if ([data length] == 0 && error == nil){
                                   NSLog(@"Empty Response, not sure why?");
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];

                                   [self.progress stopAnimating];
                                   [self.progress removeFromSuperview];
                                   [self.whiteSurfaceView removeFromSuperview];
                                   [appDelegate enablePanGesture:YES];

                               }
                               else if (error != nil){
                                   NSLog(@"not again, what is the error = %@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];

                                   [self.progress stopAnimating];
                                   [self.progress removeFromSuperview];
                                   [self.whiteSurfaceView removeFromSuperview];
                                   [appDelegate enablePanGesture:YES];

                               }
                               
                           }];
}

- (void) parseResponseOfGetVenue:(NSData *)data
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    NSError *error = nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil) {
        NSLog(@"Successfully deserialized...");
        
        NSNumber *success = [jsonObject objectForKey:@"result"];
        if ([success integerValue] == 0) {
            NSArray *array = [jsonObject objectForKey:@"venue"];
            for(NSDictionary *item in array)
            {
                VenueItem *info = [[VenueItem alloc] initWithTitle:@""];
                info.venue_id = [[item objectForKey:@"venue_id"] integerValue];
                info.name = [item objectForKey:@"name"];
                info.logo_image = [item objectForKey:@"logo"];
                info.venue_image = [item objectForKey:@"image"];
                info.phone_number = [item objectForKey:@"phone"];
                info.website = [item objectForKey:@"website"];
                info.address = [item objectForKey:@"address"];
                info.latitude = [[item objectForKey:@"geolat"] doubleValue];
                info.longitude = [[item objectForKey:@"geolng"] doubleValue];
                
                [appDelegate.venueArray addObject:info];
                
                if (info.logo_image != nil) {
                    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                           [NSURL URLWithString:info.logo_image]]];
                    
                    if (img != nil) {
                        [self.logoImageArray addObject:img];
                    }
                    else {
                        [self.logoImageArray addObject:[UIImage imageNamed:@"noImageAvailable.jpg"]];
                    }
                }
                else {
                    [self.logoImageArray addObject:[UIImage imageNamed:@"noImageAvailable.jpg"]];
                }
                
            }
            
            if (appDelegate.pass_login == YES) {
                [self getStash];
            }
        }
        
    }
    else {
        NSLog(@"error = %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"Server Error"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];

    }
    
    
    [self.progress stopAnimating];
    [self.progress removeFromSuperview];
    [self.whiteSurfaceView removeFromSuperview];
    [appDelegate enablePanGesture:YES];

    self.bLoadPerch_lock = NO;
    self.bDataLoaded = YES;
    [self.mTableView reloadData];
    
}

#pragma mark - viewWillAppear -
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.intro_passed == NO && appDelegate.introPage_presented == NO) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        IntroViewController *introViewController = [storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
        [self presentViewController:introViewController animated:NO completion:nil];
        
    }
    else if (![appDelegate login_passed] && appDelegate.loginPage_presented == NO
             && appDelegate.intro_passed == YES) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:loginViewController animated:NO completion:nil];
        
    }
    else if (self.bLocalNot_locationUpdated == YES && self.bDataLoaded == NO
             && appDelegate.pass_login == YES && self.bLoadPerch_lock == NO) {
        [self getPerchList];
        
    }
    
}

- (void) getStash
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *user_no = [appDelegate.userInfo objectForKey:@"no"];
    if (user_no == nil || [user_no isEqualToString:@""]) {
        return;
    }
    
    [self.view addSubview:self.progress];
    [self.progress startAnimating];
    
    [appDelegate enablePanGesture:NO];
    
    
    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/getstash.php";
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:user_no forKey:@"no"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyString options:NSJSONWritingPrettyPrinted error:&error];
    NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSURL *callUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:callUrl];
    [urlRequest setTimeoutInterval:120.0f];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self parseResponseOfGetStash:data];
                                   });
                               }
                               else if ([data length] == 0 && error == nil){
                                   NSLog(@"Empty Response, not sure why?");
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];
                                   [self.progress stopAnimating];
                                   [self.progress removeFromSuperview];
                                   [appDelegate enablePanGesture:YES];
                                   
                                   
                               }
                               else if (error != nil){
                                   NSLog(@"not again, what is the error = %@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];
                                   [self.progress stopAnimating];
                                   [self.progress removeFromSuperview];
                                   [appDelegate enablePanGesture:YES];
                                   
                                   
                               }
                               
                           }];
    
}

- (void) parseResponseOfGetStash:(NSData *)data
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    NSError *error = nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil) {
        NSLog(@"Successfully deserialized...");
        
        NSNumber *success = [jsonObject objectForKey:@"result"];
        if ([success integerValue] == 0) {
            
            NSArray *stash = [jsonObject objectForKey:@"stash"];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for(NSDictionary *item in stash)
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                
                [dic setValue:[item objectForKey:@"id"] forKey:@"id"];
                [dic setValue:[item objectForKey:@"venue_id"] forKey:@"venue_id"];
                [dic setValue:[item objectForKey:@"title"] forKey:@"title"];
                [dic setValue:[item objectForKey:@"info"] forKey:@"info"];
                [dic setValue:[item objectForKey:@"category"] forKey:@"category"];
                [dic setValue:[item objectForKey:@"days"] forKey:@"days"];
                [dic setValue:[item objectForKey:@"list_start"] forKey:@"list_start"];
                [dic setValue:[item objectForKey:@"list_end"] forKey:@"list_end"];
                [dic setValue:[item objectForKey:@"image"] forKey:@"image"];
                
                
                [array addObject:dic];
            }
            
            [appDelegate.userInfo setValue:array forKey:@"stash"];
            
        }
        else if ([success integerValue] == 1) {
            NSLog(@"user_no = 0");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"Parameter Error"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
            
        }
    }
    else {
        NSLog(@"error = %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"Server Error"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];
        
    }
    
    [self.progress stopAnimating];
    [self.progress removeFromSuperview];
    [appDelegate enablePanGesture:YES];
    
}


#pragma mark - CLLocationDelegate method -
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *new_location = [locations lastObject];
    NSString *strInfo = [NSString stringWithFormat:@"didUpdateToLocation:latitude=%f, longitude=%f", new_location.coordinate.latitude, new_location.coordinate.longitude];
    NSLog(@"%@", strInfo);
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if (new_location.coordinate.latitude == appDelegate.current_latitude && new_location.coordinate.longitude == appDelegate.current_longitude) {
        
        return;
    }
    appDelegate.current_latitude = new_location.coordinate.latitude;
    appDelegate.current_longitude = new_location.coordinate.longitude;
    appDelegate.location_updated = YES;
    if (appDelegate.init_latitude == 0.0f && appDelegate.init_longitude == 0.0f) {
        appDelegate.init_latitude = new_location.coordinate.latitude;
        appDelegate.init_longitude = new_location.coordinate.longitude;
    }
    if (self.bLocalNot_locationUpdated == NO) {
        
        NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/upload_geoloc.php";
        NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
        [bodyString setValue:[NSNumber numberWithDouble:appDelegate.init_latitude] forKey:@"lat1"];
        [bodyString setValue:[NSNumber numberWithDouble:appDelegate.init_longitude] forKey:@"lng1"];
        [bodyString setValue:[NSNumber numberWithDouble:new_location.coordinate.latitude] forKey:@"lat2"];
        [bodyString setValue:[NSNumber numberWithDouble:new_location.coordinate.longitude] forKey:@"lng2"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyString options:NSJSONWritingPrettyPrinted error:&error];
        NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSURL *callUrl = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:callUrl];
        [urlRequest setTimeoutInterval:120.0f];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if ([data length] > 0 && error == nil) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSLog(@"upload_geoloc success");
                                           self.bLocalNot_locationUpdated = YES;
                                           if (self.bLocalNot_locationUpdated == YES && self.bDataLoaded == NO && appDelegate.pass_login == YES && self.bLoadPerch_lock == NO) {
                                               [self getPerchList];
                                           }
                                       });
                                   }
                                   else if ([data length] == 0 && error == nil){
                                       NSLog(@"Empty Response, not sure why?");
                                       
                                   }
                                   else if (error != nil){
                                       NSLog(@"not again, what is the error = %@", error);
                                   }
                                   
                               }];

    }
    
    [self.locationMgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager error!");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                    message:@"Cannot find your current location. Please confirm the if the option (Setting->Privacy->Location Service) is active."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"ok", nil];
    [alert show];
     
    [self.locationMgr stopUpdatingLocation];
}

#pragma mark - tableview data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    return [appDelegate.perchArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cell_id = @"Cell";
    //UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cell_id];
    ProductTableViewCell *cell = (ProductTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductTableViewCell" owner:self options:nil];
        for (id oneObject in nib)
        {
            if ([oneObject isKindOfClass:[ProductTableViewCell class]]) {
                cell = (ProductTableViewCell*)oneObject;
            }
            
        }
        
    }
    
    
    [cell.selected_view setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
    [cell.diselected_view setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
    
    cell.delegate = (id<ProductCellDelegate>)self;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PerchItemInfo *perchItem = [appDelegate.perchArray objectAtIndex:indexPath.row];
    NSInteger venue_id = perchItem.venue_id;
    VenueItem *venueItem = nil;
    for (int i = 0; i < [appDelegate.venueArray count]; i++) {
        VenueItem *item = [appDelegate.venueArray objectAtIndex:i];
        NSInteger _id = item.venue_id;
        if (_id == venue_id) {
            venueItem = item;
            break;
        }
    }
    
    NSArray *category_str = [perchItem.category componentsSeparatedByString:@","];
    for (NSString *category in category_str)
    {
        if ([category isEqualToString:@"1"]) {
            [cell.d_typeFirst_imageView setImage:[UIImage imageNamed:@"listcell_category_1.png"]];
            [cell.d_typeSecond_imageView setImage:[UIImage imageNamed:@"listcell_category_2.png"]];
            [cell.d_typeThird_imageView setHidden:YES];
            [cell.d_typeFirst_imageView setFrame:CGRectMake(cell.frame.size.width/2-2-36,
                                                            cell.frame.size.height * 127/220,
                                                            36, 36)];
            [cell.d_typeSecond_imageView setFrame:CGRectMake(cell.frame.size.width/2+2,
                                                            cell.frame.size.height * 127/220,
                                                            36, 36)];
        }
        else if ([category isEqualToString:@"2"]){
            [cell.d_typeThird_imageView setImage:[UIImage imageNamed:@"listcell_category_3.png"]];
            [cell.d_typeFirst_imageView setHidden:YES];
            [cell.d_typeSecond_imageView setHidden:YES];
            [cell.d_typeThird_imageView setFrame:CGRectMake(cell.frame.size.width/2-18,
                                                            cell.frame.size.height * 127/220,
                                                            36, 36)];
        }
    }
    
    [cell.d_venue_label setText:venueItem.name];
    [cell.d_title_label setText:perchItem.title];
    //[cell.d_background_imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:itemInfo.venue_image]]]];
    /*
    if ([self.backImageArray count] > 0 && indexPath.row < [self.backImageArray count]) {
        UIImage *backImage = [self.backImageArray objectAtIndex:indexPath.row];
        if (backImage) {
            [cell.d_background_imageView setImage:backImage];
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //retrive image on global queue
                UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                       [NSURL URLWithString:perchItem.image]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (img != nil) {
                        [self.backImageArray addObject:img];
                        [cell.d_background_imageView setImage:img];
                    }
                    
                });
            });
        }
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //retrive image on global queue
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                   [NSURL URLWithString:perchItem.image]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (img != nil) {
                    [self.backImageArray addObject:img];
                    [cell.d_background_imageView setImage:img];
                }
                
            });
        });
    }
    */
    [cell.d_background_imageView setImage:[self.backImageArray objectAtIndex:indexPath.row]];
    
    [cell.s_venue_label setText:venueItem.name];
    [cell.s_title_label setText:perchItem.title];
    
    /*
    if ([self.logoImageArray count] > 0 && indexPath.row < [self.logoImageArray count]) {
        UIImage *logoImage = [self.logoImageArray objectAtIndex:indexPath.row];
        if (logoImage) {
            [cell.s_logo_imageView setImage:logoImage];
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //retrive image on global queue
                UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                       [NSURL URLWithString:venueItem.logo_image]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (img != nil) {
                        [self.logoImageArray addObject:img];
                        [cell.s_logo_imageView setImage:img];
                    }
                    
                });
            });
        }
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //retrive image on global queue
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                   [NSURL URLWithString:venueItem.logo_image]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (img != nil) {
                    [self.logoImageArray addObject:img];
                    [cell.s_logo_imageView setImage:img];
                }
                
            });
        });
    }
    */
    
    NSInteger venueIndex;
    for(int j = 0; j < [appDelegate.venueArray count]; j++)
    {
        VenueItem *item = (VenueItem*)[appDelegate.venueArray objectAtIndex:j];
        NSInteger Id = item.venue_id;
        if (venueItem.venue_id == Id) {
            venueIndex = j;
            break;
        }
    }
    [cell.s_logo_imageView setImage:[self.logoImageArray objectAtIndex:venueIndex]];
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:today];
    NSInteger weekday = dateComponents.weekday;
    NSInteger today_weekday = weekday - 1;
    if (today_weekday == 0) {
        today_weekday = 7;
    }
    
    [cell.s_description_label setText:perchItem.info];
    [cell.readmore_textView setText:perchItem.info];
    NSString *info_days_string = perchItem.days;
    NSArray *separted_array = [info_days_string componentsSeparatedByString:@","];
    for (NSString *str in separted_array)
    {
        NSInteger num = [str integerValue];
        switch (num) {
            case 1:
                [cell.s_monday_label setTextColor:[UIColor redColor]];
                break;
            case 2:
                [cell.s_tuesday_label setTextColor:[UIColor redColor]];
                break;
            case 3:
                [cell.s_wednesday_label setTextColor:[UIColor redColor]];
                break;
            case 4:
                [cell.s_thirsday_label setTextColor:[UIColor redColor]];
                break;
            case 5:
                [cell.s_friday_label setTextColor:[UIColor redColor]];
                break;
            case 6:
                [cell.s_saturday_label setTextColor:[UIColor redColor]];
                break;
            case 7:
                [cell.s_sunday_label setTextColor:[UIColor redColor]];
                break;
            default:
                break;
        }
    }
    

    [cell.s_starttime_label setText:[perchItem.start_time substringWithRange:NSMakeRange(0, perchItem.start_time.length-3)]];
    [cell.s_endtime_label setText:[perchItem.end_time substringWithRange:NSMakeRange(0, perchItem.end_time.length-3)]];
    
    return cell;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}

//before select cell
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return indexPath;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSInteger selected_row = indexPath.row;
    
    for (int i = 0; i < [appDelegate.perchArray count]; i++) {
        NSInteger row = i;
        
        ProductTableViewCell *cell = (ProductTableViewCell*)[tableView cellForRowAtIndexPath:
                                                             [NSIndexPath indexPathForRow:row inSection:0]];
        [cell.diselected_view setHidden:NO];
        [cell.readmore_view setHidden:YES];
        [cell.selected_view setHidden:YES];
        [cell.surface_view setHidden:NO];
    }
    
    ProductTableViewCell *cell = (ProductTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell.diselected_view setHidden:YES];
    [cell.surface_view setHidden:YES];
    
    [cell.selected_view setHidden:NO];
    [cell.readmore_view setHidden:YES];
    [cell.s_background_imageView setFrame:cell.selected_view.frame];
    [cell.s_background_imageView setImage:[UIImage imageNamed:@"listcell_select_bg.png"]];
    
    self.nSelectedRow = selected_row;
    
    
    PerchItemInfo *perchItem = [appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger listing_id = perchItem.nid;
    
    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/getstash.php";
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:[NSNumber numberWithInteger:listing_id] forKey:@"listingid"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyString options:NSJSONWritingPrettyPrinted error:&error];
    NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSURL *callUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:callUrl];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       NSLog(@"Listingclick success");
                                   });
                               }
                               else if ([data length] == 0 && error == nil){
                                   NSLog(@"Empty Response, not sure why?");
                                   
                               }
                               else if (error != nil){
                                   NSLog(@"not again, what is the error = %@", error);
                               }
                               
                           }];
    
    /*
    SystemSoundID listclick_audio_soundId = 99993;
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"beep-timberlistingsclicked" ofType:@"aif"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile],
                                     &listclick_audio_soundId);
    AudioServicesPlayAlertSound(listclick_audio_soundId);
    
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"beep-timberlistingsclicked"
                                    ofType: @"aif"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                           error: nil];
    [newPlayer prepareToPlay];
    [newPlayer play];
    */
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - scrollview delegate methods -
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 0) {
        self.bLoadMore = YES;
        [self.whiteSurfaceView setAlpha:0.2f];
        [self getPerchList];
    }
}




#pragma mark - ProductCellDelegate Events -
- (void) closeCell:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    for (int i = 0; i < [appDelegate.perchArray count]; i++) {
        NSInteger row = i;
        
        ProductTableViewCell *cell = (ProductTableViewCell*)[self.mTableView cellForRowAtIndexPath:
                                                             [NSIndexPath indexPathForRow:row inSection:0]];
        [cell.surface_view setHidden:YES];
    }

    if (self.nSelectedRow >= 0 && self.nSelectedRow < [appDelegate.perchArray count]) {
        
        ProductTableViewCell *cell = (ProductTableViewCell*)[self.mTableView cellForRowAtIndexPath:
                                                             [NSIndexPath indexPathForRow:self.nSelectedRow inSection:0]];
        [cell.diselected_view setHidden:NO];
        [cell.selected_view setHidden:YES];
        [cell.surface_view setHidden:YES];
        self.nSelectedRow = -1;
        
    }
}

- (void) stashIt:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PerchItemInfo *perchItem = (PerchItemInfo*)[appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger selected_listingID = perchItem.nid;
    
    BOOL isExist = NO;
    NSMutableArray *stash_array = [appDelegate.userInfo objectForKey:@"stash"];
    for (int i = 0; i < [stash_array count]; i++) {
        NSMutableDictionary *dic = [stash_array objectAtIndex:i];
        NSInteger stash_id = [[dic objectForKey:@"id"] integerValue];
        if (selected_listingID == stash_id) {
            isExist = YES;
            break;
        }
    }
    
    if (isExist == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"This item was already stashed"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];
        return;
    }
    NSString *urlString = @"http://www.perchproject.com.au/auction-code/mobile/stash.php";
    //NSString *body = [NSString stringWithFormat:@"latitude=%f&longitude=%f", appDelegate.current_latitude, appDelegate.current_longitude];
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    NSString *userNO = [appDelegate.userInfo objectForKey:@"no"];
    
    if (userNO == nil || [userNO isEqualToString:@""]) {
        appDelegate.from_stashLoginView = YES;
        [self.blueSurfaceView setHidden:NO];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];

        StashLoginViewController *stashLoginViewController = (StashLoginViewController*)[mainStoryboard
                                                                                instantiateViewControllerWithIdentifier: @"StashLoginViewController"];
        
        stashLoginViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:stashLoginViewController animated:NO completion:nil];

        return;
    }
    
    [bodyString setValue:userNO forKey:@"no"];
    [bodyString setValue:[NSNumber numberWithInteger:selected_listingID] forKey:@"listingid"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyString options:NSJSONWritingPrettyPrinted error:&error];
    NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSURL *callUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:callUrl];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self parseResponseOfStash:data];
                                   });
                               }
                               else if ([data length] == 0 && error == nil){
                                   NSLog(@"Empty Response, not sure why?");
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];

                               }
                               else if (error != nil){
                                   NSLog(@"not again, what is the error = %@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];

                               }
                               
                           }];
    
    
}

- (void) shareIt:(id)sender
{
    /*
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Tweeting from my own app! :)"];
        [tweetSheet addImage:[UIImage imageNamed:@"map_pos_red.png"]];
        [tweetSheet addURL:[NSURL URLWithString:@"http://www.bing.com"]];
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             switch (result) {
                 case SLComposeViewControllerResultCancelled:
                     NSLog(@"Post Canceled");
                     break;
                 case SLComposeViewControllerResultDone:
                     NSLog(@"Post Successful");
                     break;
                 default:
                     break;
             }
         }];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"You can`t send a tweet right now, make sure your device has an internet connection and you have at least one twitter account setup"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
     */
    /*
     if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
         SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
         [facebookSheet setInitialText:@"Tweeting from my own app! :)"];
         [facebookSheet addImage:[UIImage imageNamed:@"map_pos_red.png"]];
         [facebookSheet addURL:[NSURL URLWithString:@"http://www.bing.com"]];
         [facebookSheet setCompletionHandler:^(SLComposeViewControllerResult result)
          {
              switch (result) {
                  case SLComposeViewControllerResultCancelled:
                      NSLog(@"Post Canceled");
                      break;
                  case SLComposeViewControllerResultDone:
                      NSLog(@"Post Successful");
                      break;
                  default:
                      break;
              }
          }];
         [self presentViewController:facebookSheet animated:YES completion:nil];
     
     
     }
    */

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PerchItemInfo *perchItem = (PerchItemInfo*)[appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger venue_id = perchItem.venue_id;
    
    VenueItem *venueItem = nil;
    for(int i = 0; i < [appDelegate.venueArray count]; i++)
    {
        VenueItem *item = (VenueItem*)[appDelegate.venueArray objectAtIndex:i];
        if (item.venue_id == venue_id) {
            venueItem = item;
            break;
        }
    }
    
    if (venueItem == nil) {
        return;
    }

    NSString *textToShare = [NSString stringWithFormat:@"%@ - %@", perchItem.title, perchItem.info];
    NSString *myWebSite = venueItem.website;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:venueItem.logo_image]]];
    NSArray *shareItems = @[textToShare, myWebSite, image];
    
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    [activityViewController setValue:@"Perch Project" forKey:@"subject"];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnItems, NSError *error) {
        if (completed) {
            if ([activityType containsString:@"Facebook"]) {
                [self postShare:0 withContacts:appDelegate.facebook_friendsNum];
            }
            else if([activityType containsString:@"Twitter"]) {
                [self postShare:1 withContacts:appDelegate.twitter_friendsNum];
            }
        }
        else {
            NSLog(@"Sharing canceled!");
        }
    }];

    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void) postShare:(NSInteger)_snsIndex withContacts:(NSInteger)_contactsNum
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PerchItemInfo *perchItem = (PerchItemInfo*)[appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger selected_listingID = perchItem.nid;

    NSString *urlString = @"http://www.perchproject.com.au/auction-code/mobile/share.php";
    //NSString *body = [NSString stringWithFormat:@"latitude=%f&longitude=%f", appDelegate.current_latitude, appDelegate.current_longitude];
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:[appDelegate.userInfo objectForKey:@"no"] forKey:@"no"];
    [bodyString setValue:[NSNumber numberWithInteger:selected_listingID] forKey:@"listingid"];
    if (_snsIndex == 0) {
        [bodyString setValue:@"FB" forKey:@"method"];
    }
    else if (_snsIndex == 1)
    {
        [bodyString setValue:@"TW" forKey:@"method"];
    }
    
    [bodyString setValue:[NSNumber numberWithInteger:_contactsNum] forKey:@"contacts"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyString options:NSJSONWritingPrettyPrinted error:&error];
    NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSURL *callUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:callUrl];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self parseResponseOfShare:data];
                                   });
                               }
                               else if ([data length] == 0 && error == nil){
                                   NSLog(@"Empty Response, not sure why?");
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];

                               }
                               else if (error != nil){
                                   NSLog(@"not again, what is the error = %@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                                   message:@"Server Error"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:nil
                                                                         otherButtonTitles:@"ok", nil];
                                   [alert show];

                               }
                               
                           }];
    
}

- (void) parseResponseOfStash:(NSData *)data
{
    NSString *myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    NSError *error = nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil) {
        NSLog(@"Successfully deserialized...");
        
        NSNumber *success = [jsonObject objectForKey:@"result"];
        if ([success integerValue] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"Stashed successfully"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
            
            [self getStash];
            
        }
        else if ([success integerValue] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"list id or user no is not valid"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];

        }
    }
    else {
        NSLog(@"error = %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"Server Error"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];
    }
    
}

- (void) parseResponseOfShare:(NSData *)data
{
    NSString *myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    NSError *error = nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil) {
        NSLog(@"Successfully deserialized...");
        
        NSNumber *success = [jsonObject objectForKey:@"result"];
        if ([success integerValue] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"shared successfully"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];

        }
        else if ([success integerValue] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"Parameter Error"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];

        }
        
    }
    else {
        NSLog(@"error = %@", error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"Server Error"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];

    }
    
    
}


- (void) shareSMS
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        controller.body = @"SMS message here";
        //controller.recipients = [NSArray arrayWithObjects:@"(87)18740093221", nil];
        controller.messageComposeDelegate=self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - mfmessage delegate -
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction Events -
- (void)readmore:(id)sender
{
    ProductTableViewCell *cell = (ProductTableViewCell*)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.nSelectedRow inSection:0]];
    [cell.selected_view setHidden:YES];
    [cell.readmore_view setHidden:NO];

}

- (void) readback:(id)sender
{
    ProductTableViewCell *cell = (ProductTableViewCell*)[self.mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.nSelectedRow inSection:0]];
    [cell.readmore_view setHidden:YES];
    [cell.selected_view setHidden:NO];
}

- (void) goWebsite:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PerchItemInfo *perchItem = [appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger venueId = perchItem.venue_id;
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

- (void) callPhone:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    PerchItemInfo *perchItem = [appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger venueId = perchItem.venue_id;
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

- (void) showMap:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    PerchItemInfo *perchItem = [appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger venue_id = perchItem.venue_id;
    VenueItem *venueItem = nil;
    for (int i = 0; i < [appDelegate.venueArray count]; i++) {
        VenueItem *item = [appDelegate.venueArray objectAtIndex:i];
        NSInteger _id = item.venue_id;
        if (_id == venue_id) {
            venueItem = item;
            break;
        }
    }

    [appDelegate toggleRight];
    [appDelegate locate:venueItem.venue_id];
}

- (void) callUber:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    PerchItemInfo *perchItem = [appDelegate.perchArray objectAtIndex:self.nSelectedRow];
    NSInteger venueId = perchItem.venue_id;
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

- (void)comeHomeViewFromModal
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if (appDelegate.from_stashLoginView == YES) {
        [self.blueSurfaceView setHidden:YES];
        appDelegate.from_stashLoginView = NO;
    }

    
}

- (void)updateLocation
{
    self.bLocalNot_locationUpdated = NO;
    [self.locationMgr startUpdatingLocation];
}


@end
