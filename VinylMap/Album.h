//
//  Album.h
//  
//
//  Created by Haaris Muneer on 11/23/15.
//
//

#import <Foundation/Foundation.h>

@interface Album : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *titleWithArtist;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, assign) NSString *albumID;
@property (nonatomic, strong) NSString *recordLabel;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSURL *resourceURL;
@property (nonatomic, assign) NSUInteger releaseYear;
@property (nonatomic, assign) BOOL isInCollection;
@property (nonatomic, assign) BOOL isInWishlist;

@end
