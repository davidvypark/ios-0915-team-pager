//
//  BarCodeViewController.h
//  VinylMap
//
//  Created by JASON HARRIS on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBBarcodeScanner.h"
#import "AppDelegate.h"


@protocol BarCodeViewControllerDelegate

@required

-(NSArray *)barcodeScanResult:(NSString *)barcode;

@end


@interface BarcodeViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) id<BarCodeViewControllerDelegate> delegate;





@end
