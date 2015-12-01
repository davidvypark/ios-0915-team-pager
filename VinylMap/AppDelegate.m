//
//  AppDelegate.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/Core.h>
#import <Google/SignIn.h>
#import "UserObject.h"
#import "VinylConstants.h"
#import <FirebaseUI/FirebaseUI.h>

@interface AppDelegate  () <GIDSignInDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UserObject sharedUser];
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions]; // THIS WAKES UP THE FACEBOOK DELEGATES
    [UserObject sharedUser].facebookUserID = [FBSDKAccessToken currentAccessToken].userID;
    [self setUpFirebase];
    
    
    return YES;
}



-(void)setUpFirebase
{
    [UserObject sharedUser].firebaseRoot = [[Firebase alloc] initWithUrl:FIREBASE_URL];
    [UserObject sharedUser].firebaseTestFolder = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@testing/",FIREBASE_URL]];
    [[UserObject sharedUser].firebaseTestFolder observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"TEST: %@ -> %@", snapshot.key, snapshot.value); //LOGS CHANGES IN TEST FOLDER
    }];
    
    
    //LISTEN FOR FIREBASE AUTH
    [[UserObject sharedUser].firebaseRoot observeAuthEventWithBlock:^(FAuthData *authData) {
        if(authData)
        {
            NSLog(@"%@",authData); //AUTHDATA COMPLETE
            [UserObject sharedUser].firebaseAuthData = authData;
        } else{
            NSLog(@"User logged out or not logged in");
        }
    }];
    
    
}



-(void)setUpGoogle
{
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    [GIDSignIn sharedInstance].delegate = self;
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
}


-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    //GOOGLE'S APP DELEGATE FOR SIGN IN
    
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.restrictRotation)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    //MAKE THIS CONDITIONAL FOR FACEBOOK
    NSString *stringFromURL = [url absoluteString];
    NSLog(@"%lu",(unsigned long)[stringFromURL rangeOfString:FACEBOOK_KEY].location);
    if ([stringFromURL rangeOfString:FACEBOOK_KEY].location != NSNotFound) // facebook
    {
        [[FBSDKApplicationDelegate sharedInstance] application:app
                                                       openURL:url
                                             sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                    annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    } else
    {
        
        
    }
    
    
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
