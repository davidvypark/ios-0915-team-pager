//
//  AlbumDetailsViewController.h
//  VinylMap
//
//  Created by Linda NG on 11/30/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumDetailsViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *imageLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sellTradeButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UILabel *askingPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *albumAutoId;
@property (nonatomic, strong) NSString *albumImageURL;

@property (nonatomic, strong) NSString *resourceURL;

@property (nonatomic, strong) NSString *albumOwner;
@property (nonatomic, strong) NSString *albumPrice;
@property (nonatomic) BOOL isBuyer;
@end
