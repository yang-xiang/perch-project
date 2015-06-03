//
//  SlideNavigationControllerAnimatorSlideAndFade.h
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlideNavigationControllerAnimator.h"

@interface SlideNavigationControllerAnimatorSlideAndFade : NSObject<SlideNavigationControllerAnimator>

- (id)initWithMaximumFadeAlpha:(CGFloat)maximumFadeAlpha fadeColor:(UIColor *)fadeColor andSlideMovement:(CGFloat)slideMovement;


@end
