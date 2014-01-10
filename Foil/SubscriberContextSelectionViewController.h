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
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (strong, nonatomic, readwrite) NSString *usernameEntered;
@property (strong, nonatomic, readwrite) NSString *passwordEntered;

@property (weak, nonatomic) IBOutlet UIView *forthTipView;
@property (weak, nonatomic) IBOutlet UITextView *forthTipText;
@property (weak, nonatomic) IBOutlet UIImageView *forthTipImage;
@property (weak, nonatomic) IBOutlet UIView *fifthTipView;
@property (weak, nonatomic) IBOutlet UITextView *fifthTipText;
@property (weak, nonatomic) IBOutlet UIImageView *fifthTipImage;
-(void) restartThisPagesTutorialOnly;

@end
