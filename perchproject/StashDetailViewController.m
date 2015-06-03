//
//  StashDetailViewController.m
//  perchproject
//
//  Created by Admin on 4/16/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "StashDetailViewController.h"

#import "AppDelegate.h"
#import "PerchItemInfo.h"
#import "VenueItem.h"
#import <Social/Social.h>

#import "GPUberViewController.h"
#import "WebSiteViewController.h"

@interface StashDetailViewController ()

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

@end

@implementation StashDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray *stash_array = [appDelegate.userInfo objectForKey:@"stash"];
    NSMutableDictionary *stash = [stash_array objectAtIndex:self.nSelectedRow];
    
    NSInteger venue_id = [[stash objectForKey:@"venue_id"] integerValue];

    VenueItem *venueItem = nil;
    for (int i = 0; i < [appDelegate.venueArray count]; i++) {
        VenueItem *item = [appDelegate.venueArray objectAtIndex:i];
        NSInteger _id = item.venue_id;
        if (_id == venue_id) {
            venueItem = item;
            break;
        }
    }
    
    
    [self.s_venue_label setText:venueItem.name];
    [self.s_title_label setText:[stash objectForKey:@"title"]];
    //[cell.s_logo_imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:itemInfo.logo_image]]]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //retrive image on global queue
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                               [NSURL URLWithString:venueItem.logo_image]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.s_logo_imageView setImage:img];
        });
    });
    
    
    [self.s_description_label setText:[stash objectForKey:@"info"]];
    NSString *info_days_string = [stash objectForKey:@"days"];
    NSArray *separted_array = [info_days_string componentsSeparatedByString:@","];
    for (NSString *str in separted_array)
    {
        NSInteger num = [str integerValue];
        switch (num) {
            case 1:
                [self.s_monday_label setTextColor:[UIColor redColor]];
                break;
            case 2:
                [self.s_tuesday_label setTextColor:[UIColor redColor]];
                break;
            case 3:
                [self.s_wednesday_label setTextColor:[UIColor redColor]];
                break;
            case 4:
                [self.s_thirsday_label setTextColor:[UIColor redColor]];
                break;
            case 5:
                [self.s_friday_label setTextColor:[UIColor redColor]];
                break;
            case 6:
                [self.s_saturday_label setTextColor:[UIColor redColor]];
                break;
            case 7:
                [self.s_sunday_label setTextColor:[UIColor redColor]];
                break;
            default:
                break;
        }
    }
    
    [self.s_starttime_label setText:[stash objectForKey:@"list_start"]];
    [self.s_endtime_label setText:[stash objectForKey:@"list_end"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate enablePanGesture:YES];
}

- (IBAction) shareIt:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray *stash_array = [appDelegate.userInfo objectForKey:@"stash"];
    NSMutableDictionary *stash = [stash_array objectAtIndex:self.nSelectedRow];

    NSInteger venue_id = [[stash objectForKey:@"venue_id"] integerValue];
    
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
    
    NSString *textToShare = [NSString stringWithFormat:@"%@ - %@", [stash objectForKey:@"title"], [stash objectForKey:@"info"]];
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
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - mfmessage delegate -
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction Events -
- (IBAction) goWebsite:(id)sender
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
        return;
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    WebSiteViewController *websiteViewController = (WebSiteViewController*)[mainStoryboard
                                                                            instantiateViewControllerWithIdentifier: @"WebSiteViewController"];
    
    [websiteViewController loadWebsite:websiteUrl];
    [self presentViewController:websiteViewController animated:YES completion:nil];
    
}

- (IBAction) callPhone:(id)sender
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
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", phoneNumber]]];
}

- (IBAction) showMap:(id)sender
{
    
}

- (IBAction) callUber:(id)sender
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


@end
