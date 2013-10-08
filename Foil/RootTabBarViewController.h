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

@interface RootTabBarViewController : UIViewController<UITabBarDelegate, UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *rootTabBar;

@end
