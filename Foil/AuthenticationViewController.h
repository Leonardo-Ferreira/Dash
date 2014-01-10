//
//  AuthenticationViewController.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "ContextServices.h"
#import "Interaction.h"
#import "SubscriberContextSelectionViewController.h"

@interface AuthenticationViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textBoxUsername;
@property (weak, nonatomic) IBOutlet UITextField *textBoxPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

@property (strong, nonatomic, readwrite) NSString *usernameEntered;
@property (strong, nonatomic, readwrite) NSString *passwordEntered;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivity;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UISwitch *remindMeSwitch;

- (IBAction)remindMeSwitchValueChanged:(UISwitch *)sender;


@property (weak, nonatomic) IBOutlet UIView *firstTip;
@property (weak, nonatomic) IBOutlet UILabel *firstTipLabel;
@property (weak, nonatomic) IBOutlet UIView *secondTip;
@property (weak, nonatomic) IBOutlet UITextView *secondTipText;
@property (weak, nonatomic) IBOutlet UIImageView *secondTipImage;
@property (weak, nonatomic) IBOutlet UIView *thirdTip;
@property (weak, nonatomic) IBOutlet UITextView *thirdTipText;
@property (weak, nonatomic) IBOutlet UIImageView *thirdTipImage;
@property (nonatomic, assign) BOOL resetThisViewOnly;
- (void) restartThisPagesTutorialOnly;

@property (weak, nonatomic) IBOutlet UIImageView *logotipoDash;
@property (weak, nonatomic) IBOutlet UIImageView *logotipoHospitale;


@end
