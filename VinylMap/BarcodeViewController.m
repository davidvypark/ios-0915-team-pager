//
//  BarCodeViewController.m
//  VinylMap
//
//  Created by JASON HARRIS on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "BarCodeViewController.h"
#import <Masonry.h>
//#import <RSBarcodes.h>
#import <AFNetworking.h>
#import "VinylConstants.h"
#import "VinylColors.h"

@interface BarcodeViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *barcodeButton;
@property (nonatomic, strong) UIButton *secondBarcode;
@property (nonatomic, strong) UIImageView *logoImage;
//@property (nonatomic, strong) RSScannerViewController *scanner;
//@property (nonatomic, strong) RSScannerViewController *scannerVC;
@property (nonatomic, strong) UIAlertController *barcodeAlert;

@end

@implementation BarcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *behindVisualEffect = [[UIView alloc] init];
    behindVisualEffect.alpha = 1; //supported,, don't change on UIVisualEffectView
    [self.view addSubview:behindVisualEffect];
    [behindVisualEffect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(behindVisualEffect.superview);
    }];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.accessibilityLabel = @"backOut";
    [behindVisualEffect addSubview:visualEffectView];
    

    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self barcodeScanner];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.accessibilityLabel = @"backOut";
    [visualEffectView.contentView addSubview:vibrancyEffectView];
    
    [vibrancyEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    UIButton *saysBarcode = [[UIButton alloc] init];
    saysBarcode.userInteractionEnabled = NO;
    [saysBarcode setTitle:@"Scan Barcode" forState:UIControlStateNormal];
    saysBarcode.titleLabel.font = [UIFont fontWithName:@"Arial Hebrew" size:30];
    saysBarcode.titleLabel.textColor = [UIColor blackColor];
    saysBarcode.titleLabel.tintColor = [UIColor blackColor];
    
    [vibrancyEffectView.contentView addSubview:saysBarcode];
    
    [saysBarcode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.cameraView.mas_top).offset(-20);
    }];
    
    
    UIButton *alsoSaysBarcode = [[UIButton alloc] init];
    alsoSaysBarcode.userInteractionEnabled = NO;
    [alsoSaysBarcode setTitle:@"Scan Barcode" forState:UIControlStateNormal];
    alsoSaysBarcode.titleLabel.font = [UIFont fontWithName:@"Arial Hebrew" size:30];
    alsoSaysBarcode.titleLabel.textColor = [UIColor blackColor];
    alsoSaysBarcode.titleLabel.tintColor = [UIColor blackColor];
    
    [vibrancyEffectView.contentView addSubview:alsoSaysBarcode];
    
    [alsoSaysBarcode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@40);
        make.top.equalTo(self.cameraView.mas_bottom).offset(20);
    }];
    
}


#pragma mark - barcode scanner

-(void)barcodeScanner
{
    self.cameraView = [[UIView alloc] init];
    self.cameraView.backgroundColor = [UIColor lightGrayColor];
    self.cameraView.opaque = YES;
    self.cameraView.alpha = 1;
    self.cameraView.accessibilityLabel = @"cameraView";
    [self.view addSubview:self.cameraView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MTBBarcodeScanner *scannerMTB = [[MTBBarcodeScanner alloc] initWithPreviewView:self.cameraView];
        [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [scannerMTB startScanningWithResultBlock:^(NSArray *codes) {
                        AVMetadataMachineReadableCodeObject *code = [codes firstObject];
                        NSLog(@"Found code: %@", code.stringValue);
                        [scannerMTB stopScanning];
                        [self.cameraView removeFromSuperview];
                        [self.delegate barcodeScanResult:code.stringValue];
                    }];
                });
            } else {
                [self displayAlertViewControllerForCamera];
            }
        }];
    });
    
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.5);
        make.width.equalTo(self.view);
    }];
    
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    NSLog(@"user touched this object: %@",touches.anyObject.view.accessibilityLabel);
    
    if(![touches.anyObject.view.accessibilityLabel isEqualToString:@"cameraView"])
    {
        [self.delegate barcodeScanResult:@"dismissed"];
    }
    
}



//-(void)secondBarcodeScanner
//{
//    
//    self.scannerVC = [[RSScannerViewController alloc] initWithCornerView:YES
//                                                             controlView:YES
//                                                         barcodesHandler:^(NSArray *barcodeObjects) {
//                                                             AVMetadataMachineReadableCodeObject *barcodeObject = barcodeObjects.firstObject;
//                                                             dispatch_async(dispatch_get_main_queue(), ^{
//                                                                 [self.scannerVC dismissViewControllerAnimated:true completion:^{
//                                                                     [self barcodeDisplayAlertViewControllerFor:barcodeObject.stringValue];
//                                                                 }];
//                                                             });
//                                                         } preferredCameraPosition:AVCaptureDevicePositionBack];
//    [self.scannerVC setStopOnFirst:YES];
//    [self.scannerVC setIsButtonBordersVisible:YES];
//    
//}
//
//- (IBAction)presentModal:(id)sender {
//    [self presentViewController:self.scannerVC animated:YES completion:nil];
//}

#pragma mark - buttons

//-(void)displayButtons
//{
//    self.dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [self.dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
//    [self.view addSubview:self.dismissButton];
//    self.dismissButton.backgroundColor = [UIColor grayColor];
//    
//    self.barcodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [self.barcodeButton setTitle:@"MTB Scan Barcode" forState:UIControlStateNormal];
//    [self.view addSubview:self.barcodeButton];
//    self.barcodeButton.backgroundColor = [UIColor lightGrayColor];
//    
//    self.secondBarcode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [self.secondBarcode setTitle:@"RSB Barcode" forState:UIControlStateNormal];
//    [self.view addSubview:self.secondBarcode];
//    self.secondBarcode.backgroundColor = [UIColor yellowColor];
//    
//    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view);
//        make.height.equalTo(self.view).multipliedBy(0.075);
//        make.width.equalTo(self.view);
//        make.left.equalTo(self.view);
//    }];
//    [self.barcodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.dismissButton.mas_top);
//        make.height.equalTo(self.view).multipliedBy(0.075);
//        make.width.equalTo(self.view);
//        make.left.equalTo(self.view);
//    }];
//    [self.secondBarcode mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.barcodeButton.mas_top);
//        make.height.equalTo(self.view).multipliedBy(0.075);
//        make.width.equalTo(self.view);
//        make.left.equalTo(self.view);
//    }];
//    
//    
//    
//    
//    NSArray *buttonArray = @[self.dismissButton,self.barcodeButton,self.secondBarcode];
//    for (UIButton *button in buttonArray) {
//        [button addTarget:self
//                   action:@selector(buttonClicked:)
//         forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//}


//-(void)buttonClicked:(UIButton *)sendingButton
//{
//
//    if([sendingButton isEqual:self.dismissButton])
//    {
//        [self dismissViewControllerAnimated:YES completion:^{
//            [self restrictRotation:NO];
//        }];
//    } else if ([sendingButton isEqual:self.barcodeButton])
//    {
//        [self barcodeScanner];
//    } else if ([sendingButton isEqual:self.secondBarcode])
//    {
//        [self presentModal:nil];
//        
//    }
//}

#pragma mark - alert view controller

-(void)barcodeDisplayAlertViewControllerFor:(NSString *)barcode
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Barcode Found"
                                          message:barcode
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
                                   //ADD OBJECT ACTION
                               }];
    
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)displayAlertViewControllerForCamera
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

//-(void)restrictRotation:(BOOL)restriction
//{
//    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    appDelegate.restrictRotation = restriction;
//}

#pragma mark - logo image

-(void)setupLogoImage
{
    self.logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vinylMap_icon.png"]];
    [self.view addSubview:self.logoImage];
    [self.logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(self.view.frame.size.height/20);
        make.height.and.width.equalTo(@(self.view.frame.size.width/1.5));
    }];
}

@end
