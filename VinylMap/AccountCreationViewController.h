//
//  AccountCreationViewController.h
//  VinylMap
//
//  Created by JASON HARRIS on 12/3/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AccountCreationViewControllerDelegate

@required

-(NSArray *)loginResult:(NSString *)result;

@end

@interface AccountCreationViewController : UIViewController

@property (nonatomic, weak) id<AccountCreationViewControllerDelegate> delegate;

@end
