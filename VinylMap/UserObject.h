//
//  UserObject.h
//  VinylMap
//
//  Created by JASON HARRIS on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "VinylConstants.h"

@interface UserObject : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *facebookUserID;
@property (nonatomic, strong) Firebase *firebaseRoot;
@property (nonatomic, strong) Firebase *firebaseTestFolder;
@property (nonatomic, strong) FAuthData *firebaseAuthData;

+ (instancetype)sharedUser;


@end
