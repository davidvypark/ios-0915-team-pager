//
//  MainContentViewController.m
//  VinylMap
//
//  Created by Haaris Muneer on 12/1/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "MainContentViewController.h"

@interface MainContentViewController ()

@property (weak, nonatomic) IBOutlet UIView *hamburgerMenuContainer;
@property (weak, nonatomic) IBOutlet UIView *mainContentContainer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mainContentTapRecognizer;


@end

@implementation MainContentViewController



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowHamburgerMenu:) name:@"ShowHamburgerMenuNotification" object:nil];
}

-(void)handleShowHamburgerMenu:(NSNotification *)notification
{
    self.mainContentTapRecognizer.enabled = YES;
    
    [UIView animateWithDuration:0.12 animations:^{
        self.hamburgerMenuContainer.alpha = 1;
        self.mainContentContainer.alpha = 0.5;
    }];
}

- (IBAction)mainContentTapped:(id)sender {
    [UIView animateWithDuration:0.12 animations:^{
        self.hamburgerMenuContainer.alpha = 0;
        self.mainContentContainer.alpha = 1;
    }];
    
    self.mainContentTapRecognizer.enabled = NO;
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
