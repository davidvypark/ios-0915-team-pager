//
//  UIButton+Discogs.m
//  VinylMap
//
//  Created by JASON HARRIS on 12/3/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "DiscogsButton.h"
#import "UIColor+ChangeIt.h"
#import "VinylColors.h"

@implementation DiscogsButton


-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        [self commonInitMethod];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder])
    {
        
        [self commonInitMethod];
        
    }
    
    return self;
}

-(void)commonInitMethod
{
    self.buttonColor = [UIColor vinylBlue];
    self.backgroundColor = self.buttonColor;
    self.layer.cornerRadius = 10;
    self.adjustsImageWhenHighlighted = YES;
    self.reversesTitleShadowWhenHighlighted = YES;
    [self.layer setBorderWidth:1.0];
    [self.layer setBorderColor:[UIColor vinylLightGray].CGColor];
    self.tintColor = [UIColor vinylOrange];
}


-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        self.backgroundColor = [UIColor colorByAdjustingBrightnessOfColor:self.buttonColor withMultiplier:1.5];
    } else
    {
        self.backgroundColor = self.buttonColor;
    }
    
    
}

@end
