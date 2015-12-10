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

@interface MyAlbumsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *myCollection;
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) NSString * currentUser;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat squareSize;
@property (nonatomic, strong) NSDictionary *albumToBeDeleted;


@end

@implementation MyAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenWidth = MIN(self.view.frame.size.width,self.view.frame.size.height);
    self.squareSize = self.screenWidth * 0.45;
    self.myCollection.delegate = self;
    self.myCollection.dataSource = self;
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    longPressGR.delegate = self;
    longPressGR.delaysTouchesBegan = YES;
    [self.myCollection addGestureRecognizer:longPressGR];
    if ([UserObject sharedUser].firebaseRoot.authData) {
        [self setUpUserCollection];
        self.store = [AlbumCollectionDataStore sharedDataStore];
    }
}

- (void)setUpUserCollection {
    NSString *currentUser = [UserObject sharedUser].firebaseRoot.authData.uid;
    NSString *firebaseRefUrl = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/users/%@/collection", currentUser];
    self.firebaseRef = [[Firebase alloc] initWithUrl:firebaseRefUrl];
    self.albums = [[NSMutableArray alloc] init];
    [self.firebaseRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        
//        NSLog(@"eventTypeChildAdded");
        
        [self.albums addObject:snapshot.value];
        self.store.albums = [self.albums mutableCopy];
        [self.myCollection reloadData];
    }];
    [self.firebaseRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
//        NSLog(@"observeSingleEventOfType");
        [self.myCollection reloadData];
    }];
    
}


- (void)viewWillAppear:(BOOL)animated {
    if (![UserObject sharedUser].firebaseRoot.authData) {
        self.albums = [[NSMutableArray alloc] init];
        [self.myCollection reloadData];
    }
    else if (![self.currentUser isEqualToString:[UserObject sharedUser].firebaseRoot.authData.uid]) {
        [self setUpUserCollection];}
    else [self.myCollection reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%@",self.albums);
    return self.albums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath];
//    AlbumCollectionViewCell *cell = [[AlbumCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, self.squareSize, self.squareSize)]
    [cell.albumLabel setText:self.albums[indexPath.row][@"title"]];
    [cell.artistLabel setText:self.albums[indexPath.row][@"artist"]];
    NSURL *albumArtURL = [NSURL URLWithString:self.albums[indexPath.row][@"imageURL"]];
    [cell.albumArtView setImageWithURL:albumArtURL];
//    UIImage *albumImage = cell.albumArtView.image;
//    CGFloat imageWidth = albumImage.size.width;
//    albumImage = [UIImage imageWithCGImage:albumImage.CGImage scale:imageWidth/self.squareSize orientation:albumImage.imageOrientation];
//    [cell.albumArtView setImage:albumImage];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake(self.squareSize*.95, self.squareSize*.95 + 40);
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat insets = self.screenWidth - self.squareSize*2;
    insets = insets/2;
    return UIEdgeInsetsMake(0, insets, 0, insets); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.myCollection];
    
    NSIndexPath *indexPath = [self.myCollection indexPathForItemAtPoint:point];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        NSDictionary *album = self.albums[indexPath.row];
        self.albumToBeDeleted = album;
        [self displayDeleteAlertForAlbum:album[@"title"]];
    }
}

- (void)displayDeleteAlertForAlbum: (NSString *)albumName {
    NSString *alertMessage = [NSString stringWithFormat:@"You are about to delete %@ from your collection. Are you sure?", albumName];
    UIAlertController *alert=   [UIAlertController
                                 alertControllerWithTitle:@"Alert!"
                                 message:alertMessage
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction* delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction *action) {
                                 [self deleteAlbumFromCollection];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];
    [alert addAction:delete];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)deleteAlbumFromCollection {
    NSString *albumID = self.albumToBeDeleted[@"ID"];
    NSString *currentUser = [UserObject sharedUser].firebaseRoot.authData.uid;
    NSString *albumToBeDeletedURL = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/users/%@/collection/%@", currentUser, albumID];
    Firebase *deleteAlbumRef = [[Firebase alloc] initWithUrl:albumToBeDeletedURL];
    [self.store.albums removeObject:self.albumToBeDeleted];
    [deleteAlbumRef removeValue];
    [self.myCollection reloadData];
    
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     AlbumDetailsViewController *destinationVC = segue.destinationViewController;
     NSIndexPath *indexPath = [self.myCollection indexPathForCell:sender];
     NSDictionary *album = self.albums[indexPath.row];
     destinationVC.albumDict = [album mutableCopy];
 }


@end
