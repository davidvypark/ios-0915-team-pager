//
//  ViewController.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "VinylConstants.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *lindaButton;
@property (weak, nonatomic) IBOutlet UIButton *haarisButton;
@property (weak, nonatomic) IBOutlet UIButton *jasonButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lindaButtonPressed:(id)sender {
    
    
}


- (IBAction)haarisButtonPressed:(id)sender {
    NSString *discogsURL = @"https://api.discogs.com/database/search";
    
    NSDictionary *params = @{@"q":@"659123015011", @"type":@"barcode", @"key":DiscogsConsumerKey, @"secret":DiscogsConsumerSecret};
    
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

- (IBAction)jasonButtonPressed:(id)sender {
    
    
    
}



@end
