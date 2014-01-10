//
//  TooltipController.m
//  Foil
//
//  Created by AeC on 12/20/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "TooltipController.h"

@implementation TooltipController{
    __weak IBOutlet UIView *toolTipUIView;
}

-(void) presentTooltip2:(UIViewController *) viewController{
    
    [[viewController view] addSubview: toolTipUIView];
    
    //This block of code will create the frames that will be shown to the user.
    
    toolTipUIView.alpha = 1;
    toolTipUIView.viewForBaselineLayout.layer.cornerRadius = 5;
    toolTipUIView.viewForBaselineLayout.layer.masksToBounds = YES;
    
    CGRect rect = toolTipUIView.frame;
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [toolTipUIView setFrame:newRect];
                     }completion:^(BOOL finished){
                         
                     }
     ];
}

@end
