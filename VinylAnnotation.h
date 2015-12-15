//
//  VinylAnnotation.h
//  VinylMapView
//
//  Created by Linda NG on 11/23/15.
//  Copyright © 2015 Linda NG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VinylAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *sale;
@property (nonatomic, strong) NSString *trade;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *annotationKey;

-(id)initWithLocation:(CLLocationCoordinate2D)location;

@end
