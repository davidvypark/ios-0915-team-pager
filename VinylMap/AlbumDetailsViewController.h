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
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *albumAutoId;
@property (nonatomic, strong) NSString *albumImageURL;
@end
