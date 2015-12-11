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
#import "DiscogsOAuthRequestSerializer.h"
#import <Firebase.h>
#import "AlbumCollectionDataStore.h"

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
        [UserObject sharedUser].prelimDiscogsRequestToken = [UserObject sharedUser].discogsRequestToken;
        [UserObject sharedUser].prelimDiscogsTokenSecret = [UserObject sharedUser].discogsTokenSecret;
        if(error)
        {
            NSLog(@"%@",error);
        } else
        {
            NSLog(@"discogs in keychain");
        }
        
        
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        DiscogsOAuthRequestSerializer *reqSerializer = [DiscogsOAuthRequestSerializer serializer]; //PARAMETERS ARE IN REQUEST SERIALIZER
        manager.requestSerializer = reqSerializer;
        [manager GET:@"https://api.discogs.com/oauth/identity" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"%@", responseObject);
            
            [self populateUserObjectWithStrings:responseObject];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@", error);
        }];

    }
}

+(void)populateUserObjectWithStrings:(id)responseObject
{
    [UserObject sharedUser].discogsConsumerName = responseObject[@"consumer_name"];
    [UserObject sharedUser].discogsUserID = responseObject[@"id"];
    [UserObject sharedUser].discogsResourceURL = responseObject[@"resource_url"];
    [UserObject sharedUser].discogsUsername = responseObject[@"username"];
    
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


+(void)syncDiscogsAlbums
{
    
    
    NSString *discogsURL = [NSString stringWithFormat:@"%@/collection/folders/0/releases",[UserObject sharedUser].discogsResourceURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    DiscogsOAuthRequestSerializer *reqSerializer = [DiscogsOAuthRequestSerializer serializer]; //PARAMETERS ARE IN REQUEST SERIALIZER
    manager.requestSerializer = reqSerializer;
    [manager GET:discogsURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSArray *resultsArray = responseDictionary[@"releases"];
        
        AlbumCollectionDataStore *albumStore = [AlbumCollectionDataStore sharedDataStore];
        
        NSMutableArray *params = [NSMutableArray array];
        NSMutableSet *ownedAlbums = [[NSMutableSet alloc] init];
        NSMutableSet *unownedAlbums = [[NSMutableSet alloc] init];
        
        for (NSDictionary *eachOwned in albumStore.albums) {
            NSString *predicateString = [NSString stringWithFormat:@"id == '%@'",eachOwned[@"categoryNumber"]];
            [params addObject:[NSPredicate predicateWithFormat:predicateString]];
            [ownedAlbums addObject:eachOwned[@"categoryNumber"]];
        }
        NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:params];
        
        NSArray *filteredArray = [resultsArray filteredArrayUsingPredicate:compoundPredicate];
        NSLog(@"%@",filteredArray);
        
        
        
        for (NSDictionary *eachResult in resultsArray)
        {
            if([ownedAlbums containsObject:eachResult[@"basic_information"][@"labels"][0][@"catno"]])
            {
                
            } else
            {
                [unownedAlbums addObject:eachResult];
            }
            
        }
        
        NSString *currentUser = [UserObject sharedUser].firebaseRoot.authData.uid;
        NSString *collectionURL = [NSString stringWithFormat:@"users/%@/collection", currentUser];
        Firebase *collectionHere = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@",FIREBASE_URL,collectionURL]];
        
        for (NSDictionary *unowned in unownedAlbums) {
            NSDictionary *albumn = @{@"artist": unowned[@"basic_information"][@"artists"][0][@"name"],
                                     @"title": unowned[@"basic_information"][@"title"],
                                     @"recordLabels": unowned[@"basic_information"][@"labels"][0][@"name"],
                                     @"releaseYear": unowned[@"basic_information"][@"year"],
                                     @"categoryNumber": unowned[@"basic_information"][@"labels"][0][@"catno"],
                                     @"imageURL": unowned[@"basic_information"][@"thumb"],
                                     @"Format" :unowned[@"basic_information"][@"formats"][0][@"name"],
                                     @"resourceURL": unowned[@"basic_information"][@"labels"][0][@"resource_url"]};
            
            Firebase *collectionID = [collectionHere childByAutoId];
            
            [collectionID  setValue:albumn withCompletionBlock:^(NSError *error, Firebase *ref) {
                if(error)
                {
                    NSLog(@"error returned %@",error);
                } else
                {
                    NSLog(@"%@ added to firebase",unowned[@"basic_information"][@"title"]);
                }
            }];
            [collectionID updateChildValues:@{@"ID": collectionID.key}];
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Request failed with error %@", error);
    }];
    
}



@end
