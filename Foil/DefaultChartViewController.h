//
//  DefaultChartViewController.h
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "Indicator.h"
#import "Interaction.h"

@interface DefaultChartViewController : UIViewController<CPTPlotDataSource,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *renderActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *renderLabel;
@property (weak, nonatomic) IBOutlet UIView *blackoutView;

@end