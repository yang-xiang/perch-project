//
//  SlideNavigationControllerAnimatorFade.h
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlideNavigationControllerAnimator.h"

@interface SlideNavigationControllerAnimatorFade : NSObject <SlideNavigationControllerAnimator>

@property (nonatomic, assign) CGFloat maximumFadeAlpha;
@property (nonatomic, strong) UIColor *fadeColor;

- (id)initWithMaximumFadeAlpha:(CGFloat)maximumFadeAlpha andFadeColor:(UIColor *)fadeColor;

@end
