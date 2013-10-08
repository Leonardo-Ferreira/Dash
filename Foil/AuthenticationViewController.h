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

@interface AuthenticationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textBoxUsername;
@property (weak, nonatomic) IBOutlet UITextField *textBoxPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

@property (strong, nonatomic, readwrite) NSString *usernameEntered;
@property (strong, nonatomic, readwrite) NSString *passwordEntered;
@property (weak, nonatomic) IBOutlet UISwitch *remindMeSwitch;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivity;

@end
