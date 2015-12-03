
//
//  DiscogsOAuthRequestSerializer.m
//  VinylMap
//
//  Created by JASON HARRIS on 12/1/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "DiscogsOAuthRequestSerializer.h"
#import <AFOAuth1/NSMutableURLRequest+OAuth.h>
#import "VinylConstants.h"
#import "UserObject.h"

@implementation DiscogsOAuthRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError * __autoreleasing *)error
{
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    [self setOAuthorizationHeader:request withParameters:parameters];
    return request;
}

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                                  error:(NSError * __autoreleasing *)error
{
    NSMutableURLRequest *request = [super multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    [self setOAuthorizationHeader:request withParameters:parameters];
    return request;
}

- (NSMutableURLRequest *)requestWithMultipartFormRequest:(NSURLRequest *)request
                             writingStreamContentsToFile:(NSURL *)fileURL
                                       completionHandler:(void (^)(NSError *error))handler
{
    NSMutableURLRequest *mRequest = [super requestWithMultipartFormRequest:request writingStreamContentsToFile:fileURL completionHandler:handler];
    [self setOAuthorizationHeader:mRequest withParameters:nil];
    return mRequest;
}

- (void)setOAuthorizationHeader:(NSMutableURLRequest *)request withParameters:(id)parameters
{
    NSDictionary *params = parameters;
    
    [request signRequestWithClientIdentifier:DISCOGS_CONSUMER_KEY
                                      secret:DISCOGS_CONSUMER_SECRET
                             tokenIdentifier:[UserObject sharedUser].discogsRequestToken
                                      secret:[UserObject sharedUser].discogsTokenSecret
                                    verifier:[UserObject sharedUser].discogsOAuthVerifier
                                 usingMethod:OAuthPlaintextSignatureMethod];
}


@end
