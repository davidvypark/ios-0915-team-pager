//
//  MapViewController.m
//  VinylMapView
//
//  Created by Linda NG on 11/23/15.
//  Copyright © 2015 Linda NG. All rights reserved.
//

#import "MapViewController.h"
#import <GeoFire/GeoFire.h>
#import <Firebase/Firebase.h>
#import "VinylAnnotation.h"
#import <UIKit+AFNetworking.h>
#import "AlbumDetailsViewController.h"
#import "VinylColors.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) GeoFire * geoFire;
@property (nonatomic, strong) GFRegionQuery *regionQuery;
@property (nonatomic, strong) NSMutableDictionary *vinylAnnotations;
@property (weak, nonatomic) IBOutlet UITableView *availableVinylsTableView;




@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
//    self.view.backgroundColor = [UIColor vinylMediumGray];
    self.availableVinylsTableView.backgroundColor = [UIColor vinylLightGray];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.availableVinylsTableView.delegate = self;
    self.availableVinylsTableView.dataSource = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
        
    }
    else {[self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    }
   

    // Do any additional setup after loading the view.
    Firebase *geofireRef = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/geofire"];
    self.geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
    

    
    self.vinylAnnotations = [NSMutableDictionary dictionary];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)returnToUserTapped:(UIButton *)sender {
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Location services is off"
                                              message:@"Please allow app to use Location Services in Settings"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
        
        UIAlertAction *settingsAction = [UIAlertAction
                                   actionWithTitle:@"Settings"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                        [self openSettings];
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        [self presentViewController:alertController animated:YES completion:nil];
       
    }
}

- (void)openSettings
{
    if (&UIApplicationOpenSettingsURLString != NULL) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self updateOrSetupRegionQuery];
  
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D selfCoord = self.mapView.userLocation.location.coordinate;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(selfCoord, 3000.0, 3000.0);
    [self.mapView setRegion:startRegion animated:NO];
    [self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = NO;
    [self updateOrSetupRegionQuery];
    
}
- (void)updateOrSetupRegionQuery
{
    MKCoordinateRegion region = self.mapView.region;
    if (self.regionQuery != nil) {
        self.regionQuery.region = region;
    } else {
        self.regionQuery = [self.geoFire queryWithRegion:region];
        [self setupListeners:self.regionQuery];
    }


}

- (void)setupListeners:(GFQuery *)query
{
    
    
    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSString *albumOwnerUrl = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/geofire/%@", key];
        Firebase *albumOwner = [[Firebase alloc] initWithUrl:albumOwnerUrl];
        __block NSString *ownerOfKey = [[NSString alloc]init];
        __block VinylAnnotation *annotation = [[VinylAnnotation alloc] init];
        [albumOwner observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value != [NSNull null]) {
            ownerOfKey = snapshot.value[@"owner"];
            annotation.title = snapshot.value[@"title"];
            annotation.subtitle = snapshot.value[@"artist"];
            annotation.coordinate = location.coordinate;
            annotation.owner = ownerOfKey;
            annotation.annotationKey = key;
            [self.mapView addAnnotation:annotation];
            self.vinylAnnotations[key] = annotation;
            [self.availableVinylsTableView reloadData];
            }
        }];
        
    }];
    
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        VinylAnnotation *annotation = self.vinylAnnotations[key];
        [self.mapView removeAnnotation:annotation];
        [self.availableVinylsTableView reloadData];
    }];
    [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        VinylAnnotation *annotation = self.vinylAnnotations[key];
        [UIView animateWithDuration:3.0 animations:^{
            annotation.coordinate = location.coordinate;
            [self.availableVinylsTableView reloadData];
        }];
    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[VinylAnnotation class]]) {
        
        MKAnnotationView *pinView = (MKAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:@"VinylAnnotation"];
        
        if (!pinView) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"VinylAnnotation"];
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"accommodations-pin.png"];
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        else pinView.annotation = annotation;
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    VinylAnnotation *annView = view.annotation;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AlbumDetailsViewController *detailsOfSaleItem = [storyboard instantiateViewControllerWithIdentifier:@"AlbumDetailsViewController"];
    
    NSString *detailsOfSaleItemFirebaseURL = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/users/%@/collection/%@", annView.owner, annView.annotationKey];
    Firebase *detailsOfSaleItemFirebase = [[Firebase alloc] initWithUrl:detailsOfSaleItemFirebaseURL];
    
    [detailsOfSaleItemFirebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        detailsOfSaleItem.albumDict = snapshot.value;
        detailsOfSaleItem.albumDict[@"ID"] = annView.annotationKey;
        detailsOfSaleItem.isBuyer = YES;
        detailsOfSaleItem.albumOwner = annView.owner;
        }];
    
    NSString *saleItemOwnerDisplayName = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/users/%@", annView.owner];
    Firebase *ownerDisplayName = [[Firebase alloc]initWithUrl:saleItemOwnerDisplayName];
    [ownerDisplayName observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        detailsOfSaleItem.albumOwnerDisplayName = snapshot.value[@"displayName"];
        [self.navigationController pushViewController:detailsOfSaleItem animated:YES];}];
        }


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.mapView.annotations.count != 0) {
        return self.mapView.annotations.count;
    }
    else return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *) [cell viewWithTag:1];

        VinylAnnotation *rowAnnotation = [self.mapView.annotations objectAtIndex:indexPath.row];
        titleLabel.text = rowAnnotation.title;

    cell.backgroundColor = [UIColor vinylLightGray];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor vinylBlue];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mapView.annotations.count !=0) {
        [self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:indexPath.row] animated:NO];}
}
@end
