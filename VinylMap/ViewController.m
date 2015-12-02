//
//  ViewController.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "ViewController.h"
#import "BarCodeViewController.h"
#import <AFNetworking.h>
#import "VinylConstants.h"
#import <Masonry.h>
#import "DiscogsAPI.h"

@interface ViewController () <BarCodeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *lindaButton;
@property (weak, nonatomic) IBOutlet UIButton *haarisButton;
@property (weak, nonatomic) IBOutlet UIButton *jasonButton;
@property (nonatomic, strong) BarcodeViewController *barcodeVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *background = [UIImage imageNamed:@"russiaImage"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [self.view insertSubview:backgroundImageView atIndex:0];
    
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lindaButtonPressed:(id)sender {
    
    
}

- (IBAction)showHamburgerMenuPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHamburgerMenuNotification" object:nil];
}


- (IBAction)haarisButtonPressed:(id)sender {
    NSString *discogsURL = @"https://api.discogs.com/database/search";
    
    NSDictionary *params = @{@"q":@"659123015011", @"type":@"barcode", @"key":DISCOGS_CONSUMER_KEY, @"secret":DISCOGS_CONSUMER_SECRET};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:discogsURL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSArray *resultsArray = responseDictionary[@"results"];
        for (NSDictionary *vinylDictionary in resultsArray){
            NSLog(@"%@", vinylDictionary[@"title"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Request failed with error %@", error);
    }];
    
}







- (IBAction)jasonButtonPressed:(id)sender
{
    self.barcodeVC = [[BarcodeViewController alloc] init];
    self.barcodeVC.delegate = self;
    [self.barcodeVC setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [self presentViewController:self.barcodeVC animated:NO completion:nil];
    
}

-(NSArray *)barcodeScanResult:(NSString *)barcode
{
    if([barcode isEqualToString:@"dismissed"])
    {
        [self.barcodeVC dismissViewControllerAnimated:NO completion:nil];
    } else
    {
        [self.barcodeVC dismissViewControllerAnimated:NO completion:^{
            NSLog(@"searching for %@",barcode);
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.center = CGPointMake(160, 240);
            spinner.tag = 12;
            [self.view addSubview:spinner];
            [spinner startAnimating];
            [DiscogsAPI barcodeAPIsearch:barcode withCompletion:^(NSArray *arrayOfAlbums, bool isError) {
                NSLog(@"%@",arrayOfAlbums);
                [spinner removeFromSuperview];
            }];
        }];
    }
    
    
    return nil;
}



@end
