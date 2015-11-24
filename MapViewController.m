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
        VinylAnnotation *annotation = [[VinylAnnotation alloc] init];
        annotation.coordinate = location.coordinate;
        annotation.title = @"Testing";
        [self.mapView addAnnotation:annotation];
        self.vinylAnnotations[key] = annotation;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
