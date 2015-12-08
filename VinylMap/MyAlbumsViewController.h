//
//  MyAlbumsViewController.h
//  VinylMap
//
//  Created by Haaris Muneer on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "AlbumCollectionDataStore.h"

@interface MyAlbumsViewController : UIViewController

@property (strong, nonatomic) Firebase *firebaseRef;
@property (strong, nonatomic) AlbumCollectionDataStore *store;

- (void)setUpUserCollection;

@end
