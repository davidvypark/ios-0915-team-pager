   //
//  UserObject.m
//  VinylMap
//
//  Created by JASON HARRIS on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "UserObject.h"

@implementation UserObject


+ (instancetype)sharedUser {
    static UserObject *_sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUser = [[UserObject alloc] init];
    });
    
    return _sharedUser;
}


@end
