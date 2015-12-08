//
//  MyAlbumsViewController.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "MyAlbumsViewController.h"
#import "AlbumCollectionViewCell.h"
#import <UIKit+AFNetworking.h>
#import "AlbumDetailsViewController.h"
#import "UserObject.h"
#import <Masonry.h>

@interface MyAlbumsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollection;
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat squareSize;



@end

@implementation MyAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenWidth = MIN(self.view.frame.size.width,self.view.frame.size.height);
    self.squareSize = self.screenWidth * 0.45;
    UITabBarController *tabBarController = (UITabBarController*)[UIApplication sharedApplication].keyWindow.rootViewController ;
    [tabBarController setDelegate:self];
    self.myCollection.delegate = self;
    self.myCollection.dataSource = self;
    self.tabBarController.delegate = self;
    [self setUpUserCollection];
    self.store = [AlbumCollectionDataStore sharedDataStore];
}

- (void)setUpUserCollection {
    NSString *currentUser = [UserObject sharedUser].firebaseRoot.authData.uid;
    NSString *firebaseRefUrl = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/users/%@/collection", currentUser];
    self.firebaseRef = [[Firebase alloc] initWithUrl:firebaseRefUrl];
    self.albums = [[NSMutableArray alloc] init];
    [self.firebaseRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        
//        NSLog(@"eventTypeChildAdded");
        
        [self.albums addObject:snapshot.value];
        self.store.albums = self.albums;
        [self.myCollection reloadData];
    }];
    [self.firebaseRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        NSLog(@"observeSingleEventOfType");
        [self.myCollection reloadData];
    }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self setUpUserCollection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath];
//    AlbumCollectionViewCell *cell = [[AlbumCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, self.squareSize, self.squareSize)]
    [cell.albumLabel setText:self.albums[indexPath.row][@"title"]];
    [cell.artistLabel setText:self.albums[indexPath.row][@"artist"]];
    NSURL *albumArtURL = [NSURL URLWithString:self.albums[indexPath.row][@"imageURL"]];
    UIImage *albumImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:albumArtURL]];
    CGFloat imageWidth = albumImage.size.width;
    albumImage = [UIImage imageWithCGImage:albumImage.CGImage scale:imageWidth/self.squareSize orientation:albumImage.imageOrientation];
    NSLog(@"%1.1f",albumImage.size.width);
    NSLog(@"%1.1f",self.squareSize);
    [cell.albumArtView setImage:albumImage];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake(self.squareSize, self.squareSize + 40);
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat insets = self.screenWidth - self.squareSize*2;
    insets = insets/2;
    return UIEdgeInsetsMake(0, insets, 0, insets); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 00;
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     AlbumDetailsViewController *destinationVC = segue.destinationViewController;
     NSIndexPath *indexPath = [self.myCollection indexPathForCell:sender];
     NSDictionary *album = self.albums[indexPath.row];
     destinationVC.albumDict = [album mutableCopy];
 }


@end
