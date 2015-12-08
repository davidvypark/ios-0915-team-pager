//
//  UIColor+ChangeIt.m
//  VinylMap
//
//  Created by JASON HARRIS on 12/4/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "UIColor+ChangeIt.h"

@implementation UIColor (ChangeIt)



+(UIColor *)colorByAdjustingBrightnessOfColor:(UIColor *)color withMultiplier:(CGFloat)multiplier
{
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    brightness *= multiplier;
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}













@end
