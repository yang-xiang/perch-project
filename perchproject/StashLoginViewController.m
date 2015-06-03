//
//  StashLoginViewController.m
//  perchproject
//
//  Created by Admin on 4/6/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "StashLoginViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>

#import "Uber/AFNetworking/AFNetworking.h"


@interface StashLoginViewController ()

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UIImageView *small_imageView;
@property(nonatomic, weak) IBOutlet UIImageView *big_imageView;

@property(nonatomic, weak) IBOutlet UILabel *title_label;
@property(nonatomic, weak) IBOutlet UILabel *subtitle_label_first;
@property(nonatomic, weak) IBOutlet UILabel *subtitle_label_second;
@property(nonatomic, weak) IBOutlet UILabel *subtitle_label_third;

@property(nonatomic, weak) IBOutlet UIButton *facebook_login_btn;
@property(nonatomic, weak) IBOutlet UIButton *twitter_login_btn;
@property(nonatomic, weak) IBOutlet UIButton *email_join_btn;

@property(nonatomic, weak) IBOutlet UIView *email_menu;
@property(nonatomic, weak) IBOutlet UITextField *username_textField;
@property(nonatomic, weak) IBOutlet UITextField *email_textField;
@property(nonatomic, weak) IBOutlet UITextField *password_textField;
@property(nonatomic, weak) IBOutlet UITextField *confirm_textField;
@property(nonatomic, weak) IBOutlet UIButton      *go_btn;

@property(nonatomic, weak) IBOutlet UIButton *nothanks_btn;

@property (nonatomic) BOOL bEmailMenu_displayed;
@property (nonatomic) NSInteger nScreenWidth;
@property (nonatomic) NSInteger nScreenHeight;
@property (nonatomic) NSInteger nScrollViewHeight;
@property (nonatomic) CGFloat nEmailJoinBtnPosY;

@property (nonatomic) BOOL bKeyboardVisible;
@property (nonatomic) CGPoint fScrollView_Offset;

@property (nonatomic, retain) UIImage *facebook_profile_image;
@property (nonatomic, retain) UIImage *twitter_profile_image;
@property (nonatomic, retain) NSString *birthday_year;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *lives;


@end

@implementation StashLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nScreenWidth = self.view.frame.size.width;
    self.nScreenHeight = self.view.frame.size.height;
    self.nScrollViewHeight = self.view.frame.size.height;
    self.nEmailJoinBtnPosY = self.email_join_btn.frame.origin.y;
    self.bEmailMenu_displayed = NO;
    self.bKeyboardVisible = NO;
    
    [self.big_imageView setHidden:YES];
    [self.email_menu setHidden:YES];
    

    self.scrollView.contentSize = CGSizeMake(self.nScreenWidth,
                                             self.nScreenHeight * 3/2);
    self.scrollView.scrollEnabled = FALSE;
    
    self.username_textField.delegate = self;
    self.username_textField.returnKeyType = UIReturnKeyNext;

    self.email_textField.delegate = self;
    self.email_textField.returnKeyType = UIReturnKeyNext;

    self.password_textField.delegate = self;
    self.password_textField.returnKeyType = UIReturnKeyNext;

    self.confirm_textField.delegate = self;
    self.confirm_textField.returnKeyType = UIReturnKeyDone;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

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

- (IBAction)facebook_login:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
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
                 appDelegate.facebookAccount = [[accountStore accountsWithAccountType:accountType] lastObject];
                 NSLog(@"Facebook UserName: %@, ID: %@", appDelegate.facebookAccount.username, appDelegate.facebookAccount.identifier);
                 
                 NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
                 
                 SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                           requestMethod:SLRequestMethodGET
                                                                     URL:meurl
                                                              parameters:nil];
                 
                 merequest.account = appDelegate.facebookAccount;
                 
                 [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                     NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                     
                     NSLog(@"%@", meDataString);
                     
                     NSError* error2 = nil;
                     if (responseData != nil) {
                         NSDictionary* json = [NSJSONSerialization
                                               JSONObjectWithData:responseData //1
                                               options:NSJSONReadingAllowFragments
                                               error:&error2];
                         
                         NSString *bithday = [json objectForKey:@"birthday"];
                         NSArray *array = [bithday componentsSeparatedByString:@"/"];
                         self.birthday_year = [array lastObject];
                         self.gender = [json objectForKey:@"gender"];
                         self.lives = [[json objectForKey:@"location"] objectForKey:@"name"];
                         appDelegate.facebook_id = [json objectForKey:@"id"];
                         
                         NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", appDelegate.facebook_id];
                         self.facebook_profile_image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
                         
                         [self social_login:0 withId:appDelegate.facebookAccount.identifier withName:appDelegate.facebookAccount.username];
                         
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Server"
                                                                         message:@"No response"
                                                                        delegate:nil
                                                               cancelButtonTitle:nil
                                                               otherButtonTitles:@"ok", nil];
                         [alert show];
                     }
                     
                 }];
                 
                 
             }
             else {
                 if (error == nil) {
                     NSLog(@"User Has disabled your app from settings...");
                 }
                 else {
                     NSLog(@"Error in Login: %@", error);
                 }
             }
         }];
    }
    else {
        NSLog(@"Not configured in Setting...");
    }
}

- (IBAction)twitter_login:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountType
                                              options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted) {
                 appDelegate.twitterAccount = [[accountStore accountsWithAccountType:accountType] lastObject];
                 NSLog(@"Twitter UserName: %@, ID: %@", appDelegate.twitterAccount.username, appDelegate.twitterAccount.identifier);
                 
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 NSDictionary *params = @{@"screen_name" : appDelegate.twitterAccount.username
                                          };
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:appDelegate.twitterAccount];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             
                             NSError* error = nil;
                             NSDictionary* json = [NSJSONSerialization
                                                   JSONObjectWithData:responseData //1
                                                   options:NSJSONReadingAllowFragments
                                                   error:&error];
                             
                             NSString *name = [json objectForKey:@"name"];
                             NSString *scrnm = [json objectForKey:@"screen_name"];
                             appDelegate.twitter_id = [json objectForKey:@"id"];
                             NSString *prof_img = [json objectForKey:@"profile_image_url"];
                             NSString *location = [json objectForKey:@"location"];
                             
                             self.twitter_profile_image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:prof_img]]];
                             
                             [self social_login:1 withId:appDelegate.twitterAccount.identifier withName:appDelegate.twitterAccount.username];
                             
                             
                         }
                         else {
                             
                             NSLog(@"The response status code is %lu", (long)urlResponse.statusCode);
                         }
                     }
                     else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Server"
                                                                         message:@"No response"
                                                                        delegate:nil
                                                               cancelButtonTitle:nil
                                                               otherButtonTitles:@"ok", nil];
                         [alert show];
                     }
                 }];
                 
                 
             }
             else {
                 if (error == nil) {
                     NSLog(@"User Has disabled your app from settings...");
                 }
                 else {
                     NSLog(@"Error in Login: %@", error);
                 }
             }
         }];
    }
    else {
        NSLog(@"Not configured in Setting...");
    }
}


- (void)social_login:(NSInteger)_snsIndex withId:(NSString*)_snsIdentifier withName:(NSString*)_username
{
    NSInteger type = 12;
    if (_snsIndex == 0) {
        type = 10;
    }
    else if (_snsIndex == 1) {
        type = 11;
    }
    
    NSString *password = @"";
    
    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/login.php";
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [bodyString setValue:_snsIdentifier forKey:@"keyid"];
    [bodyString setValue:password forKey:@"password"];
    [bodyString setValue:_username forKey:@"username"];
    if (type == 10) {
        [bodyString setValue:self.birthday_year forKey:@"age"];
        NSString *gender;
        if ([self.gender isEqualToString:@"male"]) {
            gender = @"m";
        }
        else if ([self.gender isEqualToString:@"female"])
        {
            gender = @"f";
        }
        [bodyString setValue:gender forKey:@"gender"];
        [bodyString setValue:self.lives forKey:@"live"];
    }
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
                                       [self parseResponseOfLogin:data type:type];
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
    
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (_snsIndex == 0) {
        NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:meurl parameters:
                              @{@"fields":@"id, name, email, picture, first_name, last_name, gender, installed"}];
        request.account = appDelegate.facebookAccount;
        [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
            if (!error) {
                NSDictionary *list = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if ([list objectForKey:@"error"] != nil) {
                    NSLog(@"list Error");
                }
                else
                {
                    NSArray *dictFbFriend = [list objectForKey:@"data"];
                    appDelegate.facebook_friendsNum = [[[list objectForKey:@"summary"] objectForKey:@"total_count"] integerValue];
                    /*
                     for (NSDictionary *dict in dictFbFriend)
                     {
                     NSDictionary *pictureDataDict = [[dict objectForKey:@"picture"] objectForKey:@"data"];
                     
                     Contact *objContact = [[Contacts alloc] initWithName:[dict objectForKey:@"name"]
                     andEmail:nil
                     andFirstName:[dict objectForKey:@"first_name"]
                     andLastName:[dict objectForKey:@"last_name"]
                     andGender:[dict objectForKey:@"gender"]
                     andPhotoPath:[pictureDataDict objectForKey:@"url"]
                     andIsInstalled:[dict objectForKey:@"installed"] ? [[dict objectForKey:@"installed"] boolValue] : NO
                     andFacebookId:[dict objectForKey:@"id"]
                     ];
                     
                     [self.arrayFriendsList addObject:objContact];
                     objContact = nil;
                     }
                     */
                    
                }
            }
            else
            {
                NSLog(@"request Error:%@", error);
            }
        }];
    }
    else if(_snsIndex == 1)
    {
        NSURL *twitterApiUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json?"];
        SLRequest *twitterRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:twitterApiUrl parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", appDelegate.twitterAccount.username],
                                                                                                                                                         @"screen_name", @"-1", @"cursor"                                                                                       , nil]];
        [twitterRequest setAccount:appDelegate.twitterAccount];
        [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Check if we reached the reate limit
                if ([response statusCode] == 429) {
                    NSLog(@"Rate limit reached");
                    return;
                    
                }
                if (error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                    return;
                }
                if (responseData) {
                    NSError *error = nil;
                    NSArray *twData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    
                    appDelegate.twitter_friendsNum = [[(NSDictionary*)twData objectForKey:@"followers_count"] integerValue];
                }
            });
        }];
    }
    
}

- (void)uploadProfileImage:(UIImage *)image type:(NSInteger)_type
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *user_no = [appDelegate.userInfo objectForKey:@"no"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", nil];
    
    NSDictionary *param = @{@"no" : user_no};
    
    [manager POST:@"https://www.perchproject.com.au/auction-code/mobile/uploadimg.php"
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
                      
                      [appDelegate.userInfo setObject:[jsonObject objectForKey:@"image"] forKey:@"image"];
                      [appDelegate writeUserInfo];
                      
                  }
                  else if ([success integerValue] == 1) {
                      
                      NSLog(@"result 1");
                  }
                  else if ([success integerValue] == 2) {
                      NSLog(@"result 2");
                  }
                  else if ([success integerValue] == 3) {
                      NSLog(@"result 3");
                  }
              }
              else {
                  NSLog(@"error = %@", error.description);
                  
                  
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error:%@", error);
          }];
    
}

- (void) parseResponseOfLogin:(NSData *)data type:(NSInteger)_type
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
            
            NSDictionary *userInfo = [jsonObject objectForKey:@"userinfo"];
            
            [appDelegate.userInfo setValue:[userInfo objectForKey:@"no"] forKey:@"no"];
            [appDelegate.userInfo setValue:[userInfo objectForKey:@"image"] forKey:@"image"];
            [appDelegate.userInfo setValue:[userInfo objectForKey:@"username"] forKey:@"username"];
            
            NSString *keyid = [self.email_textField text];
            if ([keyid isEqualToString:@""]) {
                keyid = [self.email_textField text];
            }
            NSString *password = [self.password_textField text];
            if ([password isEqualToString:@""]) {
                password = [self.password_textField text];
            }
            
            [appDelegate.userInfo setObject:keyid forKey:@"email"];
            [appDelegate.userInfo setObject:password forKey:@"password"];
            [appDelegate.userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"logined"];
            
            if (_type == 10) {
                [appDelegate.userInfo setObject:[NSNumber numberWithInt:10] forKey:@"social"];
                [self uploadProfileImage:self.facebook_profile_image type:10];
            }
            else if (_type == 11) {
                [appDelegate.userInfo setObject:[NSNumber numberWithInt:11] forKey:@"social"];
                [self uploadProfileImage:self.twitter_profile_image type:11];
            }
            
            [appDelegate writeUserInfo];
            
        }
        else if ([success integerValue] == 1) {
            NSLog(@"type = 10 or type > 13");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"Type is not valid"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
        }
        else if ([success integerValue] == 2) {
            NSLog(@"keyid = ''");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"Email Address parameter is empty"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
        }
        else if ([success integerValue] == 3) {
            NSLog(@"email address is not valid");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"email address is not valid"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
        }
        else if ([success integerValue] == 4) {
            NSLog(@"password is incorrect");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"password is incorrect"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
            
        }
        else if ([success integerValue] == 5) {
            NSLog(@"email address is not exist");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"email address is not exist"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
            
        }
        else if ([success integerValue] == 6) {
            NSLog(@"Unknown error");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                            message:@"Unknown error"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"ok", nil];
            [alert show];
            
        }
        
    }
    else
    {
        NSLog(@"error = %@", error.description);
    }
    
    //appDelegate.location_updated = YES;
    appDelegate.pass_login = YES;
    appDelegate.loginPage_presented = NO;
    
    [appDelegate comeHomeViewFromModal];

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)email_showMenu:(id)sender
{
    if (self.bEmailMenu_displayed == NO) {
        [self.email_join_btn setHidden:YES];
        [self.small_imageView setHidden:YES];
        [self.big_imageView setHidden:NO];
        [self.email_menu setHidden:NO];
        CGFloat nPosMenuY = self.email_menu.frame.origin.y;
        NSInteger MenuHeight = self.email_menu.frame.size.height;
        [self.nothanks_btn setFrame:CGRectMake(self.nothanks_btn.frame.origin.x, nPosMenuY + MenuHeight + 2, 100, 32)];
        CGFloat nPosY = self.nothanks_btn.frame.origin.y;
        CGFloat nPosX = self.nothanks_btn.frame.origin.x;

    }
    else {
        [self.email_join_btn setHidden:NO];
        [self.email_menu setHidden:YES];
        [self.small_imageView setHidden:NO];
        [self.big_imageView setHidden:YES];
        [self.nothanks_btn setFrame:CGRectMake(self.nothanks_btn.frame.origin.x, self.nEmailJoinBtnPosY+2, 100, 32)];

    }
}

- (IBAction)email_signup:(id)sender
{
    NSInteger type = 13;
    NSString *userName = [self.username_textField text];
    NSString *keyid = [self.email_textField text];
    NSString *password = [self.password_textField text];
    NSString *confirm_password = [self.confirm_textField text];
    if (![password isEqualToString:confirm_password]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Perch Project"
                                                        message:@"Password is not correct"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ok", nil];
        [alert show];
        
        return;
    }
    
    
    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/login.php";
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [bodyString setValue:keyid forKey:@"keyid"];
    [bodyString setValue:password forKey:@"password"];
    [bodyString setValue:userName forKey:@"username"];
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
                                       [self parseResponseOfLogin:data type:type];
                                   });
                               }
                               else if ([data length] == 0 && error == nil){
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

- (IBAction)noThanks:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate comeHomeViewFromModal];

    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.username_textField) {
        [self.email_textField becomeFirstResponder];
    }
    else if (textField == self.email_textField) {
        [self.password_textField becomeFirstResponder];
    }
    else if (textField == self.password_textField) {
        [self.confirm_textField becomeFirstResponder];
    }
    else if (textField == self.confirm_textField) {
        [self.confirm_textField resignFirstResponder];
    }
    
    return YES;
}

#pragma keyboard notification
- (void) keyboardDidShow:(NSNotification *)notif
{
    //If keyboard is visible, return
    if (self.bKeyboardVisible) {
        NSLog(@"Keyboard is already visible, Ignoring notification.");
        return;
    }
    
    //Save the current location so we can restore when keyboard is dismissed
    self.fScrollView_Offset = self.scrollView.contentOffset;
    
    //scroll to the certain position
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    self.scrollView.contentOffset = CGPointMake(0, self.nScreenHeight/2);
    //Keyboard is now visible
    self.bKeyboardVisible = YES;
}

- (void) keyboardDidHide:(NSNotification *)notif
{
    //Is the keyboard already shown
    if (!self.bKeyboardVisible) {
        NSLog(@"Keyboard is already hidden. Ignoring notification");
        return;
    }
    
    //Reset the height of the scroll view to its original value
    //self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    //Reset the scrollview to previous location
    self.scrollView.contentOffset = self.fScrollView_Offset;
    
    //Keyboard is no longer visible
    self.bKeyboardVisible = NO;
}


@end
