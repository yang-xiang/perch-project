//
//  StashDetailViewController.h
//  perchproject
//
//  Created by Admin on 4/16/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface StashDetailViewController : UIViewController <MFMessageComposeViewControllerDelegate>

@property(nonatomic, assign) NSInteger nSelectedRow;

- (IBAction)closeView:(id)sender;

@end
