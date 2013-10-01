//
//  SubscriberContextSelectionViewController.h
//  Foil
//
//  Created by Leonardo Ferreira on 8/23/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubscriberContextCell.h"
#import "Interaction.h"
#import "SubscriberContext.h"
#import "RootTabBarViewController.h"

@interface SubscriberContextSelectionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *colletionView;

@property (strong, nonatomic, readwrite) NSString *usernameEntered;
@property (strong, nonatomic, readwrite) NSString *passwordEntered;
@end
