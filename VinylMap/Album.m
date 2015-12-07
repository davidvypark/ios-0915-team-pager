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
    album.titleWithArtist = titleWithArtist;
    NSArray *artistAndTitle = [titleWithArtist componentsSeparatedByString:@" - "];
    album.artist = artistAndTitle.firstObject;
    album.title = artistAndTitle.lastObject;
    album.barcode = dictionary[@"barcode"];
    NSArray *genres = dictionary[@"genre"];
    album.genre = genres.firstObject;
    album.albumID = dictionary[@"id"];
    album.recordLabels = dictionary[@"label"];
    album.country = dictionary[@"country"];
    album.resourceURL = dictionary[@"resource_url"];
    NSString *releaseYear = dictionary[@"year"];
    album.releaseYear = releaseYear.integerValue;
    return album;
}

@end
