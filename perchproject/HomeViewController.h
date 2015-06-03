//
//  HomeViewController.h
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

#import "SlideNavigationController.h"
#import "ProductTableViewCell.h"

@interface HomeViewController : UIViewController<SlideNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, ProductCellDelegate, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate>

- (void) closeCell:(id)sender;
- (void) stashIt:(id)sender;
- (void) shareIt:(id)sender;
- (void) goWebsite:(id)sender;
- (void) callPhone:(id)sender;
- (void) showMap:(id)sender;
- (void) callUber:(id)sender;
- (void) readmore:(id)sender;
- (void) readback:(id)sender;
- (void)comeHomeViewFromModal;
- (void)updateLocation;

@end
