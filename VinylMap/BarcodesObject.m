//
//  BarcodesObject.m
//  VinylMap
//
//  Created by JASON HARRIS on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "BarcodesObject.h"

@implementation BarcodesObject


+ (instancetype)sharedBarcodes {
    static BarcodesObject *_sharedBarcodes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBarcodes = [[self alloc] init];
    });
    
    return _sharedBarcodes;
}


-(instancetype)init
{
    self = [super init];
    if(self)
    {
        _barcodesSet = [[NSMutableSet alloc] init];
        
    }
    
    return self;
}




@end
