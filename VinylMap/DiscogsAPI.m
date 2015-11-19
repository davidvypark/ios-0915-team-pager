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





@end
