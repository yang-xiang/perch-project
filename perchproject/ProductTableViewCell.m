//
//  ProductTableViewCell.m
//  purch_01
//
//  Created by Admin on 3/19/15.
//  Copyright (c) 2015 YFL. All rights reserved.
//

#import "ProductTableViewCell.h"

@implementation ProductTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) closeCell:(id)sender
{
    [self.delegate closeCell:self];
}

- (IBAction) stashIt:(id)sender
{
    [self.delegate stashIt:self];
}

- (IBAction) shareIt:(id)sender
{
    [self.delegate shareIt:self];
}

- (IBAction) goWebsite:(id)sender
{
    [self.delegate goWebsite:self];
}

- (IBAction) callPhone:(id)sender
{
    [self.delegate callPhone:self];
}

- (IBAction) showMap:(id)sender
{
    [self.delegate showMap:self];
}

- (IBAction) callUber:(id)sender
{
    [self.delegate callUber:self];
}

- (IBAction)readmore:(id)sender
{
    [self.delegate readmore:self];
}

- (IBAction)readback:(id)sender
{
    [self.delegate readback:self];
}

@end
