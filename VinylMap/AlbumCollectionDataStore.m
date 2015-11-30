//
//  AlbumCollectionDataStore.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/30/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "AlbumCollectionDataStore.h"

@implementation AlbumCollectionDataStore

+ (instancetype)sharedDataStore {
    static AlbumCollectionDataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [[AlbumCollectionDataStore alloc] init];
    });
    
    return _sharedDataStore;
}

@end
