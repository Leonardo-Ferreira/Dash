//
//  FoilViewController.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/25/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AuthenticationViewController.h"
#import "Interaction.h"

@interface EntranceViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *loadingScreenImageView;

@end
