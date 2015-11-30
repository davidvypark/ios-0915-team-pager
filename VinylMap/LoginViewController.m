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
#import <Firebase/Firebase.h>
#import <FirebaseUI.h>
#import "VinylConstants.h"


@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (nonatomic, strong) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, strong) UIButton *dismissViewControllerButton;
@property (nonatomic, strong) UIButton *firebaseLoginButton;
@property (nonatomic, strong) FirebaseLoginViewController *firebaseLoginVC;

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
    self.dismissViewControllerButton.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:self.dismissViewControllerButton];
    [self.dismissViewControllerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.firebaseLoginButton = [[UIButton alloc] init];
    [self.firebaseLoginButton setTitle:@"FIREBASE LOGIN" forState:UIControlStateNormal];
    self.firebaseLoginButton.tintColor = [UIColor grayColor];
    self.firebaseLoginButton.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.firebaseLoginButton];
    
    [self.firebaseLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.dismissViewControllerButton.mas_top);
    }];
    
    NSArray *arrayOfButtons = @[self.dismissViewControllerButton, self.firebaseLoginButton];
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

-(void)firebaseLoginClicked
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Login"
                                          message:@"Please Login to VinylMap"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Email", @"Email");
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Password", @"Password");
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *login = alertController.textFields.firstObject;
                                   UITextField *password = alertController.textFields.lastObject;
                                   [self loginToFirebase:login.text password:password.text];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        //COMPLETION OF LOGIN ALERT VIEW CONTROLLER
    }];

    
}

-(void)loginToFirebase:(NSString *)username password:(NSString *)password
{
    [[UserObject sharedUser].firebaseRoot authUser:username password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
    if (error) {
        // an error occurred while attempting login
        NSLog(@"error %@",error);
    } else {
        // user is logged in, check authData for data
        NSLog(@"logged in successfully");
    }
}];
    
    
}

-(void)buttonClicked:(UIButton *)sendingButton
{

    if([sendingButton isEqual:self.dismissViewControllerButton])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if ([sendingButton isEqual:self.firebaseLoginButton])
    {
        [self firebaseLoginClicked];
        
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
