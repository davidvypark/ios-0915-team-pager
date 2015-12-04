//
//  CurrentUserDataStore.h
//  VinylMap
//
//  Created by Linda NG on 12/3/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentUserDataStore : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *displayName;

+ (instancetype)sharedDataStore;

@end
