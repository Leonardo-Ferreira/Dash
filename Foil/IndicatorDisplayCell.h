//
//  IndicatorDisplayCell.h
//  Foil
//
//  Created by AeC on 9/18/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Indicator.h"

@interface IndicatorDisplayCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITextView *indicatorTitle;
@property (nonatomic, retain) UIView *selectedBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *indicatorValueLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readonly) Indicator *referencedIndicator;

-(void)setReferencedIndicator:(Indicator *)referencedIndicator;
@end
