//
//  UIButton+Discogs.m
//  VinylMap
//
//  Created by JASON HARRIS on 12/3/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "UIButton+Discogs.h"


@implementation UIButton (Discogs)


-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.backgroundColor = [[UIColor alloc] initWithRed:0.15 green:0.15 blue:0.15 alpha:1];
        self.layer.cornerRadius = 10;
        self.adjustsImageWhenHighlighted = YES;
        self.reversesTitleShadowWhenHighlighted = YES;
        [self.layer setBorderWidth:3];

        [self.layer setBorderColor:[[UIColor alloc] initWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor];
        self.tintColor = [UIColor blackColor];
    }
    
    return self;
}

-(CAGradientLayer *)createGradientLayer:(UIButton *)customButton
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = customButton.layer.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithWhite:1.0f alpha:0.1f].CGColor,
                            (id)[UIColor colorWithWhite:0.4f alpha:0.5f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    gradientLayer.cornerRadius = customButton.layer.cornerRadius;
    
    
    return gradientLayer;
}


@end
