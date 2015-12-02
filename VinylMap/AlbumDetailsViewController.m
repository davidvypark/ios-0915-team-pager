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


@interface AlbumDetailsViewController ()


@end

@implementation AlbumDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *albumArtURL = [NSURL URLWithString:self.albumImageURL];
    [self.imageLabel setImageWithURL:albumArtURL];
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
