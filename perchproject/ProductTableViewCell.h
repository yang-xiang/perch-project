//
//  ProductTableViewCell.h
//  purch_01
//
//  Created by Admin on 3/19/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProductCellDelegate

@optional
- (void) closeCell:(id)sender;
- (void) stashIt:(id)sender;
- (void) shareIt:(id)sender;
- (void) goWebsite:(id)sender;
- (void) callPhone:(id)sender;
- (void) showMap:(id)sender;
- (void) callUber:(id)sender;
- (void) readmore:(id)sender;
- (void) readback:(id)sender;

@end

@interface ProductTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIView        *diselected_view;

@property(nonatomic, weak) IBOutlet UIImageView   *d_background_imageView;
@property(nonatomic, weak) IBOutlet UILabel       *d_venue_label;
@property(nonatomic, weak) IBOutlet UILabel       *d_title_label;
@property(nonatomic, weak) IBOutlet UIImageView   *d_typeFirst_imageView;
@property(nonatomic, weak) IBOutlet UIImageView   *d_typeSecond_imageView;
@property(nonatomic, weak) IBOutlet UIImageView   *d_typeThird_imageView;

@property(nonatomic, weak) IBOutlet UIView        *selected_view;

@property(nonatomic, weak) IBOutlet UIImageView   *s_background_imageView;
@property(nonatomic, weak) IBOutlet UIImageView   *s_logo_imageView;
@property(nonatomic, weak) IBOutlet UILabel       *s_venue_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_title_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_monday_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_tuesday_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_wednesday_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_thirsday_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_friday_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_saturday_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_sunday_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_starttime_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_endtime_label;
@property(nonatomic, weak) IBOutlet UILabel       *s_description_label;
@property(nonatomic, weak) IBOutlet UIButton      *s_stash_btn;
@property(nonatomic, weak) IBOutlet UIButton      *s_share_btn;
@property(nonatomic, weak) IBOutlet UIButton      *s_website_btn;
@property(nonatomic, weak) IBOutlet UIButton      *s_map_btn;
@property(nonatomic, weak) IBOutlet UIButton      *s_phone_btn;
@property(nonatomic, weak) IBOutlet UIButton      *s_uber_btn;
@property(nonatomic, weak) IBOutlet UILabel       *s_tomorrow_label;

@property(nonatomic, weak) IBOutlet UIView        *readmore_view;
@property(nonatomic, weak) IBOutlet UITextView    *readmore_textView;

@property(nonatomic, weak) IBOutlet UIView        *surface_view;



@property(nonatomic, strong) id<ProductCellDelegate> delegate;
- (IBAction) closeCell:(id)sender;
- (IBAction) stashIt:(id)sender;
- (IBAction) shareIt:(id)sender;
- (IBAction) goWebsite:(id)sender;
- (IBAction) callPhone:(id)sender;
- (IBAction) showMap:(id)sender;
- (IBAction) callUber:(id)sender;
- (IBAction) readmore:(id)sender;
- (IBAction) readback:(id)sender;

@end


