//
//  AboutViewController.m
//  Foil
//
//  Created by AeC on 12/3/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "AboutViewController.h"
#import "SlideoutViewController.h"
#import "SlidoutController.h"
#import "FoilAppDelegate.h"

@interface AboutViewController ()

@end

@implementation AboutViewController{
    FoilAppDelegate* myAppDelegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _backButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    if (myAppDelegate.tutorialState >= FirstTipPresented && myAppDelegate.tutorialState <= SixthTipPresented && myAppDelegate.aboutViewTutorialPresented == NO) {
        _logotipoDashWhite.alpha = 0;
    }
    
    ////////////// GESTURE RECOGNIZERS //////////////////////
    
    UISwipeGestureRecognizer *exitScreen = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleExitScreen:)];
    exitScreen.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:exitScreen];
    /////////////////////////////////////////////////////////
    
}

-(void)handleExitScreen:(UISwipeGestureRecognizer*)exitScreen{
    [self goBack];
    
}

//SHAKE MOTION

- (BOOL) canBecomeFirstResponder { // To be able to respond to shake, the view must be a first responder.
    return YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    [self becomeFirstResponder];
    [self presentFirstTip];
}

- (void) viewDidDisappear:(BOOL)animated{
    [self resignFirstResponder];
    [super viewWillDisappear:NO];
}

- (void)goBack {
    
    [self dismissFirstTip];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CATransition *transition = [CATransition animation];
    [transition setSubtype:kCATransitionFromBottom];
    [transition setType:kCATransitionPush];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    [self.navigationController popViewControllerAnimated:NO];
    [CATransaction commit];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.subtype  == UIEventSubtypeMotionShake) {
        [self goBack];
    }
    if([super respondsToSelector:@selector(motionEnded:withEvent:)]){
        [super motionEnded:motion withEvent:event];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButton:(UIButton *)sender {
    [self goBack];
}


////////////////////////////// DANGER TUTORIAL AREA BELOW////////////////////////////////////

-(void)presentFirstTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState >= FirstTipPresented && myAppDelegate.tutorialState <= SixthTipPresented && myAppDelegate.aboutViewTutorialPresented == NO) {
        _firstTipView.viewForBaselineLayout.layer.cornerRadius = 5;
        _firstTipView.viewForBaselineLayout.layer.masksToBounds = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _firstTipView.alpha = 1;
            _firstTipText.alpha = 1;
        }completion:^(BOOL completed){
            [self firstTipAnimation];
        }];
    }
}

-(void)dismissFirstTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState >= FirstTipPresented && myAppDelegate.tutorialState <= SixthTipPresented && myAppDelegate.aboutViewTutorialPresented == NO) {
        _firstTipView.alpha = 0;
        _firstTipText.alpha = 0;
        _logotipoDashWhite.alpha = 1;
        myAppDelegate.aboutViewTutorialPresented = YES;
    }
}

-(void)firstTipAnimation{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect rect = _firstTipImage.frame;
    CGRect newRect = CGRectMake(rect.origin.x, 120, rect.size.width, rect.size.height);
    CGRect resetRect = CGRectMake(rect.origin.x, 82, rect.size.width, rect.size.height);
    
    [UIView animateWithDuration:1.5 animations:^{
        _firstTipImage.alpha = 1;
        [_firstTipImage setFrame:newRect];
    }completion:^(BOOL completed){
        
        [UIView animateWithDuration:0.3 animations:^{
            _firstTipImage.alpha = 0;
        }completion:^(BOOL completed){
            [_firstTipImage setFrame:resetRect];
            if (myAppDelegate.aboutViewTutorialPresented == NO) {
                [self firstTipAnimation];
            }
        }];
    }];
}



@end
