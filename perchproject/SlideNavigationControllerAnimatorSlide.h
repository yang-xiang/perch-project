//
//  SlideNavigationControllerAnimatorSlide.h
//  perchproject
//
//  Created by Admin on 3/27/15.
//  Copyright (c) 2015 Partnership. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlideNavigationControllerAnimator.h"

@interface SlideNavigationControllerAnimatorSlide : NSObject <SlideNavigationControllerAnimator>

@property (nonatomic, assign) CGFloat slideMovement;

- (id)initWithSlideMovement:(CGFloat)slideMovement;

@end
