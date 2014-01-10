//
//  AboutViewController.h
//  Foil
//
//  Created by AeC on 12/3/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
- (IBAction)backButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIView *firstTipView;
@property (weak, nonatomic) IBOutlet UITextView *firstTipText;
@property (weak, nonatomic) IBOutlet UIImageView *firstTipImage;
@property (weak, nonatomic) IBOutlet UIImageView *logotipoDashWhite;


@end
