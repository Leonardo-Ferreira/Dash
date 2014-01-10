//
//  FoilAppDelegate.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/25/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoilNavigationController.h"

@interface FoilAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) FoilNavigationController *navigationController;

@property int tutorialPage;// DEPRECATED PLZ DELETE THIS LINE.

//Check to see if the slideout is presented. This is needed because I never know who's my rootviewc, so I need to save this information in a global manner.
@property (nonatomic) BOOL slideoutMenuPresented;

//NOVO TUTORIAL

typedef NS_ENUM(NSInteger, UserInAppLocation){
    AuthenticationView,
    SubscriberContextView,
    RootTabBarView,
    DefaultChartView
};

@property (nonatomic, assign) BOOL reviewThisPagesTutorial;

@property (nonatomic, assign) NSInteger userInAppLocation;

typedef NS_ENUM(NSInteger, TutorialState){
    GroundZero,
    FirstTipPresented,
    SecondTipPresented,
    ThirdTipPresented,
    ForthTipPresented,
    FifthTipPresented,
    SixthTipPresented,
    ResetTutorial,
    DisableTutorial
};

@property (nonatomic, assign) BOOL aboutViewTutorialPresented;

@property (nonatomic, assign) NSInteger tutorialState;

@end
