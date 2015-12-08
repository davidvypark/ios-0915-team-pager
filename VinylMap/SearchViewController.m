//
//  SearchViewController.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "SearchViewController.h"
#import "BarcodeViewController.h"
#import <AFNetworking.h>
#import "VinylConstants.h"
#import "AlbumTableViewCell.h"
#import <UIKit+AFNetworking.h>
#import <Firebase/Firebase.h>
#import "DiscogsAPI.h"
#import "UserObject.h"
#import "Album.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BarCodeViewControllerDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *albumResults;
@property (nonatomic, strong) Firebase *firebase;
@property (nonatomic, strong) NSMutableArray* collection;
@property (strong, nonatomic) NSIndexPath *cellIndexPath;


@property (nonatomic, strong) BarcodeViewController *barcodeVC;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.searchField.delegate = self;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.tabBarController.delegate = self;
    self.albumResults = [NSMutableArray new];
    [self setupFirebase];
}

-(void)viewWillAppear:(BOOL)animated {
    [self setupFirebase];
}

- (void)setupFirebase{
    NSString *currentUser = [UserObject sharedUser].firebaseRoot.authData.uid;
    NSString *firebaseRefUrl = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/users/%@/collection", currentUser];
    self.firebase = [[Firebase alloc] initWithUrl:firebaseRefUrl];
    self.store = [AlbumCollectionDataStore sharedDataStore];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *searchKeyword = self.searchField.text;
    searchKeyword = [searchKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *discogsURL = [NSString stringWithFormat:@"https://api.discogs.com/database/search?q=%@&type=title&key=%@&secret=%@", searchKeyword, DISCOGS_CONSUMER_KEY, DISCOGS_CONSUMER_SECRET];
    [manager GET:discogsURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSArray *resultsArray = responseDictionary[@"results"];
            [self.albumResults removeAllObjects];
            
            
            NSMutableArray *holdingTheCategoryNumbers = [NSMutableArray new];
            for (NSDictionary *album in self.store.albums) {
                NSString *categoryNumber = album[@"categoryNumber"];
                [holdingTheCategoryNumbers addObject: categoryNumber];
            }
            
            for (NSDictionary *result in resultsArray) {
                NSMutableDictionary *mutableResult = [result mutableCopy];
                mutableResult[@"hasBeenAdded"] = @"NO";

                if ([result[@"format"] containsObject:@"Vinyl"]) {
                    NSString *categoryNumberOfResult = result[@"catno"];
                    
                    if ([holdingTheCategoryNumbers containsObject:categoryNumberOfResult]) {
                        mutableResult[@"hasBeenAdded"] = @"YES";
                    }
                    [self.albumResults addObject:mutableResult];
                }
            }
            [self.searchTableView reloadData];
        }];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Request failed with error %@", error);
    }];
    
    return YES;
}




- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumResults.count;
}

- (IBAction)addButtonTapped:(UIButton *)sender {
    Firebase *album = [self.firebase childByAutoId];
    CGPoint pos = [sender convertPoint:CGPointZero toView:self.searchTableView];
    NSIndexPath *indexPath = [self.searchTableView indexPathForRowAtPoint:pos];
    NSDictionary *result = self.albumResults[indexPath.row];
    Album *resultAlbum = [Album albumFromResultDictionary:result];
    [album setValue:@{@"artist": resultAlbum.artist,
                       @"title": resultAlbum.title,
                     @"barcode": resultAlbum.barcode,
                @"recordLabels": resultAlbum.recordLabels,
                     @"country": resultAlbum.country,
                 @"releaseYear": @(resultAlbum.releaseYear),
              @"categoryNumber": resultAlbum.categoryNumber,
                    @"imageURL": resultAlbum.thumbnailURL,
                          @"ID": album.key,
                 @"resourceURL": resultAlbum.resourceURL}];
    //[self.searchTableView reloadData];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
    NSMutableString *albumInfo = [NSMutableString new];
    NSDictionary *result = self.albumResults[indexPath.row];
    NSArray *recordLabels = result[@"label"];

    NSString *recordLabel;
    if (!recordLabels.firstObject) {
        recordLabel = @"";
    }
    else {
        recordLabel = recordLabels.firstObject;
    }
    NSString *releaseYear;
    if (!result[@"year"]) {
        releaseYear = @"";
    }
    else {
        releaseYear = result[@"year"];
    }
    
    cell.artistAndTitle.text = result[@"title"];
    cell.recordLabel.text = recordLabel;
    cell.year.text = releaseYear;
    
    //cell.albumInfoLabel.text = albumInfo;
    
    NSURL *albumArtURL = [NSURL URLWithString:result[@"thumb"]];
    [cell.albumView setImageWithURL:albumArtURL];
    if ([result[@"hasBeenAdded"] isEqualToString:@"YES"]) {
        [cell.addButton setTitle:@"✔︎" forState:UIControlStateNormal];
        cell.addButton.enabled = NO;
    }
    return cell;
}

#pragma mark - barcode search
- (IBAction)barcodeButtonTapped:(id)sender {
    self.barcodeVC = [[BarcodeViewController alloc] init];
    self.barcodeVC.delegate = self;
    [self.barcodeVC setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [self presentViewController:self.barcodeVC animated:NO completion:nil];
}

-(NSArray *)barcodeScanResult:(NSString *)barcode {
    
    if([barcode isEqualToString:@"dismissed"])
    {
        [self.barcodeVC dismissViewControllerAnimated:NO completion:nil];
    } else
    {
        [self.barcodeVC dismissViewControllerAnimated:NO completion:^{
            NSLog(@"searching for %@",barcode);
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.center = CGPointMake(160, 240);
            spinner.tag = 12;
            [self.view addSubview:spinner];
            [spinner startAnimating];
            [DiscogsAPI barcodeAPIsearch:barcode withCompletion:^(NSArray *arrayOfAlbums, bool isError) {
                NSLog(@"%@",arrayOfAlbums);//RESULTS FROM DISCOGS API
                [spinner removeFromSuperview];
            }];
        }];
    }
    
    return nil;
}

@end
