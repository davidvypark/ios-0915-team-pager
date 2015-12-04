//
//  CurrentUserDataStore.m
//  VinylMap
//
//  Created by Linda NG on 12/3/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "CurrentUserDataStore.h"

@implementation CurrentUserDataStore

+ (instancetype)sharedDataStore {
    static CurrentUserDataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [[CurrentUserDataStore alloc] init];
    });

    return _sharedDataStore;
}

@end
