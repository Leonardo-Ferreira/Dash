//
//  RootTabBarViewController.h
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interaction.h"
#import "DefaultChartViewController.h"
#import "IndicatorDisplayCell.h"

@interface RootTabBarViewController : UIViewController<UITabBarDelegate, UITabBarControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UINavigationBarDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *rootTabBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewIndicatorsDisplay;


@end
