//
//  AlbumCollectionDataStore.h
//  VinylMap
//
//  Created by Haaris Muneer on 11/30/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumCollectionDataStore : NSObject

@property (nonatomic, strong) NSMutableArray *albums;

+ (instancetype)sharedDataStore;

@end
