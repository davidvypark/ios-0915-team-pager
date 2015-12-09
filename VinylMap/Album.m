//
//  Album.m
//  
//
//  Created by Haaris Muneer on 11/23/15.
//
//

#import "Album.h"

@implementation Album

+(Album *)albumFromResultDictionary: (NSDictionary *) dictionary {
    Album *album = [Album new];
    NSString *titleWithArtist = dictionary[@"title"];
    NSArray *artistAndTitle = [titleWithArtist componentsSeparatedByString:@" - "];
    album.artist = artistAndTitle.firstObject;
    album.title = artistAndTitle.lastObject;
    NSArray *barcodes = dictionary[@"barcode"];
    album.recordLabels = dictionary[@"label"];
    album.country = dictionary[@"country"];
    album.resourceURL = dictionary[@"resource_url"];
    NSString *releaseYear = dictionary[@"year"];
    album.releaseYear = releaseYear.integerValue;
    album.categoryNumber = dictionary[@"catno"];
    album.thumbnailURL = dictionary[@"thumb"];
    return album;
}

@end
