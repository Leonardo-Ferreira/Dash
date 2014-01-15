//
//  RootTabBarViewController.h
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Interaction.h"
#import "DefaultChartViewController.h"
#import "IndicatorDisplayCell.h"

@interface RootTabBarViewController : UIViewController<UITabBarDelegate, UITabBarControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UINavigationBarDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *rootTabBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewIndicatorsDisplay;
@property (weak, nonatomic) IBOutlet UILabel *tooltipLabel;
- (IBAction)backButton:(UIBarButtonItem *)sender;
typedef NS_ENUM(NSInteger, TooltipState){
    TooltipClicked,
    TooltipPresented,
    TooltipFading,
    TooltipGone
};

@property (weak, nonatomic) IBOutlet UIView *tutorialBackground;
@property (weak, nonatomic) IBOutlet UIView *sixthTipView;
@property (weak, nonatomic) IBOutlet UILabel *sixthTipText;
@property (weak, nonatomic) IBOutlet UIImageView *sixthTipImage;
@property (weak, nonatomic) IBOutlet UIView *seventhTipView;
@property (weak, nonatomic) IBOutlet UILabel *seventhTipText;
@property (weak, nonatomic) IBOutlet UIImageView *seventhTipImage;
@property (weak, nonatomic) IBOutlet UIView *eighthTipView;
@property (weak, nonatomic) IBOutlet UILabel *eighthTipText;
@property (weak, nonatomic) IBOutlet UIImageView *eighthTipImage;


@end
