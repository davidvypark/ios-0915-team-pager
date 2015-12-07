//
//  DiscogsAPI.h
//  VinylMap
//
//  Created by JASON HARRIS on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscogsAPI : NSObject

+(void)barcodeAPIsearch:(NSString *)barcode
         withCompletion:(void (^)(NSArray *arrayOfAlbums, bool isError))completionBlock;

+(void)pullDiscogsTokenSecret;

+(void)removeDiscogsKeychain;

@end
