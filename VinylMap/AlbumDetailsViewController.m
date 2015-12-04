//
//  AlbumDetailsViewController.m
//  VinylMap
//
//  Created by Linda NG on 11/30/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "AlbumDetailsViewController.h"
#import "AddViewController.h"
#import <UIKit+AFNetworking.h>
#import "VinylConstants.h"
#import <AFNetworking.h>


@interface AlbumDetailsViewController ()


@end

@implementation AlbumDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSLog(@"%@", self.resourceURL);
    NSString *resourceURL = [NSString stringWithFormat:@"%@?key=%@&secret=%@",  self.resourceURL, DISCOGS_CONSUMER_KEY, DISCOGS_CONSUMER_SECRET];
    [manager GET:resourceURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSArray *images = responseDictionary[@"images"];
        NSDictionary *firstImage = images.firstObject;
        NSString *bigAlbumArt = firstImage[@"uri"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSURL *bigAlbumArtURL = [NSURL URLWithString:bigAlbumArt];
            [self.imageLabel setImageWithURL:bigAlbumArtURL];
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Request failed with error %@", error);
    }];
    
    
    self.albumNameLabel.text = self.albumName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AddViewController *destinationVC = segue.destinationViewController;
    destinationVC.ID = self.albumAutoId;
    destinationVC.albumName = self.albumNameLabel.text;
    destinationVC.albumURL = self.albumImageURL;
}


@end
