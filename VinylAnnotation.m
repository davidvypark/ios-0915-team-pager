//
//  VinylAnnotation.m
//  VinylMapView
//
//  Created by Linda NG on 11/23/15.
//  Copyright © 2015 Linda NG. All rights reserved.
//

#import "VinylAnnotation.h"


@implementation VinylAnnotation
@synthesize coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    return self;
}


//- (MKAnnotationView *) annotationView {
//    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"VinylAnnotation"];
//    annotationView.enabled = YES;
//    annotationView.canShowCallout = YES;
//    annotationView.image = self.image;
//    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    return annotationView;
//}
@end
