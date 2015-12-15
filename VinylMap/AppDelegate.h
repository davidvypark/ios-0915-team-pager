//
//  AppDelegate.h
//  VinylMap
//
//  Created by Haaris Muneer on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, assign) bool restrictRotation;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *lastMessageString;

@end

