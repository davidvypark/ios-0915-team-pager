//
//  AlbumTableViewCell.h
//  VinylMap
//
//  Created by Haaris Muneer on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *albumView;
@property (weak, nonatomic) IBOutlet UILabel *artistAndTitle;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (weak, nonatomic) IBOutlet UILabel *year;

@end
