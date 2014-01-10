//
//  TutorialViewController.m
//  Foil
//
//  Created by Leonardo Ferreira on 10/14/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "TutorialViewController.h"
#import "AuthenticationViewController.h"
#import "FoilAppDelegate.h"

@interface TutorialViewController (){
    NSArray *images;
}


@end

@implementation TutorialViewController
@synthesize scrollView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"tutorial loaded fine");
    
    [self buildImageArray];
    
    for (int i=0; i < images.count; i++) {
        
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *subview = [[UIImageView alloc] initWithImage:[images objectAtIndex:i]];
        subview.frame = frame;
        [self.scrollView addSubview:subview];
        
        UISwipeGestureRecognizer *swipeOut = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeOut:)];
        swipeOut.direction = UISwipeGestureRecognizerDirectionDown;
        
        subview.userInteractionEnabled = YES;
        [subview addGestureRecognizer:swipeOut];
        
    }
    FoilAppDelegate* myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    int location = self.scrollView.frame.size.width * myAppDelegate.tutorialPage;
    CGPoint point = CGPointMake(location, 0);
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * images.count, self.scrollView.frame.size.height/2); //O /2 serve para controlar scroll vertical.
    
    [self.scrollView setContentOffset:point animated:NO];
    
	// Do any additional setup after loading the view.
}



-(void)buildImageArray{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.height > 480.0f) {
        [self createArrayForIphone5];
    }else{
        [self createArrayForIphone4];
    }
}

-(void)createArrayForIphone4{
    images = [NSArray arrayWithObjects:[UIImage imageNamed:@"tutorialView01"], [UIImage imageNamed:@"tutorialView02"], [UIImage imageNamed:@"tutorialView03"], [UIImage imageNamed:@"tutorialView04"], [UIImage imageNamed:@"tutorialView05"], [UIImage imageNamed:@"tutorialView06"], [UIImage imageNamed:@"tutorialViewFinalImage"], nil];
}

-(void)createArrayForIphone5{
    images = [NSArray arrayWithObjects:[UIImage imageNamed:@"iP5tutorialView01"], [UIImage imageNamed:@"iP5tutorialView02"], [UIImage imageNamed:@"iP5tutorialView03"], [UIImage imageNamed:@"iP5tutorialView04"], [UIImage imageNamed:@"iP5tutorialView05"], [UIImage imageNamed:@"iP5tutorialView06"], [UIImage imageNamed:@"iP5tutorialViewFinalImage"], nil];
}

- (BOOL) canBecomeFirstResponder { // To be able to respond to shake, the view must be a first responder.
    return YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    [self becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated{
    [self resignFirstResponder];
    [super viewWillDisappear:NO];
}

-(void)handleSwipeOut:(UISwipeGestureRecognizer*)swipeOut{
    
    [self goBack];

}

- (void)goBack {
    int page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    FoilAppDelegate* myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    myAppDelegate.tutorialPage = page;
    
    [((UIViewController *)self.nextResponder) dismissViewControllerAnimated:YES completion:nil];
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


@end
