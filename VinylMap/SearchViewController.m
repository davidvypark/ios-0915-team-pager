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

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *albumResults;
@property (nonatomic, strong) Firebase *firebase;
@property (nonatomic, strong) NSMutableArray* collection;
@property (strong, nonatomic) NSIndexPath *cellIndexPath;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchField.delegate = self;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.albumResults = [NSMutableArray new];
    self.firebase = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/users/Cat/collection"];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *searchKeyword = self.searchField.text;
    searchKeyword = [searchKeyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *discogsURL = [NSString stringWithFormat:@"https://api.discogs.com/database/search?q=%@&type=title&key=%@&secret=%@", searchKeyword, DISCOGS_CONSUMER_KEY, DISCOGS_CONSUMER_SECRET];
    [manager GET:discogsURL parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSArray *resultsArray = responseDictionary[@"results"];
        [self.albumResults removeAllObjects];
        [self.albumResults addObjectsFromArray:resultsArray];
        [self.searchTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Request failed with error %@", error);
    }];
    
    return YES;
}

- (IBAction)barcodeButtonTapped:(id)sender {
    BarcodeViewController *barcodeVC = [[BarcodeViewController alloc] init];
    [self presentViewController:barcodeVC animated:YES completion:nil];
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
    [album setValue:@{@"title": result[@"title"], @"imageURL": result[@"thumb"]}];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
    NSMutableString *albumInfo = [NSMutableString new];
    NSDictionary *result = self.albumResults[indexPath.row];
    NSArray *recordLabels = result[@"label"];
    NSLog(@"the record label is a %@ with a value of %@", [result[@"label"] class], result[@"label"]);

    NSString *recordLabel;
    if (!recordLabels.firstObject) {
        recordLabel = @"";
    }
    else {
        recordLabel = recordLabels.firstObject;
    }
    NSLog(@"the release year is a %@ with a value of %@", [result[@"year"] class], result[@"year"]);
    NSString *releaseYear;
    if (!result[@"year"]) {
        releaseYear = @"";
    }
    else {
        releaseYear = result[@"year"];
    }
    
    [albumInfo appendFormat:@"%@\n%@\n%@", result[@"title"], recordLabel, releaseYear];
    
    cell.albumInfoLabel.text = albumInfo;
    
    NSURL *albumArtURL = [NSURL URLWithString:result[@"thumb"]];
    [cell.albumView setImageWithURL:albumArtURL];
    
//    self.cellIndexPath = indexPath;
    return cell;
}

@end
