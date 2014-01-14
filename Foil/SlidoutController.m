//
//  SlidoutController.m
//  Foil
//
//  Created by AeC on 11/29/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "SlidoutController.h"
#import "SlideoutViewController.h"
#import "AuthenticationViewController.h"
#import "AboutViewController.h"
#import "FoilAppDelegate.h"
#import "SVBackstageViewController.h"

@implementation SlidoutController


- (void) openSlideOut{
    FoilAppDelegate* myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (myAppDelegate.slideoutMenuPresented == NO) {
        //Gets the currently RootView
        id currentRootVC = myAppDelegate.navigationController.visibleViewController;
        [[currentRootVC view] setTag:2];
        if ([currentRootVC isKindOfClass:[AuthenticationViewController class]]) {
            [[currentRootVC view] setTag:3];
        }
        if ([currentRootVC isKindOfClass:[AboutViewController class]]) {
            [[currentRootVC view] setTag:4];
        }
        
        //This block of code will create a back stage view controller and assign every view as its subview.
        //This way, there won`t be any conflict between gesture recognizers or other actions, as well as
        //allowing me to disable user interaction from any view without affecting another.
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        SVBackstageViewController *backStage = [[SVBackstageViewController alloc]init];
        //[currentRootVC presentViewController:backStage animated:NO completion:Nil];
        [currentRootVC willMoveToParentViewController:backStage];
        [myAppDelegate.navigationController pushViewController:backStage animated:NO];
        //[backStage addChildViewController:currentRootVC];
        [currentRootVC didMoveToParentViewController:backStage];
        [backStage.view addSubview:[currentRootVC view]];
        
        SlideoutViewController *slideout = (SlideoutViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SlideoutView"];
        [[slideout view] setTag:1];
        [backStage addChildViewController:slideout];
        [slideout didMoveToParentViewController:currentRootVC];
        [[backStage view] addSubview: [slideout view]];
        [[backStage view] bringSubviewToFront:slideout.view];
        
        
        
        //This block of code will create the frames that will be shown to the user.
        CGRect frame = [[currentRootVC view] frame];
        CGRect rootFrame = [[currentRootVC view] frame];
        
        frame.origin.x = - [[currentRootVC view] frame].size.width;
        [[slideout view] setFrame:frame];
        frame.size.width = 150;
        frame.origin.x = 0;
        rootFrame.origin.x = 150;
        
        slideout.view.layer.masksToBounds = NO;
        slideout.view.layer.shadowColor = [[UIColor blackColor] CGColor];
        slideout.view.layer.shadowRadius = 2.5f;
        slideout.view.layer.shadowOffset = CGSizeMake(0.0f, 2.5f);
        slideout.view.layer.shadowOpacity = 1.0f;
        
        
        //This block animates it.
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [[currentRootVC view] setFrame:rootFrame];
                             [[slideout view] setFrame:frame];
                         }completion:^(BOOL finished){
                             
                         }
         ];
        myAppDelegate.slideoutMenuPresented = YES;
    }
    
}

-(void) closeSlideOut{
    FoilAppDelegate* myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (myAppDelegate.slideoutMenuPresented == YES) {
        id currentRootVC = myAppDelegate.navigationController.visibleViewController;;
        
        for (UIView *subview in [[currentRootVC view] subviews]) {
            if (subview.tag == 1) {
                
                CGRect frame = [subview frame];
                [subview setFrame:frame];
                frame.origin.x = - 150;
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     [subview setFrame:frame];
                                 }completion:^(BOOL finished){
                                     [subview removeFromSuperview];
                                 }
                 ];
                
            }
            if (subview.tag > 1 && subview.tag < 5){
                
                CGRect frame = [subview frame];
                [subview setFrame:frame];
                frame.origin.x = 0;
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     [subview setFrame:frame];
                                 }completion:^(BOOL finished){
                                     //[((UIViewController *)currentRootVC) dismissViewControllerAnimated:NO completion:nil];
                                     [myAppDelegate.navigationController popViewControllerAnimated:NO];
                                     
                                     //NSLog(@"%@", myAppDelegate.navigationController.visibleViewController);
                                 }
                 ];
                
            }
        }
        myAppDelegate.slideoutMenuPresented = NO;
    }
}


@end
