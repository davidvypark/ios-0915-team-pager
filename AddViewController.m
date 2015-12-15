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
#import <UIKit+AFNetworking.h>
#import <Mapkit/Mapkit.h>
#import "UserObject.h"
#import "VinylColors.h"
#import <Masonry.h>
#import "VinylConstants.h"


@interface AddViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *addMapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) GeoFire * geoFire;
@property (nonatomic, strong) MKPointAnnotation *user;
@property (nonatomic, strong) NSString *currentUser;
@property (nonatomic, strong) VinylAnnotation *albumLocation;

@property (weak, nonatomic) IBOutlet UITextField *priceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sellSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tradeSwitch;

@property (nonatomic) BOOL forSale;
@property (nonatomic) BOOL forTrade;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;



@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
    self.addMapView.delegate = self;
    self.locationManager.delegate = self;
    
    
    // Do any additional setup after loading the view.
    NSString *urlString = [NSString stringWithFormat:@"%@geofire",FIREBASE_URL];
    Firebase *geofireRef = [[Firebase alloc] initWithUrl:urlString];
    self.geoFire = [[GeoFire alloc] initWithFirebaseRef:geofireRef];
    self.currentUser = [UserObject sharedUser].firebaseRoot.authData.uid;
    
    
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        self.addMapView.showsUserLocation = YES;
        
    }
    else {[self.locationManager startUpdatingLocation];
        self.addMapView.showsUserLocation = YES;
    }
    
    self.title = @"Add location";
//    self.theNavigationBar.tintColor = [UIColor vinylLightGray];
//    self.theNavigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
//    self.theNavigationBar.translucent = YES;
////    self.view.backgroundColor = [UIColor vinylDarkGray];
//    
//    CGFloat navHeight = self.albumDeetVC.navigationController.navigationBar.frame.size.height;
//    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
//    NSLog(@"navHeight: %f \n statusHeight: %f",navHeight,statusBarHeight);
//    
//    [self.theNavigationBar mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@(navHeight + statusBarHeight));
//        make.topMargin.equalTo(self.view);
//    }];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
}
- (IBAction)screenTapped:(id)sender {
    [self.priceLabel resignFirstResponder];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D selfCoord = self.addMapView.userLocation.location.coordinate;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(selfCoord, 2000.0, 2000.0);
    [self.addMapView setRegion:startRegion animated:NO];
    self.user = [[MKPointAnnotation alloc] init];
    self.user.coordinate = selfCoord;
    self.user.title = @"Your location";
    [self.addMapView addAnnotation:self.user];
    [self.addMapView selectAnnotation:self.user animated:YES];
    [self.locationManager stopUpdatingLocation];
    self.addMapView.showsUserLocation = NO;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKAnnotationView *annotationView;
    if ([annotation.title isEqualToString:@"Your location"]) {
        annotationView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"VinylAnnotation"];
        annotationView.tintColor = [UIColor blueColor];
        annotationView.canShowCallout = YES;
    }
    else {
        annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"VinylAnnotation"];
        UIImage *pinImage = [UIImage imageNamed:@"accommodations-pin.png"];
        annotationView.image = pinImage;
        annotationView.centerOffset = CGPointMake(0, -pinImage.size.height/2);
    }
    
    return annotationView;
}

- (IBAction)returnToUserTapped:(UIButton *)sender {
    [self.addMapView removeAnnotation:self.user];
    [self.locationManager startUpdatingLocation];
    self.addMapView.showsUserLocation = YES;
}



- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    sender.minimumPressDuration = 0.35;
    CGPoint touchPoint = [sender locationInView:self.addMapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.addMapView convertPoint:touchPoint toCoordinateFromView:self.addMapView];
    self.albumLocation = [[VinylAnnotation alloc] init];
    self.albumLocation.coordinate = touchMapCoordinate;
    NSMutableArray * annotationsToRemove = [self.addMapView.annotations mutableCopy];
    [annotationsToRemove removeObject:self.user];
    [self.addMapView removeAnnotations:annotationsToRemove];
    [self.addMapView addAnnotation:self.albumLocation];
    

    
    }
- (IBAction)tradeButtonChanged:(id)sender {
    if ([self.tradeSwitch isOn]) {
        self.priceLabel.text = @"";
        self.priceLabel.enabled = NO;
    }
    else self.priceLabel.enabled = YES;
}
- (IBAction)sellButtonChanged:(id)sender {
    if ([self.sellSwitch isOn]) {
        self.priceLabel.enabled = YES;
    }
    else {
        self.priceLabel.enabled = NO;
        self.priceLabel.text = @"";
    }}

- (IBAction)saveButtonTapped:(id)sender {



    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];

    Firebase *connectedRef = [[Firebase alloc] initWithUrl:@"https://amber-torch-8635.firebaseio.com/.info/connected"];
    [connectedRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(![snapshot.value boolValue]) {
            NSLog(@"Not Connected");
            UIAlertController *internetAlertController = [UIAlertController
                                                        alertControllerWithTitle:@"Please turn on internet access"
                                                        message:@"You must have a network connection to post items"
                                                        preferredStyle:UIAlertControllerStyleAlert];
            [internetAlertController addAction:okAction];
            [self presentViewController:internetAlertController animated:YES completion:nil];

            
        } else {
            NSLog(@"Connected");
    

    

    
    if (![self.sellSwitch isOn] && ![self.tradeSwitch isOn]) {
        UIAlertController *switchAlertController = [UIAlertController
                                                    alertControllerWithTitle:@"Please select at least one"
                                                    message:@"Item must be sold or traded"
                                                    preferredStyle:UIAlertControllerStyleAlert];
        [switchAlertController addAction:okAction];
        [self presentViewController:switchAlertController animated:YES completion:nil];
        
    }
    
    else if (!self.albumLocation) {
        UIAlertController *locationAlertController = [UIAlertController
                                                      alertControllerWithTitle:@"Item location required"
                                                      message:@"Please specify the item's location"
                                                      preferredStyle:UIAlertControllerStyleAlert];
            [locationAlertController addAction:okAction];
        [self presentViewController:locationAlertController animated:YES completion:nil];
    }

    else if (([self.sellSwitch isOn] || [self.tradeSwitch isOn]) && self.albumLocation) {
        if ([self.sellSwitch isOn]  && self.priceLabel.text.length == 0) {
            UIAlertController *priceAlertController =[UIAlertController
                                                      alertControllerWithTitle:@"Enter a price"
                                                      message:@"A price must be entered"
                                                       preferredStyle:UIAlertControllerStyleAlert];
            [priceAlertController addAction:okAction];
            [self presentViewController:priceAlertController animated:YES completion:nil];
        }
        else {
            __weak typeof(self) weakSelf = self;
            [self.geoFire setLocation:[[CLLocation alloc] initWithLatitude:self.albumLocation.coordinate.latitude longitude:self.albumLocation.coordinate.longitude] forKey:self.ID withCompletionBlock:^(NSError *error) {
                NSString *geofireAlbumURL = [NSString stringWithFormat:@"https://amber-torch-8635.firebaseio.com/geofire/%@", weakSelf.ID];
                Firebase *albumKey = [[Firebase alloc] initWithUrl:geofireAlbumURL];
                weakSelf.forSale = [weakSelf.sellSwitch isOn];
                weakSelf.forTrade = [weakSelf.tradeSwitch isOn];
                if (error != nil) {
                    NSLog(@"An error occurred: %@", error);
                }
                else {
                    
    [albumKey updateChildValues:@{@"owner" : weakSelf.currentUser, @"artist": weakSelf.albumArtist, @"title": weakSelf.albumName, @"imageURL": weakSelf.albumURL, @"price" : weakSelf.priceLabel.text, @"sale" : [NSNumber numberWithBool:weakSelf.forSale] , @"trade": [NSNumber numberWithBool:weakSelf.forTrade]} ];
                [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];}
    }
        }
    }];
    
}
- (IBAction)cancelButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
