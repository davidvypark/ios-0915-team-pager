//
//  UserObject.h
//  VinylMap
//
//  Created by JASON HARRIS on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFOAuth2Manager/AFOAuth2Manager.h>

@interface UserObject : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) AFOAuthCredential *facebookCredential;





@end
