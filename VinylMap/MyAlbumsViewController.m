//
//  MyAlbumsViewController.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "MyAlbumsViewController.h"
#import "AlbumCollectionViewCell.h"

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
    [self populateAlbumsArray];
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
    [cell.albumArtView setImage:[UIImage imageNamed:self.albums[indexPath.row][@"artwork"]]];
    cell.albumArtView.backgroundColor = [UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:drand48()];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(150, 200);
}

-(void) populateAlbumsArray {
    self.albums = [NSMutableArray new];
    [self.albums addObject:@{@"title":@"Album 1", @"artist":@"Artist 1", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 2", @"artist":@"Artist 2", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 3", @"artist":@"Artist 3", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"To Pimp a Butterfly", @"artist":@"Kendrick Lamar", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 5", @"artist":@"Artist 5", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 6", @"artist":@"Artist 6", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 7", @"artist":@"Artist 7", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 8", @"artist":@"Artist 8", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 9", @"artist":@"Artist 9", @"artwork":@"Images/record.png"}];
    [self.albums addObject:@{@"title":@"Album 10", @"artist":@"Artist 10", @"artwork":@"Images/record.png"}];
}

@end
