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


@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) GeoFire * geoFire;
@property (nonatomic, strong) GFRegionQuery *regionQuery;
@property (nonatomic, strong) NSMutableDictionary *vinylAnnotations;




@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    // Do any additional setup after loading the view.
    Firebase *geofireRef = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/geofire"];
    self.geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
        
    }
    else {[self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
}
    
    self.vinylAnnotations = [NSMutableDictionary dictionary];
    
}

- (void)viewDidAppear {
[self updateOrSetupRegionQuery];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D selfCoord = self.mapView.userLocation.location.coordinate;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(selfCoord, 3000.0, 3000.0);
    [self.mapView setRegion:startRegion animated:YES];
    [self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = NO;

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

- (void)updateOrSetupRegionQuery
{
    MKCoordinateRegion region = self.mapView.region;
    if (self.regionQuery != nil) {
        self.regionQuery.region = region;
    } else {
        self.regionQuery = [self.geoFire queryWithRegion:region];
        [self setupListeners:self.regionQuery];
    }
    NSLog(@"Updated query to region [%f +/- %f, %f, +/- %f]",
          region.center.latitude, region.span.latitudeDelta/2,
          region.center.longitude, region.span.longitudeDelta/2);
}

- (void)setupListeners:(GFQuery *)query
{

    [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSString *albumOwnerUrl = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/geofire/%@", key];
        Firebase *albumOwner = [[Firebase alloc] initWithUrl:albumOwnerUrl];
        __block NSString *ownerOfKey = [[NSString alloc]init];
        __block VinylAnnotation *annotation = [[VinylAnnotation alloc] init];
        [albumOwner observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"%@", snapshot.value[@"owner"]);
            ownerOfKey = snapshot.value[@"owner"];
            annotation.title = key;
            annotation.coordinate = location.coordinate;
            annotation.owner = ownerOfKey;
            annotation.annotationKey = key;
            [self.mapView addAnnotation:annotation];
            self.vinylAnnotations[key] = annotation;

        }];
        
    }];
    [query observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        VinylAnnotation *annotation = self.vinylAnnotations[key];
        [self.mapView removeAnnotation:annotation];
    }];
    [query observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        VinylAnnotation *annotation = self.vinylAnnotations[key];
        [UIView animateWithDuration:3.0 animations:^{
            annotation.coordinate = location.coordinate;
        }];
    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[VinylAnnotation class]]) {
        
        MKPinAnnotationView *pinView = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:@"VinylAnnotation"];
        
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"VinylAnnotation"];
            pinView.canShowCallout = YES;
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
    [ownerDisplayName observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        detailsOfSaleItem.albumOwnerDisplayName = snapshot.value[@"displayName"];
        [self.navigationController pushViewController:detailsOfSaleItem animated:YES];}];
        }




@end
