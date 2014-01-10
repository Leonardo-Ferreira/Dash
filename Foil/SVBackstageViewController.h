//
//  SVBackstageViewController.h
//  Foil
//
//  Created by AeC on 1/2/14.
//  Copyright (c) 2014 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVBackstageViewController : UIViewController

@end

//This backstage is a temporary view controller that is used to control the Slideout View Controller as its subview, and serves as root controller while the menu is openned. This is done so the interactions on the menu wont enherit from the current view.