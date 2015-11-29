//
//  AddViewController.m
//  VinylMapView
//
//  Created by Linda NG on 11/24/15.
//  Copyright © 2015 Linda NG. All rights reserved.
//

#import "AddViewController.h"
#import <GeoFire/GeoFire.h>
#import <Firebase/Firebase.h>
#import "VinylAnnotation.h"

@interface AddViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *addMapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) GeoFire * geoFire;
@property (nonatomic, strong) VinylAnnotation *user;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
    self.addMapView.delegate = self;
    self.locationManager.delegate = self;
    
    // Do any additional setup after loading the view.
    Firebase *geofireRef = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/geofire"];
    self.geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
    
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        self.addMapView.showsUserLocation = YES;
        
    }
    else {[self.locationManager startUpdatingLocation];
        self.addMapView.showsUserLocation = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D selfCoord = self.addMapView.userLocation.location.coordinate;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(selfCoord, 1000.0, 1000.0);
    [self.addMapView setRegion:startRegion animated:NO];
     self.user = [[VinylAnnotation alloc] init];
    self.user.coordinate = selfCoord;
    self.user.title = @"Your location";
    [self.addMapView addAnnotation:self.user];
    [self.locationManager stopUpdatingLocation];
    self.addMapView.showsUserLocation = NO;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
    if ([annotation.title isEqualToString:@"Your location"]) {
        annView.pinTintColor = [UIColor blueColor];
    }
    return annView;
}

- (IBAction)returnToUserTapped:(UIButton *)sender {
    [self.addMapView removeAnnotation:self.user];
    [self.locationManager startUpdatingLocation];
    self.addMapView.showsUserLocation = YES;
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    sender.minimumPressDuration = 2.0;
    CGPoint touchPoint = [sender locationInView:self.addMapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.addMapView convertPoint:touchPoint toCoordinateFromView:self.addMapView];
    
    VinylAnnotation *annotation = [[VinylAnnotation alloc] init];
    annotation.coordinate = touchMapCoordinate;
    [self.addMapView addAnnotation:annotation];
    [self.geoFire setLocation:[[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude] forKey:@"test1"];
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
