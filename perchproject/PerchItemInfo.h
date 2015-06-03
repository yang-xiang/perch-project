//
//  PerchItemInfo.h
//  purch_01
//
//  Created by Admin on 3/20/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PerchItemInfo : NSObject
{
    NSInteger                   nid;
    NSString                    *category;

    NSInteger                   venue_id;
    NSString                    *title;
    NSString                    *info;
    NSString                    *days;
    NSString                    *start_time;
    NSString                    *end_time;
    
    NSString                    *image;
}

@property(nonatomic)            NSInteger                   nid;
@property(nonatomic, retain)   NSString                    *category;
@property(nonatomic)           NSInteger                    venue_id;
@property(nonatomic, retain)   NSString                    *title;
@property(nonatomic, retain)   NSString                    *info;
@property(nonatomic, retain)   NSString                    *days;
@property(nonatomic, retain)   NSString                    *start_time;
@property(nonatomic, retain)   NSString                    *end_time;
@property(nonatomic, retain)    NSString                   *image;

- (id) initWithTitle:(NSString *)_title;

@end
