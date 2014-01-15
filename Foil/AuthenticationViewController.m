//
//  AuthenticationViewController.m
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "SlidoutController.h"
#import "SlideoutViewController.h"
#import "Reachability.h"
#import "KeychainItemWrapper.h"
#import "FoilAppDelegate.h"

@implementation AuthenticationViewController{
    Interaction *_currentInteraction;
    FoilAppDelegate* myAppDelegate;
    BOOL userChecked;
}

@synthesize usernameEntered;
@synthesize passwordEntered;

- (void)viewDidLoad
{
    [super viewDidLoad];
    userChecked = NO;
    [self loadUserInfo];
    
    NSLog(@"%i", self.navigationController.viewControllers.count);

    //SWIPE GESTURE FOR SLIDE OUT MENU
    UISwipeGestureRecognizer *openSlideout = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeIn:)];
    openSlideout.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *closeSlideout = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeOut:)];
    closeSlideout.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:openSlideout];
    [self.view addGestureRecognizer:closeSlideout];
    
    //---------------------------------
    if ([self isFirstTimeLaunching] == YES) {
        _logotipoDash.alpha = 0;
        _logotipoHospitale.alpha = 0;
        [self presentTutorialForTheFirstTime];
    }
        // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [self resetTutorial];
}

//SWIPE GESTURES METHODS FOR THE SLIDE OUT MENU

-(void)handleSwipeIn:(UISwipeGestureRecognizer*)swipeIn{
    SlidoutController *controller = [[SlidoutController alloc] init];
    [controller openSlideOut];
    [self.view endEditing:YES];
    [self dismissSecondTip];
    NSLog(@"Swipe In working as intended.");
}

-(void)handleSwipeOut:(UISwipeGestureRecognizer*)swipeOut{
    [self swipeOut];
    NSLog(@"Swipe Out working as intended.");
}

-(void)swipeOut{
    SlidoutController *controller = [[SlidoutController alloc] init];
    [self dismissThirdTip];
    [controller closeSlideOut];
}

//--------------------------------------//

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
    userChecked = NO;
    [self checkForInterationsAndLoadUserContexts];
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    [self dismissFirstTip];
    [self swipeOut]; // CLOSE SLIDEOUT ON TEXTFIELD FOCUS
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
    [self checkTheRemindSwitch];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)loginClicked {
    NSLog(@"login clicked. Preparing to exibit next view");
    [self checkForInterationsAndLoadUserContexts];
    if (myAppDelegate.tutorialState >= FirstTipPresented && myAppDelegate.tutorialState <= ThirdTipPresented) {
        [self userGaveUpFollowingTheTutorial];
    }else{
        [self loginAction];
    }
}

-(void) loginAction{
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Conexão de Rede" message:@"Não foi possível estabelecer uma conexão de rede. Certifique-se de que os \"Dados Celulares\", \"3G\", ou \"WiFi\" estão ativados, que a conexão com sua operadora de rede está funcionando e tente mais tarde." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [self.buttonLogin setTitle:@"" forState:UIControlStateNormal];
        [self.loginActivity startAnimating];
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        SubscriberContextSelectionViewController *viewController = (SubscriberContextSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ContextSelectionView"];
        
        viewController.usernameEntered = self.textBoxUsername.text;
        viewController.passwordEntered = self.textBoxPassword.text;
        
        
        NSLog(@"Preparation completed. pushing view now");
        [self.navigationController pushViewController:viewController animated:YES];
        //[self presentViewController:viewController animated:YES completion:nil];
        [self.loginActivity stopAnimating];
        [self.buttonLogin setTitle:@"Login" forState:UIControlStateNormal];
    }
}

-(void) saveAllUserInfo{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"yourAppLogin" accessGroup:nil];
    [keychainItem setObject:self.textBoxUsername.text forKey:(__bridge id)(kSecAttrAccount)];
    [keychainItem setObject:self.textBoxPassword.text forKey:(__bridge id)(kSecValueData)];
}

-(void)checkTheRemindSwitch{
    if (_remindMeSwitch.on) {
        [self saveAllUserInfo];
    }else{
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"yourAppLogin" accessGroup:nil];
        [keychainItem resetKeychainItem];
    }
}

- (IBAction)remindMeSwitchValueChanged:(UISwitch *)sender {
    [self checkTheRemindSwitch];
}

- (void) loadUserInfo{
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"yourAppLogin" accessGroup:nil];
    NSString *username = [keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [keychain objectForKey:(__bridge id)(kSecValueData)];
    if (![username isEqual:@""]) {
        self.textBoxUsername.text = username;
        self.textBoxPassword.text = password;
        [self checkForInterationsAndLoadUserContexts];
    }else{
        [self.remindMeSwitch setOn:NO];
    }
}

- (void) checkForInterationsAndLoadUserContexts{
    if(_currentInteraction == nil){
        _currentInteraction = [Interaction getInstance];
    }
    if ((!_currentInteraction.allContextsForCurrentUser || _currentInteraction.allContextsForCurrentUser.count == 0) || userChecked == NO) {
        [_currentInteraction loadAllContextsForUser:self.textBoxUsername.text];
        if (!_currentInteraction.allContextsForCurrentUser || _currentInteraction.allContextsForCurrentUser.count == 0) {
            return;
        }
        userChecked = YES;
    }
}

-(BOOL)isFirstTimeLaunching{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        return NO;
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
}

////////////////////////////// DANGER TUTORIAL AREA BELOW////////////////////////////////////

-(void)presentTutorialForTheFirstTime{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Bem vindo ao Dash" message:@"Como esta é a primeira vez que abre o aplicativo, gostaríamos de oferecer uma rápida introdução aos recursos disponíveis no Dash. Gostaria de visualizar nosso tutorial?" delegate:self cancelButtonTitle:@"Não Visualizar" otherButtonTitles:@"Visualizar", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (alertView.tag == 1) { // see on the bottom of the page.
        if (buttonIndex == 1) {
            myAppDelegate.reviewThisPagesTutorial = NO;
            [self disableTutorial];
            [self loginAction];
        }else if (buttonIndex == 2){
            [self disableTutorial];
            myAppDelegate.tutorialState = ForthTipPresented;
            myAppDelegate.reviewThisPagesTutorial = NO;
            [self loginAction];
        }
        return;
    }else{
        if (buttonIndex > 0) {
            _logotipoHospitale.alpha = 0;
            _logotipoDash.alpha = 0;
            [self presentFirstTip];
        }else{
            [self presentLogos];
        }
    }
}

-(void)presentFirstTip{
    if (![self.textBoxUsername.text isEqual: @""]) {
        [self presentSecondTip];
        return;
    }
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    _firstTip.viewForBaselineLayout.layer.cornerRadius = 5;
    _firstTip.viewForBaselineLayout.layer.masksToBounds = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _firstTip.alpha = 1;
        _firstTipLabel.alpha = 1;
        myAppDelegate.tutorialState = FirstTipPresented;
    }completion:^(BOOL completed){
    }];
}

-(void)dismissFirstTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == FirstTipPresented) {
        [UIView animateWithDuration:0.3 animations:^{
            _firstTip.alpha = 0;
            _firstTipLabel.alpha = 0;
        }completion:^(BOOL completed){
            [self presentSecondTip];
        }];
    }
}

-(void)presentSecondTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    _secondTip.viewForBaselineLayout.layer.cornerRadius = 5;
    _secondTip.viewForBaselineLayout.layer.masksToBounds = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _secondTip.alpha = 1;
        _secondTipText.alpha = 1;
        myAppDelegate.tutorialState = SecondTipPresented;
    }completion:^(BOOL completed){
        [self secondTipAnimation];
    }];
}

-(void)dismissSecondTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == SecondTipPresented) {
        [UIView animateWithDuration:0.3 animations:^{
            _secondTip.alpha = 0;
            _secondTipText.alpha = 0;
            myAppDelegate.tutorialState = ThirdTipPresented;
        }completion:^(BOOL completed){
            [self presentThirdTip];
        }];
        _secondTipImage.alpha = 0;

    }
}

-(void)secondTipAnimation{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect rect = _secondTipImage.frame;
    CGRect newRect = CGRectMake(220, rect.origin.y, rect.size.width, rect.size.height);
    CGRect resetRect = CGRectMake(60, rect.origin.y, rect.size.width, rect.size.height);
    
    [UIView animateWithDuration:1.5 animations:^{
        _secondTipImage.alpha = 1;
        [_secondTipImage setFrame:newRect];
    }completion:^(BOOL completed){
        
        [UIView animateWithDuration:0.3 animations:^{
            _secondTipImage.alpha = 0;
            }completion:^(BOOL completed){
                [_secondTipImage setFrame:resetRect];
                if (myAppDelegate.tutorialState == SecondTipPresented) {
                    [self secondTipAnimation];
                }
            }];
    }];
}

-(void)presentThirdTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    _thirdTip.viewForBaselineLayout.layer.cornerRadius = 5;
    _thirdTip.viewForBaselineLayout.layer.masksToBounds = YES;
    [UIView animateWithDuration:0.6 animations:^{
        _thirdTip.alpha = 1;
        _thirdTipText.alpha = 1;
    }completion:^(BOOL completed){
        if (myAppDelegate.tutorialState == ThirdTipPresented) {
            [self thirdTipAnimation];
        }
    }];
}

-(void)dismissThirdTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == ThirdTipPresented) {
        [UIView animateWithDuration:0.3 animations:^{
            _thirdTip.alpha = 0;
            _thirdTipText.alpha = 0;
            if (myAppDelegate.reviewThisPagesTutorial == YES) {
                myAppDelegate.tutorialState = DisableTutorial;
                myAppDelegate.reviewThisPagesTutorial = NO;
            }else{
                myAppDelegate.tutorialState = ForthTipPresented;
            }
        }completion:^(BOOL completed){
            [self presentLogos];
        }];
        _thirdTipImage.alpha = 0;

    }
}

-(void)thirdTipAnimation{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect rect = _thirdTipImage.frame;
    CGRect newRect = CGRectMake(15, rect.origin.y, rect.size.width, rect.size.height);
    CGRect resetRect = CGRectMake(125, rect.origin.y, rect.size.width, rect.size.height);
    
    [UIView animateWithDuration:1.5 animations:^{
        _thirdTipImage.alpha = 1;
        [_thirdTipImage setFrame:newRect];
    }completion:^(BOOL completed){
        
        [UIView animateWithDuration:0.3 animations:^{
            _thirdTipImage.alpha = 0;
        }completion:^(BOOL completed){
            [_thirdTipImage setFrame:resetRect];
            if (myAppDelegate.tutorialState == ThirdTipPresented) {
                [self thirdTipAnimation];
            }
        }];
    }];
}

-(void)presentLogos{
    
    [UIView animateWithDuration:1 animations:^{
        _logotipoDash.alpha = 1;
    }completion:^(BOOL completed){
        [UIView animateWithDuration:0.3 animations:^{
            _logotipoHospitale.alpha = 1;
        }];
    }];
}

-(void)disableTutorial{
    _firstTip.alpha = 0;
    _firstTipLabel.alpha = 0;
    _secondTip.alpha = 0;
    _secondTipText.alpha = 0;
    _secondTipImage.alpha = 0;
    _thirdTip.alpha = 0;
    _thirdTipText.alpha = 0;
    _thirdTipImage.alpha = 0;
    if (myAppDelegate.reviewThisPagesTutorial == NO) {
        myAppDelegate.tutorialState = DisableTutorial;
    }
    _logotipoDash.alpha = 1;
    _logotipoHospitale.alpha = 1;
}

-(void)userGaveUpFollowingTheTutorial{
    NSString *text;
    NSString *thisViewOnly = @"Somente desta tela";
    if (myAppDelegate.tutorialState == FirstTipPresented || myAppDelegate.tutorialState == SecondTipPresented) {
        text = @"Você ainda não conferiu o menu, gostaria de encerrar o tutorial e continuar a navegacão?";
    }else if(myAppDelegate.tutorialState == ThirdTipPresented){
        text = @"Estamos terminando esta página. Gostaria de encerrar o tutorial e continuar a navegacão?";
    }
    if (myAppDelegate.reviewThisPagesTutorial == YES) {
        thisViewOnly = nil;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:self cancelButtonTitle:@"Ainda não" otherButtonTitles:@"Sim", thisViewOnly, nil];
    [alert setTag:1];
    [alert show];
}

-(void)resetTutorial{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == ResetTutorial) {
        //myAppDelegate.reviewThisPagesTutorial = NO;
        [self disableTutorial];
        myAppDelegate.tutorialState = GroundZero;
        _logotipoDash.alpha = 0;
        _logotipoHospitale.alpha = 0;
        [self presentFirstTip];
    }
    if (myAppDelegate.tutorialState == ThirdTipPresented) {
        SlidoutController *controller = [[SlidoutController alloc] init];
        [controller openSlideOut];
    }
}

- (void) restartThisPagesTutorialOnly{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    myAppDelegate.tutorialState = ResetTutorial;
    [self swipeOut];
    myAppDelegate.reviewThisPagesTutorial = YES;
}


@end
