//
//  WebSiteViewController.m
//  perchproject
//
//  Created by Admin on 4/2/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "WebSiteViewController.h"

@interface WebSiteViewController ()

@property(nonatomic, weak) IBOutlet UIWebView *webView;
@property(nonatomic, retain)            NSString *websiteUrl;

@end

@implementation WebSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSURL *url = [NSURL URLWithString:self.websiteUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void) loadWebsite:(NSString *)_url
{
    self.websiteUrl = _url;
}

- (IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
