//
//  LoginViewController.m
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>

#import "Uber/AFNetworking/AFNetworking.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *mParent_scrollView;
@property (nonatomic, weak) IBOutlet UIView *mAction_parentView;
@property (nonatomic, weak) IBOutlet UIView *mAction_emailView;
@property (nonatomic, weak) IBOutlet UIView *mImageView;
@property (nonatomic, weak) IBOutlet UITextField *mUsername_textField;
@property (nonatomic, weak) IBOutlet UITextField *mEmail_textField;
@property (nonatomic, weak) IBOutlet UITextField *mPassword_textField;
@property (nonatomic, weak) IBOutlet UITextField *mPwConfirm_textField;
@property (nonatomic, weak) IBOutlet UIButton *mGo_button;
@property (nonatomic, weak) IBOutlet UIButton *mEmailShow_button;
@property (nonatomic, weak) IBOutlet UIButton *mFacebookLogin_button;
@property (nonatomic, weak) IBOutlet UIButton *mTwitterLogin_button;
@property (nonatomic, weak) IBOutlet UIButton *mLogin_button;
@property (nonatomic, weak) IBOutlet UIButton *mLater_button;
@property (nonatomic, weak) IBOutlet UITextField *mLogin_email_textField;
@property (nonatomic, weak) IBOutlet UITextField *mLogin_password_textField;
@property (nonatomic, weak) IBOutlet UIButton *mLogin_go_button;
@property (nonatomic, weak) IBOutlet UIView *mLogin_showView;
@property (nonatomic, weak) IBOutlet UIImageView *mlogo_imageView;
@property (nonatomic, weak) IBOutlet UILabel *mtitle_label;


@property (nonatomic) BOOL bEmailShowView_displayed;
@property (nonatomic) BOOL bLoginShowView_displayed;
@property (nonatomic) NSInteger nScreenWidth;
@property (nonatomic) NSInteger nScreenHeight;
@property (nonatomic) BOOL bKeyboardVisible;
@property (nonatomic) CGPoint fScrollView_Offset;

@property (nonatomic, retain) UIImage *facebook_profile_image;
@property (nonatomic, retain) UIImage *twitter_profile_image;
@property (nonatomic, retain) NSString *birthday_year;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *lives;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.loginPage_presented = YES;
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    self.nScreenWidth = self.view.frame.size.width;
    self.nScreenHeight = self.view.frame.size.height;
    self.bEmailShowView_displayed = NO;
    self.bLoginShowView_displayed = NO;
    self.mParent_scrollView.contentSize = CGSizeMake(self.nScreenWidth,
                                                     self.nScreenHeight * 3/2);
    self.mParent_scrollView.scrollEnabled = FALSE;
    
    self.mUsername_textField.delegate = self;
    self.mUsername_textField.returnKeyType = UIReturnKeyNext;
    
    self.mEmail_textField.delegate = self;
    self.mEmail_textField.returnKeyType = UIReturnKeyNext;
    
    self.mPassword_textField.delegate = self;
    self.mPassword_textField.returnKeyType = UIReturnKeyNext;
    
    self.mPwConfirm_textField.delegate = self;
    self.mPwConfirm_textField.returnKeyType = UIReturnKeyDone;
    
    self.mLogin_email_textField.delegate = self;
    self.mLogin_email_textField.returnKeyType = UIReturnKeyNext;
    
    self.mLogin_password_textField.delegate = self;
    self.mLogin_password_textField.returnKeyType = UIReturnKeyDone;
    
    self.bKeyboardVisible = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (IBAction)show_loginView:(id)sender
{
    [self.mAction_parentView setFrame:CGRectMake(0, self.nScreenHeight - 150, self.nScreenWidth, 150)];
    
    [self.mLogin_button setFrame:CGRectMake(0, 100, self.nScreenWidth/2-2, 50)];
    [self.mLater_button setFrame:CGRectMake(self.nScreenWidth/2+1, 100, self.nScreenWidth/2-1, 50)];
    
    [self.mEmailShow_button setFrame:CGRectMake(0, 55, self.nScreenWidth, 40)];
    [self.mAction_emailView setHidden:YES];
    
    self.bEmailShowView_displayed = NO;
    
    if (self.bLoginShowView_displayed == NO) {
        [self.mAction_parentView setFrame:CGRectMake(0, self.nScreenHeight - 260, self.nScreenWidth, 260)];
        [self.mLogin_showView setFrame:CGRectMake(0, 155, self.nScreenWidth, 105)];
        [self.mLogin_showView setHidden:NO];
        self.bLoginShowView_displayed = YES;
    }
    else {
        [self.mAction_parentView setFrame:CGRectMake(0, self.nScreenHeight - 150, self.nScreenWidth, 150)];
        [self.mLogin_showView setFrame:CGRectMake(0, 0, self.nScreenWidth, 105)];
        [self.mLogin_showView setHidden:YES];
        self.bLoginShowView_displayed = NO;
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


- (IBAction)action_login:(id)sender
{
    NSInteger type = 12;
    NSString *keyid = [self.mLogin_email_textField text];
    NSString *password = [self.mLogin_password_textField text];
    
    NSString *urlString = @"https://www.perchproject.com.au/auction-code/mobile/login.php";
    NSMutableDictionary *bodyString = [[NSMutableDictionary alloc] init];
    [bodyString setValue:[NSNumber numberWithInteger:type] forKey:@"type"];
    [bodyString setValue:keyid forKey:@"keyid"];
    [bodyString setValue:password forKey:@"password"];
    [bodyString setValue:@"" forKey:@"username"];
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
            
            NSString *keyid = [self.mLogin_email_textField text];
            if ([keyid isEqualToString:@""]) {
                keyid = [self.mEmail_textField text];
            }
            NSString *password = [self.mLogin_password_textField text];
            if ([password isEqualToString:@""]) {
                password = [self.mPassword_textField text];
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

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)action_later:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //appDelegate.location_updated = YES;
    appDelegate.pass_login = YES;
    //appDelegate.loginPage_presented = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [appDelegate loadPerch];
}

- (IBAction)action_emailShow:(id)sender
{
    [self.mAction_parentView setFrame:CGRectMake(0, self.nScreenHeight - 150, self.nScreenWidth, 150)];
    [self.mLogin_showView setFrame:CGRectMake(0, 0, self.nScreenWidth, 105)];
    [self.mLogin_showView setHidden:YES];
    self.bLoginShowView_displayed = NO;

    if (self.bEmailShowView_displayed == NO) {
        [self.mAction_parentView setFrame:CGRectMake(0, self.nScreenHeight - 330, self.nScreenWidth, 330)];
        
        [self.mLogin_button setFrame:CGRectMake(0, 280, self.nScreenWidth/2-2, 50)];
        [self.mLater_button setFrame:CGRectMake(self.nScreenWidth/2+1, 280, self.nScreenWidth/2-1, 50)];
        
        [self.mEmailShow_button setFrame:CGRectMake(0, 55, self.nScreenWidth, 40)];
        [self.mUsername_textField setFrame:CGRectMake(0, 0, self.nScreenWidth, 30)];
        [self.mEmail_textField setFrame:CGRectMake(0, 35, self.nScreenWidth, 30)];
        [self.mPassword_textField setFrame:CGRectMake(0, 70, self.nScreenWidth, 30)];
        [self.mPwConfirm_textField setFrame:CGRectMake(0, 105, self.nScreenWidth, 30)];
        [self.mGo_button setFrame:CGRectMake(0, 140, self.nScreenWidth, 35)];
        
        [self.mAction_emailView setFrame:CGRectMake(0, 100, self.nScreenWidth, 175)];
        [self.mAction_emailView setHidden:NO];
        
        [self.mlogo_imageView setFrame:CGRectMake(110 * self.nScreenWidth/320,
                                                  40 * self.nScreenHeight/568,
                                                  100, 100)];
        [self.mtitle_label setFrame:CGRectMake(60 * self.nScreenWidth/320,
                                               160 * self.nScreenHeight/568,
                                               200, 21)];
        
        self.bEmailShowView_displayed = YES;
    }
    else{
        [self.mAction_parentView setFrame:CGRectMake(0, self.nScreenHeight - 150, self.nScreenWidth, 150)];
        
        [self.mLogin_button setFrame:CGRectMake(0, 100, self.nScreenWidth/2-2, 50)];
        [self.mLater_button setFrame:CGRectMake(self.nScreenWidth/2+1, 100, self.nScreenWidth/2-1, 50)];
        
        [self.mEmailShow_button setFrame:CGRectMake(0, 55, self.nScreenWidth, 40)];
        [self.mAction_emailView setHidden:YES];
        
        [self.mlogo_imageView setFrame:CGRectMake(110 * self.nScreenWidth/320,
                                                  140 * self.nScreenHeight/568,
                                                  100, 100)];
        [self.mtitle_label setFrame:CGRectMake(60 * self.nScreenWidth/320,
                                               260 * self.nScreenHeight/568,
                                               200, 21)];

        self.bEmailShowView_displayed = NO;
    }
    
    [self.view setNeedsDisplay];
}

- (IBAction)action_emailGo:(id)sender
{
    NSInteger type = 13;
    NSString *userName = [self.mUsername_textField text];
    NSString *keyid = [self.mEmail_textField text];
    NSString *password = [self.mPassword_textField text];
    NSString *confirm_password = [self.mPwConfirm_textField text];
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

#pragma textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.mUsername_textField) {
        [self.mUsername_textField becomeFirstResponder];
    }
    else if (textField == self.mEmail_textField) {
        [self.mPassword_textField becomeFirstResponder];
    }
    else if (textField == self.mPassword_textField) {
        [self.mPwConfirm_textField becomeFirstResponder];
    }
    else if (textField == self.mPwConfirm_textField) {
        [self.mPwConfirm_textField resignFirstResponder];
    }
    else if (textField == self.mLogin_email_textField) {
        [self.mLogin_password_textField becomeFirstResponder];
    }
    else if (textField == self.mLogin_password_textField) {
        [self.mLogin_password_textField resignFirstResponder];
    }
    
    return YES;
}

#pragma keyboard notification
- (void) keyboardDidShow:(NSNotification *)notif
{
    NSDictionary *info  = notif.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    
    //If keyboard is visible, return
    if (self.bKeyboardVisible) {
        NSLog(@"Keyboard is already visible, Ignoring notification.");
        return;
    }
    
    //Save the current location so we can restore when keyboard is dismissed
    self.fScrollView_Offset = self.mParent_scrollView.contentOffset;
    
    //scroll to the certain position
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    self.mParent_scrollView.contentOffset = CGPointMake(0, self.nScreenHeight/2);
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
    self.mParent_scrollView.frame = CGRectMake(0, 0, self.nScreenWidth, self.nScreenHeight);
    
    //Reset the scrollview to previous location
    self.mParent_scrollView.contentOffset = self.fScrollView_Offset;
    
    //Keyboard is no longer visible
    self.bKeyboardVisible = NO;
}


@end
