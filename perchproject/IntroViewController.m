//
//  IntroViewController.m
//  perchproject
//
//  Created by Admin on 4/3/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "IntroViewController.h"
#import "AppDelegate.h"

@interface IntroViewController ()

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSInteger nScreenWidth;
@property (nonatomic) NSInteger nScreenHeight;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.introPage_presented = YES;
    
    self.nScreenWidth = self.view.frame.size.width;
    self.nScreenHeight = self.view.frame.size.height;
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.nScreenWidth * 4, self.nScreenHeight);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.directionalLockEnabled = YES;
    //self.scrollView.delegate = self;

    UIImageView *intro_screen_01 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_screen_01.png"]];
    [intro_screen_01 setFrame:CGRectMake(0, 0, self.nScreenWidth, self.nScreenHeight)];
    [self.scrollView addSubview:intro_screen_01];
    
    
    UIButton *first_next_button = [[UIButton alloc] initWithFrame:
                                   CGRectMake(self.nScreenWidth/2.5,
                                              self.nScreenHeight/4.05,
                                              self.nScreenWidth/5.3,
                                              self.nScreenHeight/19)];
    [first_next_button setBackgroundColor:[UIColor clearColor]];
    [first_next_button addTarget:self action:@selector(first_next) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:first_next_button];
    
    UIButton *skip_button = [[UIButton alloc] initWithFrame:
                                   CGRectMake(self.nScreenWidth/1.4,
                                              self.nScreenHeight/1.1,
                                              self.nScreenWidth/3.55,
                                              self.nScreenHeight/19)];
    [skip_button setBackgroundColor:[UIColor clearColor]];
    [skip_button addTarget:self action:@selector(skip_tutorial) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:skip_button];

    
    UIImageView *intro_screen_02 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_screen_02.png"]];
    [intro_screen_02 setFrame:CGRectMake(self.nScreenWidth, 0, self.nScreenWidth, self.nScreenHeight)];
    [self.scrollView addSubview:intro_screen_02];
    
    UIButton *second_next_button = [[UIButton alloc] initWithFrame:
                                   CGRectMake(self.nScreenWidth * 1.4,
                                              self.nScreenHeight/2.91,
                                              self.nScreenWidth/5.3,
                                              self.nScreenHeight/19)];
    [second_next_button setBackgroundColor:[UIColor clearColor]];
    [second_next_button addTarget:self action:@selector(second_next) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:second_next_button];

    UIImageView *intro_screen_03 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_screen_03.png"]];
    [intro_screen_03 setFrame:CGRectMake(self.nScreenWidth * 2, 0, self.nScreenWidth, self.nScreenHeight)];
    [self.scrollView addSubview:intro_screen_03];
    
    UIButton *third_next_button = [[UIButton alloc] initWithFrame:
                                    CGRectMake(self.nScreenWidth * 2.4,
                                               self.nScreenHeight/1.83,
                                               self.nScreenWidth/5.3,
                                               self.nScreenHeight/19)];
    [third_next_button setBackgroundColor:[UIColor clearColor]];
    [third_next_button addTarget:self action:@selector(third_next) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:third_next_button];

    UIImageView *intro_screen_04 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro_screen_04.png"]];
    [intro_screen_04 setFrame:CGRectMake(self.nScreenWidth * 3, 0, self.nScreenWidth, self.nScreenHeight)];
    [self.scrollView addSubview:intro_screen_04];
    
    UIButton *finish_button = [[UIButton alloc] initWithFrame:
                                   CGRectMake(self.nScreenWidth * 3.18,
                                              self.nScreenHeight/1.89,
                                              self.nScreenWidth/5.3,
                                              self.nScreenHeight/19)];
    [finish_button setBackgroundColor:[UIColor clearColor]];
    [finish_button addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:finish_button];

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

- (void)skip_tutorial
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    appDelegate.intro_passed = YES;
    appDelegate.introPage_presented = NO;

    [appDelegate.userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"intro_passed"];

    [appDelegate writeUserInfo];
    
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)first_next
{
    self.scrollView.contentOffset = CGPointMake(self.nScreenWidth * 1,
                                                self.scrollView.contentOffset.y);

}

- (void)second_next
{
    self.scrollView.contentOffset = CGPointMake(self.nScreenWidth * 2,
                                                self.scrollView.contentOffset.y);

}

- (void)third_next
{
    self.scrollView.contentOffset = CGPointMake(self.nScreenWidth * 3,
                                                self.scrollView.contentOffset.y);

}

- (void)finish
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    appDelegate.intro_passed = YES;
    appDelegate.introPage_presented = NO;

    [appDelegate.userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"intro_passed"];

    [appDelegate writeUserInfo];

    [self dismissViewControllerAnimated:NO completion:nil];

}

@end
