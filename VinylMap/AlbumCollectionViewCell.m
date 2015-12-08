//
//  AlbumCollectionViewCell.m
//  VinylMap
//
//  Created by Haaris Muneer on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "AlbumCollectionViewCell.h"

@implementation AlbumCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = 10;

    }
    
    return self;
    
    
}

@end
