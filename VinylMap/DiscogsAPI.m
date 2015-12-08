//
//  DiscogsAPI.m
//  VinylMap
//
//  Created by JASON HARRIS on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "DiscogsAPI.h"
#import <AFNetworking.h>
#import "VinylConstants.h"
#import "BarcodeViewController.h"
#import <SSKeychain.h>
#import <SSKeychainQuery.h>
#import "UserObject.h"

@interface DiscogsAPI ()


@end


@implementation DiscogsAPI

+(void)barcodeAPIsearch:(NSString *)barcode
         withCompletion:(void (^)(NSArray *arrayOfAlbums, bool isError))completionBlock
{
    
    NSString *discogsURL = @"https://api.discogs.com/database/search";
    NSDictionary *params = @{@"q":barcode, @"type":@"barcode", @"key":DISCOGS_CONSUMER_KEY, @"secret":DISCOGS_CONSUMER_SECRET};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:discogsURL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSArray *resultsArray = responseDictionary[@"results"];

        completionBlock(resultsArray,YES);
        
        for (NSDictionary *vinylDictionary in resultsArray){
            NSLog(@"%@", vinylDictionary[@"title"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil,NO);
        NSLog(@"Request failed with error %@", error);
    }];
    
}

+(void)pullDiscogsTokenSecret
{
    NSError *error;
    NSArray *accounts = [SSKeychain accountsForService:DISCOGS_KEYCHAIN error:&error];
    NSDictionary *firstAccount = accounts[0];
    if(error)
    {
        NSLog(@"%@",error);
    } else
    {
        [UserObject sharedUser].discogsRequestToken = firstAccount[@"acct"];
        [UserObject sharedUser].discogsTokenSecret = [SSKeychain passwordForService:DISCOGS_KEYCHAIN
                                                                            account:[UserObject sharedUser].discogsRequestToken
                                                                              error:&error];
        NSLog(@"discogs in keychain");
        if(error)
        {
            NSLog(@"%@",error);
        }
    }
}

+(void)removeDiscogsKeychain
{
    NSError *error;
    NSArray *accounts = [SSKeychain accountsForService:DISCOGS_KEYCHAIN error:&error];
    if(error)
    {
        NSLog(@"%@",error);
    } else
    {
        NSDictionary *firstAccount = accounts[0];
        NSLog(@"%@",accounts[0]);
        bool deletedPassword = [SSKeychain deletePasswordForService:DISCOGS_KEYCHAIN account:firstAccount[@"acct"] error:&error];
        if(error)
        {
            NSLog(@"%@",error);
        } else if (deletedPassword)
        {
            NSLog(@"Removed discogs from keychain");
            [UserObject sharedUser].discogsTokenSecret = nil;
            
        }
    }
}


+(void)importDiscogsAblums
{
    
    
    
}



@end
