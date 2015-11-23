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
#import <FBSDKApplicationDelegate.h>
#import "UserObject.h"
#import <Google/Core.h>
#import <Google/SignIn.h>


@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (nonatomic, strong) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, strong) UIButton *dismissViewControllerButton;

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
    
    self.facebookLoginButton = [[FBSDKLoginButton alloc] init];
    self.facebookLoginButton.accessibilityIdentifier = @"facebookLogin";
    [self.view addSubview:self.facebookLoginButton];
    self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.facebookLoginButton.delegate = self;
    [self.facebookLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.bottomMargin.equalTo(self.view).multipliedBy(0.66);
    }];
    
    
    self.dismissViewControllerButton = [[UIButton alloc] init];
    [self.dismissViewControllerButton setTitle:@"Dismiss VC" forState:UIControlStateNormal];
    self.dismissViewControllerButton.tintColor = [UIColor grayColor];
    self.dismissViewControllerButton.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.dismissViewControllerButton];
    [self.dismissViewControllerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.width.equalTo(self.view);
        make.bottomMargin.equalTo(self.view);
    }];
    
    
    
    NSArray *arrayOfButtons = @[self.dismissViewControllerButton];
    for (id button in arrayOfButtons) {
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    
}


-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error

{
    NSLog(@"did complete with error %@",error);
    NSSet *grantedPermissions = result.token.permissions;
    NSSet *declinedPermissions = result.token.declinedPermissions;
    NSString *userID = result.token.userID;
    NSString *tokenString = result.token.tokenString;
    NSLog(@"userID: %@ \n token: %@ \n permissions: %@ \n declined permissions: %@ \n",userID,tokenString,grantedPermissions,declinedPermissions);
    [UserObject sharedUser].facebookUserID = [FBSDKAccessToken currentAccessToken].userID;
    
    
    
}





-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}

- (BOOL) loginButtonWillLogin:(FBSDKLoginButton *)loginButton
{
    
    return YES;
}


-(void)buttonClicked:(UIButton *)sendingButton
{

    if([sendingButton isEqual:self.dismissViewControllerButton])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
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
