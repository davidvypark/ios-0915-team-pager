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
#import "ChatMessagesViewController.h"
#import <Masonry.h>
#import "DiscogsButton.h"
#import "VinylColors.h"
#import "UserObject.h"

@interface AlbumDetailsViewController ()

@end

@implementation AlbumDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

-(void)buttonClicked:(DiscogsButton *)button
{
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{ NSString *albumURL = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/users/%@/collection/%@", self.albumOwner, self.albumDict[@"ID"]];
    NSLog(@"%@", self.albumOwner);
    NSLog(@"%@", self.albumDict[@"ID"]);
    Firebase *albumRef = [[Firebase alloc] initWithUrl:albumURL];
    [albumRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@", snapshot.value);
        if (snapshot.value == [NSNull null] && self.albumOwner.length > 0){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        //    NSLog(@"%@", self.albumDict[@"resourceURL"]);
        NSString *resourceURL = [NSString stringWithFormat:@"%@?key=%@&secret=%@",  self.albumDict[@"resourceURL"], DISCOGS_CONSUMER_KEY, DISCOGS_CONSUMER_SECRET];
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
        
        self.view.backgroundColor = [UIColor vinylLightGray];
        self.albumNameLabel.text = self.albumDict[@"title"];
        self.artistLabel.text = self.albumDict[@"artist"];
        self.albumYear.text =  [self.albumDict[@"releaseYear"] stringValue];
        self.ownerLabel.text = [NSString stringWithFormat: @"Owned by %@", self.albumOwnerDisplayName];
        if (self.trade && ![self.albumPrice isEqualToString:@""]){
            self.askingPriceLabel.text = [NSString stringWithFormat:@"$%@ or Trade",self.albumPrice];
        }
        else if (![self.albumPrice isEqualToString:@""] && !self.trade) {
            self.askingPriceLabel.text = [NSString stringWithFormat:@"$%@",self.albumPrice];
        }
        
        else self.askingPriceLabel.text = @"Trade";
        if (self.isBuyer) {
            self.sellTradeButton.hidden = YES;
            self.messageButton.hidden = NO;
            self.askingPriceLabel.hidden = NO;
            self.ownerLabel.hidden = NO;
        }
        
    Firebase *connectedRef = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/.info/connected"];
    [connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if([snapshot.value boolValue]) {
            NSLog(@"connected");
            
        } else {
            NSLog(@"not connected");
            self.sellTradeButton.enabled = NO;
        }
    }];
    }}];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addToMap"]) {
        AddViewController *destinationVC = segue.destinationViewController;
        destinationVC.ID = self.albumDict[@"ID"];
        destinationVC.albumName = self.albumDict[@"title"];
        destinationVC.albumArtist = self.albumDict[@"artist"];
        destinationVC.albumURL = self.albumDict[@"imageURL"];
        destinationVC.albumDeetVC = self;
    }
    
    else {
        ChatMessagesViewController *destinationVC = segue.destinationViewController;
        destinationVC.userToMessage = self.albumOwner;
        destinationVC.userToMessageDisplayName = self.albumOwnerDisplayName;
    }
}


@end
