//
//  LoginViewController.m
//  VinylMap
//
//  Created by JASON HARRIS on 11/19/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "LoginViewController.h"
#import <Masonry.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (nonatomic, strong) FBSDKLoginButton *facebookLoginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setUpButtons];
    
    
    
    
}


#pragma mark - set up buttons

-(void)setUpButtons
{
    
//    [FBSDKAccessToken currentAccessToken]; // CALL THIS FIRST BUT TO CHECK IF BUTTON IS NECESSARY
    self.facebookLoginButton = [[FBSDKLoginButton alloc] init];
    self.facebookLoginButton.accessibilityIdentifier = @"facebookLogin";
    [self.view addSubview:self.facebookLoginButton];
    self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.facebookLoginButton.delegate = self;
    [self.facebookLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.bottomMargin.equalTo(self.view).multipliedBy(0.66);
    }];
    
    
    
//    NSArray *arrayOfButtons = @[self.facebookLoginButton];
    for (id button in @[]) {
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    
}


-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error

{
    NSLog(@"did complete: %@", result);
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSLog(@"me: %@", result);
    }];
}


-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}


-(void)buttonClicked:(UIButton *)sendingButton
{

    if([sendingButton isEqual:self.facebookLoginButton])
    {

    } else if (YES)
    {
        
    } else if (YES)
    {
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (IBAction)googleLoginPressed:(id)sender
{
    
    
    
}


- (IBAction)discogsLoginPressed:(id)sender
{
    
    
    
}

- (IBAction)otherLoginPressed:(id)sender
{
    
    
    
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
