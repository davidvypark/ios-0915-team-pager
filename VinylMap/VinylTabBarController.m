//
//  VinylTabBarController.m
//  VinylMap
//
//  Created by JASON HARRIS on 12/10/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "VinylTabBarController.h"

@interface VinylTabBarController ()

@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat screenWidth;
@end


@implementation VinylTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSelectedIndex:2];
    
    
}

//-(void)setScreenHeightandWidth
//{
//    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    self.screenWidth = MAX(screenSize.width, screenSize.height);
//    self.screenHeight = MIN(screenSize.width, screenSize.height);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
