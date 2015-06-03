//
//  AppDelegate.m
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.pushRemote_deviceToken = @"";
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySetting = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySetting];
    
    [application registerForRemoteNotifications];
    
    application.applicationIconBadgeNumber = 0;
    
    self.locate_timer = [NSTimer scheduledTimerWithTimeInterval:2700 target:self selector:@selector(timerCounter:) userInfo:nil repeats:YES];
    [self.locate_timer fire];
    
    
    self.enablePanGesture = YES;

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    ProfileViewController *leftMenu = (ProfileViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"ProfileViewController"];
    
    MapViewController *rightMenu = (MapViewController*)[mainStoryboard
                                                                    instantiateViewControllerWithIdentifier: @"MapViewController"];
    
    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;

    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
        
        /*
        SystemSoundID slide_audio_soundId = 99992;
        NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"slide-metalslidescreen" ofType:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile],
                                         &slide_audio_soundId);
        AudioServicesPlayAlertSound(slide_audio_soundId);
        
        
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"slide_metalslidescreen"
                                                                  ofType: @"mp3"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                                          error: nil];
        [newPlayer prepareToPlay];
        [newPlayer play];
         */
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
        /*
        SystemSoundID slide_audio_soundId = 99992;
        NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"slide-metalslidescreen" ofType:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile],
                                         &slide_audio_soundId);
        AudioServicesPlayAlertSound(slide_audio_soundId);
        
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource: @"slide_metalslidescreen"
                                                                  ofType: @"mp3"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
        
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                                          error: nil];
        [newPlayer prepareToPlay];
        [newPlayer play];
         */
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    
    self.location_updated = NO;
    self.pass_login = NO;
    self.intro_passed = NO;
    self.facebook_friendsNum = 0;
    self.twitter_friendsNum = 0;
    self.from_stashLoginView = NO;
    self.userInfo = [[NSMutableDictionary alloc] init];
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    self.data_plist_path = [documentDirectory stringByAppendingPathComponent:@"data.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.data_plist_path]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath:self.data_plist_path error:&error];
    }
    
    self.userInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:self.data_plist_path];
    self.pass_login = [[self.userInfo objectForKey:@"logined"] boolValue];
    self.intro_passed = [[self.userInfo objectForKey:@"intro_passed"] boolValue];
    
    self.perchArray = [[NSMutableArray alloc] init];
    self.venueArray = [[NSMutableArray alloc] init];

    self.init_latitude = 0.0f;
    self.init_longitude = 0.0f;

    
    
    return YES;
}

- (void) writeUserInfo
{
    
    [self.userInfo writeToFile:self.data_plist_path atomically:YES];
}

- (NSMutableDictionary *) readUserInfo
{
    return self.userInfo;
}

- (BOOL)login_passed
{
    BOOL logined = [[self.userInfo objectForKey:@"logined"] boolValue];
    return logined;
}

- (void)enablePanGesture:(BOOL)enableFlag
{
    self.enablePanGesture = enableFlag;
}

- (void)comeHomeViewFromModal
{
    [self.homeView comeHomeViewFromModal];
}

- (void)timerCounter:(NSTimer *)timer
{
    [self.homeView updateLocation];
}

- (void)loadPerch
{
    [self.homeView viewDidAppear:NO];
}

- (void)toogleLeft
{
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)toggleRight
{
    [[SlideNavigationController sharedInstance] toggleRightMenu];
}

- (void)locate:(NSInteger)venue_id
{
    [self.mapView locate:venue_id];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Set icon badge number to zero
    application.applicationIconBadgeNumber += 1;

    NSLog(@"Remote Notification: %@", [userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *messageBody = [[apsInfo objectForKey:@"alert"] objectForKey:@"body"];
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:messageBody
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];
        
        application.applicationIconBadgeNumber = 0;

        [self.homeView updateLocation];
    }
    

}

- (void)uploadDeviceToken
{
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/appcheck.php";
    
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];

    [bodyString setValue:@"i" forKey:@"type"];
    [bodyString setValue:self.pushRemote_deviceToken forKey:@"regid"];
    [bodyString setValue:uuid forKey:@"udid"];
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
                                       [self parseResponseOfUploadToken:data];
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

- (void)parseResponseOfUploadToken:(NSData *)data
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
            
            NSLog(@"AppCheck response success");
            

        }
        else if ([success integerValue] == 1) {
            NSLog(@"type or regid is invalid");
            
        }
        else if ([success integerValue] == 2) {
            NSLog(@"this token is already registered!");
            
        }
        
    }
    else
    {
        NSLog(@"error = %@", error.description);
    }

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    self.pushRemote_deviceToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"device token = %@", self.pushRemote_deviceToken);
    [self uploadDeviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to register. Error : %@", error);
}

 
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [self.locate_timer invalidate];
    [self.locate_timer finalize];
    self.locate_timer = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];

}

@end
