//
//  IndicatorDisplayCell.m
//  Foil
//
//  Created by AeC on 9/18/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "IndicatorDisplayCell.h"

@implementation IndicatorDisplayCell

@synthesize indicatorTitle;
@synthesize indicatorValueLabel;
@synthesize referencedIndicator = _referencedIndicator;
@synthesize activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //indicatorValueLabel.hidden = YES;
    }
    return self;
}

-(void)setReferencedIndicator:(Indicator *)referencedIndicator{
    _referencedIndicator=referencedIndicator;
    while (referencedIndicator.isLoadingData) {
        //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        [NSThread sleepForTimeInterval:.1];
    }
    if (referencedIndicator.dataFinishedLoadingSuccessfully) {
        indicatorValueLabel.text = referencedIndicator.value;
        [activityIndicator stopAnimating];
        indicatorValueLabel.hidden = NO;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
