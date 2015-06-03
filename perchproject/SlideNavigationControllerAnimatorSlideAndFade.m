//
//  SlideNavigationControllerAnimatorSlideAndFade.m
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import "SlideNavigationControllerAnimatorSlideAndFade.h"
#import "SlideNavigationControllerAnimatorSlide.h"
#import "SlideNavigationControllerAnimatorFade.h"

@interface SlideNavigationControllerAnimatorSlideAndFade()
@property (nonatomic, strong) SlideNavigationControllerAnimatorFade *fadeAnimation;
@property (nonatomic, strong) SlideNavigationControllerAnimatorSlide *slideAnimation;
@end

@implementation SlideNavigationControllerAnimatorSlideAndFade

#pragma mark - Initialization -

- (id)init
{
    if (self = [self initWithMaximumFadeAlpha:.8 fadeColor:[UIColor blackColor] andSlideMovement:100])
    {
    }
    
    return self;
}

- (id)initWithMaximumFadeAlpha:(CGFloat)maximumFadeAlpha fadeColor:(UIColor *)fadeColor andSlideMovement:(CGFloat)slideMovement
{
    if (self = [super init])
    {
        self.fadeAnimation = [[SlideNavigationControllerAnimatorFade alloc] initWithMaximumFadeAlpha:maximumFadeAlpha andFadeColor:fadeColor];
        self.slideAnimation = [[SlideNavigationControllerAnimatorSlide alloc] initWithSlideMovement:slideMovement];
    }
    
    return self;
}

#pragma mark - SlideNavigationContorllerAnimation Methods -

- (void)prepareMenuForAnimation:(Menu)menu
{
    [self.fadeAnimation prepareMenuForAnimation:menu];
    [self.slideAnimation prepareMenuForAnimation:menu];
}

- (void)animateMenu:(Menu)menu withProgress:(CGFloat)progress
{
    [self.fadeAnimation animateMenu:menu withProgress:progress];
    [self.slideAnimation animateMenu:menu withProgress:progress];
}

- (void)clear
{
    [self.fadeAnimation clear];
    [self.slideAnimation clear];
}

@end
