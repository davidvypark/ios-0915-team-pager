//
//  BarcodesObject.h
//  VinylMap
//
//  Created by JASON HARRIS on 11/18/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BarcodesObject : NSObject

@property (nonatomic, strong) NSMutableSet *barcodesSet;


-(instancetype)init;
+(instancetype)sharedBarcodes;










@end
