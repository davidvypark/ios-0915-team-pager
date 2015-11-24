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
@end
