//
//  ProfileViewController.m
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "ProfileTableViewCell.h"
#import "StashDetailViewController.h"
#import "WebSiteViewController.h"
#import "Uber/AFNetworking/AFNetworking.h"

#import <Social/Social.h>

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *mProfileImageView;
@property (nonatomic, weak) IBOutlet UIButton *mStash_button;
@property (nonatomic, weak) IBOutlet UIView *mTableParentView;
@property (nonatomic, weak) IBOutlet UIView *mStashTable_ParentView;
@property (nonatomic, weak) IBOutlet UITableView *mProfileList_tableView;
@property (nonatomic, weak) IBOutlet UILabel *mUserName_label;
@property (nonatomic, weak) IBOutlet UILabel *mStashCount_label;

@property (nonatomic, weak) IBOutlet UIButton *mFB_button;
@property (nonatomic, weak) IBOutlet UIButton *mTW_button;

@property (nonatomic) BOOL bMyStash_displayed;
@property (nonatomic) NSInteger nScreenWidth;
@property (nonatomic) NSInteger nScreenHeight;

@property (nonatomic, retain) UIActivityIndicatorView *progress;

@property (nonatomic, retain) UIImage *capturedImage;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bMyStash_displayed = NO;

    self.nScreenWidth = self.view.frame.size.width;
    self.nScreenHeight = self.view.frame.size.height;

    self.capturedImage = [[UIImage alloc] init];
    [self.mProfileList_tableView setContentSize:CGSizeMake(self.nScreenWidth - 25, 100)];
    [self.mProfileList_tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.mProfileList_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingString:@"captureimage.jpg"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //retrive image on global queue
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[appDelegate.userInfo objectForKey:@"image"]] ]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (image == nil) {
                [self.mProfileImageView setImage:[UIImage imageNamed:@"default_profile_image.png"]];
            }
            else {
                [self.mProfileImageView setImage:image];
            }

        });
    });

    self.mProfileImageView.layer.cornerRadius = self.mProfileImageView.frame.size.width/2;
    self.mProfileImageView.clipsToBounds = YES;
    
    if ([[appDelegate.userInfo objectForKey:@"social"] integerValue] == 10)
    {
        //[self.mFB_button.titleLabel setTextColor:[UIColor whiteColor]];
        [self.mFB_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else if ([[appDelegate.userInfo objectForKey:@"social"] integerValue] == 11)
    {
        //[self.mTW_button.titleLabel setTextColor:[UIColor whiteColor]];
        [self.mTW_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    [self.mUserName_label setText:[appDelegate.userInfo objectForKey:@"username"]];

    self.progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.progress setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *stash_array = [appDelegate.userInfo objectForKey:@"stash"];
    NSInteger stash_count = [stash_array count];

    if (stash_count > 0) {
        [self.mStashCount_label setText:[NSString stringWithFormat:@"%ld", (long)stash_count]];
    }
    
    [self.mProfileList_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (void) postShare
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *urlString = @"http://www.perchproject.com.au/auction-code/mobile/share.php";
    //NSString *body = [NSString stringWithFormat:@"latitude=%f&longitude=%f", appDelegate.current_latitude, appDelegate.current_longitude];
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:[appDelegate.userInfo objectForKey:@"no"] forKey:@"no"];
    [bodyString setValue:[NSNumber numberWithInt:0] forKey:@"listingid"];
    [bodyString setValue:[NSNumber numberWithInt:0] forKey:@"method"];
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
                               }
                               else if (error != nil){
                                   NSLog(@"not again, what is the error = %@", error);
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
            
        }
        else if ([success integerValue] == 1) {
            
        }
        else if ([success integerValue] == 2) {
            
        }
    }
    else {
        NSLog(@"error = %@", error.description);
    }
    
    
}



#pragma tableview data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *stash_array = [appDelegate.userInfo objectForKey:@"stash"];
    return [stash_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell_id = @"Cell";
    ProfileTableViewCell *cell = (ProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileListCell" owner:self options:nil];
        for (id oneObject in nib)
        {
            if ([oneObject isKindOfClass:[ProfileTableViewCell class]]) {
                cell = (ProfileTableViewCell*)oneObject;
            }
        }
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *stash_array = [appDelegate.userInfo objectForKey:@"stash"];
    NSMutableDictionary *stash = [stash_array objectAtIndex:indexPath.row];
    [cell.title_label setText:[stash objectForKey:@"title"] ];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //retrive image on global queue
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                               [NSURL URLWithString:[stash objectForKey:@"image"]]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (img != nil) {
                [cell.logo_imageView setImage:img];
            }
            else {
                [cell.logo_imageView setImage:[UIImage imageNamed:@"noImageAvailable.jpg"]];
            }
            
        });
    });

    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//before select cell
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate enablePanGesture:NO];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    StashDetailViewController *detailViewController = (StashDetailViewController*)[mainStoryboard
                                                                            instantiateViewControllerWithIdentifier: @"StashDetailViewController"];
    
    detailViewController.nSelectedRow = indexPath.row;
    [self presentViewController:detailViewController animated:YES completion:nil];

    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma IBAction Events
- (IBAction)action_showStash:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *stash_array = [appDelegate.userInfo objectForKey:@"stash"];
    NSInteger stash_count = [stash_array count];

    if (stash_count == 0) {
        return;
    }
    
    if (self.bMyStash_displayed == NO) {
        [self.mStashTable_ParentView setFrame:CGRectMake(0, self.nScreenHeight-265, self.nScreenWidth, 155)];
        [self.mTableParentView setHidden:NO];
        [self.mTableParentView setFrame:CGRectMake(0, 55, self.nScreenWidth, 100)];
        
        self.bMyStash_displayed = YES;
    }
    else{
        [self.mTableParentView setFrame:CGRectMake(0, 50, self.nScreenWidth, 0)];
        [self.mTableParentView setHidden:YES];
        [self.mStashTable_ParentView setFrame:CGRectMake(0, self.nScreenHeight-156, self.nScreenWidth, 50)];
        
        self.bMyStash_displayed = NO;
    }
    
}

- (IBAction)action_shareFB:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.facebookAccount != nil && [appDelegate.facebookAccount.identifier isEqualToString:@""] == NO) {
        [self.mFB_button.titleLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            
            NSDictionary *options = @{
                                      ACFacebookAppIdKey : FACEBOOK_APP_ID_KEY,
                                      ACFacebookPermissionsKey : @[@"email", @"user_friends"],
                                      ACFacebookAudienceKey : ACFacebookAudienceFriends
                                      };
            
            [accountStore requestAccessToAccountsWithType:accountType
                                                  options:options completion:^(BOOL granted, NSError *error)
             {
                 if (granted) {
                     [self.mFB_button.titleLabel setTextColor:[UIColor whiteColor]];
                 }
                 else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:@"No FB account can be found"
                                                                    delegate:nil
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:@"ok", nil];
                     [alert show];
                 }
                 
             }];
             
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"No FB account can be found"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
        }
    }

}

- (IBAction)action_shareTW:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.twitterAccount != nil && [appDelegate.twitterAccount.identifier isEqualToString:@""] == NO) {
        [self.mTW_button.titleLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [accountStore requestAccessToAccountsWithType:accountType
                                                  options:nil completion:^(BOOL granted, NSError *error)
             {
                 if (granted) {
                     [self.mTW_button.titleLabel setTextColor:[UIColor whiteColor]];
                 }
                 else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:@"No TW account can be found"
                                                                    delegate:nil
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:@"ok", nil];
                     [alert show];
                 }
                 
             }];
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"No TW account can be found"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
        }

    }

}

- (IBAction)action_feedback:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *emailTitle = @"Feedback about PerchProject";
        // Email Content
        NSString *messageBody = @"";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@"simone@perchproject.com.au"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
    }
}

#pragma mark - mfmailcomposer delegate -
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)action_share:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *textToShare = @"PerchProject iPhone App";
    UIImage *image = [UIImage imageNamed:@"icon_120.png"];
    NSArray *shareItems = @[textToShare, image];
    
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    [activityViewController setValue:@"Perch Project" forKey:@"subject"];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnItems, NSError *error) {
        if (completed) {
            NSLog(@"Sharing success!");
        }
        else {
            NSLog(@"Sharing canceled!");
        }
    }];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

- (IBAction)action_rate:(id)sender
{
    [[UIApplication sharedApplication] openURL:
        [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id988826339"]];
}

- (IBAction)action_uploadProfileImg:(id)sender
{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)privacyPolicy:(id)sender
{
    NSString *websiteUrl = @"https://perchproject.com.au/privacy-policy.php";
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    WebSiteViewController *websiteViewController = (WebSiteViewController*)[mainStoryboard
                                                                            instantiateViewControllerWithIdentifier: @"WebSiteViewController"];
    
    [websiteViewController loadWebsite:websiteUrl];
    [self presentViewController:websiteViewController animated:YES completion:nil];

}

#pragma mark - uiimagepickercontroller delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.capturedImage = info[UIImagePickerControllerEditedImage];
    
    UIImageWriteToSavedPhotosAlbum(self.capturedImage, nil, nil, nil);
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self uploadProfileImage:self.capturedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadProfileImage:(UIImage *)image
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *user_no = [appDelegate.userInfo objectForKey:@"no"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", nil];
    
    NSDictionary *param = @{@"no" : user_no};
    
    [manager POST:@"http://www.perchproject.com.au/auction-code/mobile/uploadimg.php"
       parameters:param
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1)
                                        name:@"file"
                                    fileName:@"photo"
                                    mimeType:@"image/jpeg" ] ;
        }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"success:%@", responseObject);
              NSError *error = nil;
              /*
              NSDictionary *responseDic = (NSDictionary*)responseObject;
              
              
              
              NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:NSJSONReadingAllowFragments error:&error];
              */
              NSDictionary *jsonObject = (NSDictionary*)responseObject;
              
              if (jsonObject != nil && error == nil) {
                  NSLog(@"Successfully deserialized...");
                  
                  NSNumber *success = [jsonObject objectForKey:@"result"];
                  if ([success integerValue] == 0) {
                      
                      [self.mProfileImageView setImage:self.capturedImage];
                      
                      [appDelegate.userInfo setObject:[jsonObject objectForKey:@"image"] forKey:@"image"];
                      [appDelegate writeUserInfo];
                      
                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                      message:@"Your profile image was uploaded successfully"delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil, nil];
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
                  else if ([success integerValue] == 2) {
                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                      message:@"Server Error"
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"ok", nil];
                      [alert show];
                      
                  }
                  else if ([success integerValue] == 3) {
                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                                      message:@"Server Error"
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
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error:%@", error);
          }];
    
}


@end
