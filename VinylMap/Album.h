//
//  Album.h
//  
//
//  Created by Haaris Muneer on 11/23/15.
//
//

#import <Foundation/Foundation.h>

@interface Album : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSArray *recordLabels;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *resourceURL;
@property (nonatomic, assign) NSUInteger releaseYear;
@property (nonatomic, strong) NSString *categoryNumber;
@property (nonatomic, strong) NSString *thumbnailURL;

+(Album *)albumFromResultDictionary: (NSDictionary *) dictionary;

@end
