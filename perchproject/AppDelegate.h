//
//  AppDelegate.h
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"
#import "HomeViewController.h"

#import <Accounts/Accounts.h>

#define FACEBOOK_APP_ID_KEY @"351913064990947"
#define UBER_CLIENT_ID @"8gI1Q4vdJFBu8Koz-bA6DsRGglxtCdLu"
#define UBER_SERVER_TOKEN @"HNKxLXuPMyRWoqL_yj8wMd_u67u4Sx4-XauIs4P1"

//#define KEYBOARD_HEIGHT 250

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI

#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)

#define IS_IPHONE_5 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_5_IOS8 : IS_IPHONE_5_IOS7 )
#define IS_IPHONE_6 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6_IOS8 : IS_IPHONE_6_IOS7 )
#define IS_IPHONE_6P ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6P_IOS8 : IS_IPHONE_6P_IOS7 )
#define IS_IPHONE_4_AND_OLDER ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_4_AND_OLDER_IOS8 : IS_IPHONE_4_AND_OLDER_IOS7 )

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic) ACAccount *twitterAccount;
@property(nonatomic) ACAccount *facebookAccount;
@property(nonatomic, retain) NSString *facebook_id;
@property(nonatomic, retain) NSString *twitter_id;
@property(nonatomic) double current_latitude;
@property(nonatomic) double current_longitude;
@property(nonatomic) double init_latitude;
@property(nonatomic) double init_longitude;

@property(nonatomic) BOOL   location_updated;
@property(nonatomic) BOOL   pass_login;
@property(nonatomic) BOOL   intro_passed;
@property(nonatomic, retain) NSMutableDictionary *userInfo;
@property(nonatomic, retain) NSString *data_plist_path;
@property(nonatomic, retain) NSMutableArray *perchArray;
@property(nonatomic, retain) NSMutableArray *venueArray;

@property (nonatomic, assign) BOOL enablePanGesture;

@property(nonatomic) NSInteger facebook_friendsNum;
@property(nonatomic) NSInteger twitter_friendsNum;

@property(nonatomic) BOOL   from_stashLoginView;
@property(nonatomic, retain) HomeViewController *homeView;
@property(nonatomic, retain) MapViewController *mapView;

@property(nonatomic) NSInteger KEYBOARD_HEIGHT;

@property(nonatomic, retain) NSString *pushRemote_deviceToken;

@property(nonatomic, retain) NSTimer *locate_timer;

@property(nonatomic, assign) BOOL introPage_presented;
@property(nonatomic, assign) BOOL loginPage_presented;



- (void) writeUserInfo;
- (NSMutableDictionary *) readUserInfo;
- (BOOL) login_passed;
- (void)enablePanGesture:(BOOL)enableFlag;

- (void)comeHomeViewFromModal;
- (void)loadPerch;

- (void)toogleLeft;
- (void)toggleRight;

- (void)locate:(NSInteger)venue_id;

@end

