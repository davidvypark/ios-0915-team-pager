//
//  SearchViewController.h
//  VinylMap
//
//  Created by Haaris Muneer on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumCollectionDataStore.h"

@interface SearchViewController : UIViewController
- (void)setupFirebase;
@property (nonatomic, strong) AlbumCollectionDataStore *store;

-(void)makeSearchFieldFirstResponder;

@end
