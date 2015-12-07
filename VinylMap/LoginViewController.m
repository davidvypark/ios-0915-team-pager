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
#import <FirebaseUI/FirebaseLoginViewController.h>
#import "VinylConstants.h"
#import <AFOAuth2Manager.h>
#import <AFNetworking.h>
#import <KDURLRequestSerialization+OAuth.h>
#import "DiscogsOAuthRequestSerializer.h"
#import "AccountCreationViewController.h"
#import "DiscogsButton.h"



@interface LoginViewController () <FBSDKLoginButtonDelegate, AccountCreationViewControllerDelegate>
@property (nonatomic, strong) FBSDKLoginButton *facebookLoginButton;
@property (nonatomic, strong) DiscogsButton *dismissViewControllerButton;
@property (nonatomic, strong) DiscogsButton *firebaseLoginButton;
@property (nonatomic, strong) DiscogsButton *firebaseLogoutButton;
@property (nonatomic, strong) DiscogsButton *discogsLoginButton;
@property (nonatomic, strong) DiscogsButton *createFirebaseAccount;


@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AccountCreationViewController *createAccountVC;

@property (nonatomic, strong) UITextView *textView;

@end



@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpButtons];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self discogsLoginButtonAlive];
    [self showLoginStatus];
}


#pragma mark - set up buttons

-(void)showLoginStatus
{
    self.textView = [[UITextView alloc] init];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.width.equalTo(self.view).offset(80);
        make.height.equalTo(@(40));
    }];
    self.textView.text = [UserObject sharedUser].firebaseRoot.authData.uid;
}


-(void)setUpButtons
{
    
    self.facebookLoginButton = [[FBSDKLoginButton alloc] init];
    self.facebookLoginButton.accessibilityIdentifier = @"facebookLogin";
    [self.view addSubview:self.facebookLoginButton];
    self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.facebookLoginButton.delegate = self;
    
    self.dismissViewControllerButton = [[DiscogsButton alloc] init];
    [self.dismissViewControllerButton setTitle:@"Dismiss VC" forState:UIControlStateNormal];
    [self.view addSubview:self.dismissViewControllerButton];
    
    self.discogsLoginButton = [[DiscogsButton alloc] init];
    [self.discogsLoginButton setTitle:@"LINK DISCOGS ACCOUNT" forState:UIControlStateNormal];
    [self.view addSubview:self.discogsLoginButton];
    
    self.firebaseLoginButton = [[DiscogsButton alloc] init];
    [self.firebaseLoginButton setTitle:@"FIREBASE LOGIN" forState:UIControlStateNormal];
    [self.view addSubview:self.firebaseLoginButton];
    
    self.firebaseLogoutButton = [[DiscogsButton alloc] init];
    [self.firebaseLogoutButton setTitle:@"FIREBASE LOGOUT" forState:UIControlStateNormal];
    [self.view addSubview:self.firebaseLogoutButton];
    
    self.createFirebaseAccount = [[DiscogsButton alloc] init];
    [self.createFirebaseAccount setTitle:@"CREATE ACCOUNT" forState:UIControlStateNormal];
    [self.view addSubview:self.createFirebaseAccount];
    
    
    NSArray *arrayOfButtons = @[self.discogsLoginButton, self.firebaseLogoutButton, self.firebaseLoginButton, self.createFirebaseAccount, self.facebookLoginButton];
    DiscogsButton *previousButton;
    for (DiscogsButton *button in arrayOfButtons) {
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        
        if(previousButton)
        {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@40);
                make.width.equalTo(self.view);
                make.bottom.equalTo(previousButton.mas_top);
            }];

        } else
        {
            UITabBarController *tabBarController = [UITabBarController new];
            CGFloat tabBarHeight = tabBarController.tabBar.frame.size.height;
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@40);
                make.width.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-tabBarHeight);
            }];
            
        }
        
        previousButton = button;
    }
    
}

-(void)discogsLoginButtonAlive
{
    if([UserObject sharedUser].firebaseRoot.authData)
    {
        self.discogsLoginButton.userInteractionEnabled = YES;
        self.discogsLoginButton.enabled = YES;
        [self.discogsLoginButton setTitle:@"LINK DISCOGS ACCOUNT" forState:UIControlStateNormal];
    } else
    {
        self.discogsLoginButton.userInteractionEnabled = NO;
        self.discogsLoginButton.enabled = NO;
        [self.discogsLoginButton setTitle:@"MUST LOGIN TO LINK DISCOGS" forState:UIControlStateNormal];
    }
    
    
}

-(void)buttonClicked:(DiscogsButton *)sendingButton
{
    
    if([sendingButton isEqual:self.dismissViewControllerButton])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if ([sendingButton isEqual:self.firebaseLoginButton])
    {
        [self firebaseLoginClicked];
        
    } else if ([sendingButton isEqual:self.firebaseLogoutButton])
    {
        [self logoutOfFirebase];
    } else if ([sendingButton isEqual:self.discogsLoginButton])
    {
        [self discogsLoginButtonPressed];
        
    } else if ([sendingButton isEqual:self.createFirebaseAccount])
    {
        [self createFirebaseAccountNow];
        
    }
    
}

#pragma mark - create account

-(void)createFirebaseAccountNow
{
    self.createAccountVC = [[AccountCreationViewController alloc] init];
    self.createAccountVC.delegate = self;
    [self.createAccountVC setModalPresentationStyle:UIModalPresentationOverFullScreen];
    [self presentViewController:self.createAccountVC animated:NO completion:nil];
    
    
}




#pragma mark - discogs login

-(void)discogsLoginButtonPressed
{
    NSString *stringURL = @"https://api.discogs.com/oauth/request_token";
    NSString *timeInterval = [NSString stringWithFormat:@"%ld", [@([[NSDate date] timeIntervalSince1970]) integerValue]];
    NSDictionary *params = @{@"oauth_consumer_key" : DISCOGS_CONSUMER_KEY,
                             @"oauth_signature" : [NSString stringWithFormat:@"%@&",DISCOGS_CONSUMER_SECRET],
                             @"oauth_signature_method":@"PLAINTEXT",
                             @"oauth_timestamp" : timeInterval,
                             @"oauth_nonce" : @"jThVrMF",
                             @"User-Agent" : @"uniqueVinylMaps",
                             @"oauth_version" : @"1.0",
                             @"oauth_callback" : @"vinyl-discogs-beeper://"
                             };
    
    self.manager = [AFHTTPSessionManager manager];
    
    
    DiscogsOAuthRequestSerializer *reqSerializer = [DiscogsOAuthRequestSerializer serializer];
    self.manager.requestSerializer = reqSerializer;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [self.manager GET:stringURL parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        responseString = [NSString stringWithFormat:@"%@?%@",stringURL,responseString]; //ADDED ORIGINAL URL TO USE QUEURY ITEMS
        NSURL *responseURL = [NSURL URLWithString:responseString]; // CHANGED TO NSURL
        NSURLComponents *urlComps = [NSURLComponents componentsWithURL:responseURL resolvingAgainstBaseURL:nil];
        NSArray *urlParts = urlComps.queryItems;
        
        for (NSURLQueryItem *queryItem in urlParts) {
            if([queryItem.name isEqualToString:@"oauth_token_secret"])
            {
                [UserObject sharedUser].discogsTokenSecret = queryItem.value;
                NSLog(@"OAuth Prelim Secret %@",queryItem.value);
            } else if ([queryItem.name isEqualToString:@"oauth_token"])
            {
                [UserObject sharedUser].discogsRequestToken = queryItem.value;
                NSLog(@"OAuth Prelim Token %@",queryItem.value);
            }
        }
        NSString *authorizeStringURL = [NSString stringWithFormat:@"https://discogs.com/oauth/authorize?oauth_token=%@",[UserObject sharedUser].discogsRequestToken];
        NSURL *authorizeURL = [NSURL URLWithString:authorizeStringURL];
        [[UIApplication sharedApplication] openURL:authorizeURL];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    
    
    
}



#pragma mark - facebook

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error

{
    NSLog(@"did complete with error %@",error);
    NSSet *grantedPermissions = result.token.permissions;
    NSSet *declinedPermissions = result.token.declinedPermissions;
    NSString *userID = result.token.userID;
    NSString *tokenString = result.token.tokenString;
    NSLog(@"userID: %@ \n token: %@ \n permissions: %@ \n declined permissions: %@ \n",userID,tokenString,grantedPermissions,declinedPermissions);
    [UserObject sharedUser].facebookUserID = [FBSDKAccessToken currentAccessToken].userID;
    [UserObject sharedUser].facebookToken = result.token.tokenString;
    
    [[UserObject sharedUser].firebaseRoot authWithOAuthProvider:@"facebook" token:result.token.tokenString withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if(error)
        {
            NSLog(@"%@",error);
        } else
        {
            NSLog(@"Facebook Login Complete"); //AUTHDATA COMPLETE
            NSDictionary *userProfile = authData.providerData[@"cachedUserProfile"];
            NSMutableDictionary *facebookUser = [@{
                                              @"provider": authData.provider,
                                              @"email" : authData.providerData[@"email"],
                                              @"displayName" : authData.providerData[@"displayName"],
                                              @"firstName" : userProfile[@"first_name"],
                                              @"lastName" : userProfile[@"last_name"],
                                              @"profileImageURL": authData.providerData[@"profileImageURL"]
                                              } mutableCopy];
            
            // Create a child path with a key set to the uid underneath the "users" node
            [[[[UserObject sharedUser].firebaseRoot childByAppendingPath:@"users"]
              childByAppendingPath:authData.uid] setValue:facebookUser];
            [self discogsLoginButtonAlive];
        }
    }];
    
}


-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    [self discogsLoginButtonAlive];
}

- (BOOL)loginButtonWillLogin:(FBSDKLoginButton *)loginButton
{
    
    return YES;
}

#pragma mark - firebase


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
//            NSData *firebaseAuth = [NSKeyedArchiver archivedDataWithRootObject:authData];
//            NSMutableDictionary *firebaseDictionary = [@{@"authData": authData} mutableCopy];
            [self discogsLoginButtonAlive];
        }
    }];
}


-(void)logoutOfFirebase
{
    [[UserObject sharedUser].firebaseRoot unauth];
    [self discogsLoginButtonAlive];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
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

#pragma mark - account creation

-(void)createAccountResult:(NSDictionary *)result
{
    [self loginToFirebase:result[@"email"] password:result[@"password"]];
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
