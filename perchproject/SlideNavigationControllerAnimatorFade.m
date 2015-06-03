//
//  SlideNavigationControllerAnimatorFade.m
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "SlideNavigationControllerAnimatorFade.h"

@interface SlideNavigationControllerAnimatorFade()
@property (nonatomic, strong) UIView *fadeAnimationView;
@end

@implementation SlideNavigationControllerAnimatorFade

#pragma mark - Initialization -

- (id)init
{
    if (self = [self initWithMaximumFadeAlpha:.8 andFadeColor:[UIColor blackColor]])
    {
    }
    
    return self;
}

- (id)initWithMaximumFadeAlpha:(CGFloat)maximumFadeAlpha andFadeColor:(UIColor *)fadeColor
{
    if (self = [super init])
    {
        self.maximumFadeAlpha = maximumFadeAlpha;
        self.fadeColor = fadeColor;
        
        self.fadeAnimationView = [[UIView alloc] init];
        self.fadeAnimationView.backgroundColor = self.fadeColor;
    }
    
    return self;
}

#pragma mark - SlideNavigationContorllerAnimation Methods -

- (void)prepareMenuForAnimation:(Menu)menu
{
    UIViewController *menuViewController = (menu == MenuLeft)
    ? [SlideNavigationController sharedInstance].leftMenu
    : [SlideNavigationController sharedInstance].rightMenu;
    
    self.fadeAnimationView.alpha = self.maximumFadeAlpha;
    self.fadeAnimationView.frame = menuViewController.view.bounds;
}

- (void)animateMenu:(Menu)menu withProgress:(CGFloat)progress
{
    UIViewController *menuViewController = (menu == MenuLeft)
    ? [SlideNavigationController sharedInstance].leftMenu
    : [SlideNavigationController sharedInstance].rightMenu;
    
    self.fadeAnimationView.frame = menuViewController.view.bounds;
    [menuViewController.view addSubview:self.fadeAnimationView];
    self.fadeAnimationView.alpha = self.maximumFadeAlpha - (self.maximumFadeAlpha *progress);
}

- (void)clear
{
    [self.fadeAnimationView removeFromSuperview];
}

@end
