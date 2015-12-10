//
//  VinylShortTabBar.m
//  VinylMap
//
//  Created by JASON HARRIS on 12/10/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "VinylShortTabBar.h"

@implementation VinylShortTabBar

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize defaultSize = [super sizeThatFits:size];
    defaultSize.height = 45;
    return defaultSize;
}

-(void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated
{
    for(UITabBarItem *item in items) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    
    [super setItems:items animated:animated];
}

@end
