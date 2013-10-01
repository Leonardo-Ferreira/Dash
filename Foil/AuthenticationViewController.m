//
//  AuthenticationViewController.m
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "AuthenticationViewController.h"

@implementation AuthenticationViewController{
    Interaction *_currentInteraction;
}

@synthesize usernameEntered;
@synthesize passwordEntered;

- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    if(textField != self.textBoxPassword){
        [self.textBoxPassword becomeFirstResponder];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (IBAction)usernameChanged:(id)sender {
    if(_currentInteraction == nil){
        _currentInteraction = [Interaction getInstance];
    }
    [_currentInteraction loadAllContextsForUser:[self.textBoxUsername.text copy]];
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (IBAction)loginClicked {
    NSLog(@"login clicked. Preparing to exibit next view");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SubscriberContextSelectionViewController *viewController = (SubscriberContextSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ContextSelectionView"];
    
    viewController.usernameEntered = self.textBoxUsername.text;
    viewController.passwordEntered = self.textBoxPassword.text;
    
    NSLog(@"Preparation completed. pushing view now");
    
    [self presentViewController:viewController animated:YES completion:nil];
}
@end
