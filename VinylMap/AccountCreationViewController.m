//
//  AccountCreationViewController.m
//  VinylMap
//
//  Created by JASON HARRIS on 12/3/15.
//  Copyright © 2015 Toaster. All rights reserved.
//

#import "AccountCreationViewController.h"
#import <Masonry.h>

@interface AccountCreationViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *emailAddressField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *confirmPassword;
@property (nonatomic, strong) UITextField *firstName;
@property (nonatomic, strong) UITextField *lastName;
@property (nonatomic, strong) UISwitch *acceptTerms;
@property (nonatomic, assign) CGFloat textSize;


@end

@implementation AccountCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    self.textSize = 30;
    // Do any additional setup after loading the view from its nib.
    [self setupButtons];
    [self setupTextFields];
    
    
    
}

-(void)setupTextFields
{
    self.firstName = [[UITextField alloc] init];
    self.firstName.placeholder = @"first name";
    self.lastName = [[UITextField alloc] init];
    self.lastName.placeholder = @"last name";
    self.emailAddressField = [[UITextField alloc] init];
    self.emailAddressField.placeholder = @"email address";
    self.passwordField = [[UITextField alloc] init];
    self.passwordField.placeholder = @"password";
    self.passwordField.secureTextEntry = YES;
    self.confirmPassword = [[UITextField alloc] init];
    self.confirmPassword.placeholder = @"retype password";
    self.confirmPassword.secureTextEntry = YES;

    
    NSArray *textFieldArray = @[self.firstName , self.lastName , self.emailAddressField , self.passwordField , self.confirmPassword];
    UITextField *previousField;
    for (UITextField *textField in textFieldArray) {
        [self.view addSubview:textField];
        CGFloat grayNESS = 0.9;
        textField.backgroundColor = [[UIColor alloc] initWithRed:grayNESS green:grayNESS blue:grayNESS alpha:1];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).multipliedBy(0.9);
            make.height.equalTo(@(self.textSize));
            make.centerX.equalTo(self.view);
            
            if(previousField)
            {
                make.top.equalTo(previousField.mas_bottom).offset(self.textSize * 0.5);
            } else
            {
                make.top.equalTo(self.view).offset(self.textSize * 3);
            }
            
            
        }];
        
        
        previousField = textField;
    }
    
    
}



-(void)setupButtons
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
}

-(void)setupBackground
{
    UIView *behindVisualEffect = [[UIView alloc] init];
//    behindVisualEffect.alpha = 0.9;
    behindVisualEffect.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:behindVisualEffect];
    [behindVisualEffect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(behindVisualEffect.superview);
    }];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    backgroundView.accessibilityLabel = @"backGround";
    [behindVisualEffect addSubview:backgroundView];
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    NSLog(@"user touched this object: %@",touches.anyObject.view.accessibilityLabel);
    
    if([touches.anyObject.view.accessibilityLabel isEqualToString:@"backGround"])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
