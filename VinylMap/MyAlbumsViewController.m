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

@interface MyAlbumsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollection;
@property (nonatomic, strong) NSMutableArray *albums;

@end

@implementation MyAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.myCollection registerNib:[UINib nibWithNibName:@"CustomAlbumCell" bundle:[NSBundle mainBundle]]
//        forCellWithReuseIdentifier:@"albumCell"];
    self.myCollection.delegate = self;
    self.myCollection.dataSource = self;
    self.firebaseRef = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/users/Cat/collection"];
    self.albums = [[NSMutableArray alloc] init];
    [self.firebaseRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self.albums addObject:snapshot.value];
        [self.myCollection reloadData];
        NSLog(@"%@ %@", snapshot.key, snapshot.value);
    }];
    [self.firebaseRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self.myCollection reloadData];
        NSLog(@"%@ %@", snapshot.key, snapshot.value);
    }];
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
    NSLog(@"The thing is getting called");
    
    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath];
    srand48(time(0));
    [cell.albumLabel setText:self.albums[indexPath.row][@"title"]];
    [cell.artistLabel setText:self.albums[indexPath.row][@"artist"]];
    NSURL *albumArtURL = [NSURL URLWithString:self.albums[indexPath.row][@"imageURL"]];

    [cell.albumArtView setImageWithURL:albumArtURL];
    cell.albumArtView.backgroundColor = [UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:drand48()];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(150, 200);
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     AlbumDetailsViewController *desitinationVC = segue.destinationViewController;
     NSIndexPath *indexPath = [self.myCollection indexPathForCell:sender];
     NSDictionary *album = self.albums[indexPath.row];
     desitinationVC.albumAutoId = album[@"ID"];
     desitinationVC.albumName = album[@"title"];
     desitinationVC.albumImageURL = album[@"imageURL"];
     
 }


@end
