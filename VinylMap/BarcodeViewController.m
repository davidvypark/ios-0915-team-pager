//
//  BarCodeViewController.m
//  VinylMap
//
//  Created by JASON HARRIS on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "BarCodeViewController.h"
#import <Masonry.h>



@interface BarcodeViewController ()
@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *barcodeButton;
@property (nonatomic, strong) UIButton *secondBarcode;


@end

@implementation BarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //only allow portrait mode
    [self restrictRotation:YES];
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [self displayButtons];

}


#pragma mark - barcode scanner

-(void)barcodeScanner
{
    self.cameraView = [[UIView alloc] init];
    self.cameraView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.cameraView];
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.25);
    }];
    
    MTBBarcodeScanner *scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.cameraView];
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            
            [scanner startScanningWithResultBlock:^(NSArray *codes) {
                AVMetadataMachineReadableCodeObject *code = [codes firstObject];
                NSLog(@"Found code: %@", code.stringValue);
                
                [scanner stopScanning];
            }];
            
        } else {
            [self displayAlertViewController];
            
        }
    }];
}

-(void)secondBarcodeScanner
{
    
    
    
}


#pragma mark - buttons
-(void)displayButtons
{
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [self.view addSubview:self.dismissButton];
    self.dismissButton.backgroundColor = [UIColor grayColor];
    
    self.barcodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.barcodeButton setTitle:@"MTB Scan Barcode" forState:UIControlStateNormal];
    [self.view addSubview:self.barcodeButton];
    self.barcodeButton.backgroundColor = [UIColor lightGrayColor];
    
    self.secondBarcode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.secondBarcode setTitle:@"RSB Barcode" forState:UIControlStateNormal];
    [self.view addSubview:self.secondBarcode];
    self.secondBarcode.backgroundColor = [UIColor yellowColor];
    
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.075);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    [self.barcodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.dismissButton.mas_top);
        make.height.equalTo(self.view).multipliedBy(0.075);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    [self.secondBarcode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.barcodeButton.mas_top);
        make.height.equalTo(self.view).multipliedBy(0.075);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    
    
    
    
    NSArray *buttonArray = @[self.dismissButton,self.barcodeButton];
    for (UIButton *button in buttonArray) {
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    
}


-(void)buttonClicked:(UIButton *)sendingButton
{

    if([sendingButton isEqual:self.dismissButton])
    {
        [self dismissViewControllerAnimated:YES completion:^{
            [self restrictRotation:NO];
        }];
    } else if ([sendingButton isEqual:self.barcodeButton])
    {
        [self barcodeScanner];
    } else if ([sendingButton isEqual:self.secondBarcode])
    {
        [self secondBarcode];
        
    }
    
}

#pragma mark - alert view controller

-(void)displayAlertViewController
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Camera"
                                          message:@"You need to allow camera access"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self barcodeScanner];
                               }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - restrict rotation

-(void)restrictRotation:(BOOL)restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

@end
