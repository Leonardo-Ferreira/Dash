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
    _referencedIndicator = referencedIndicator;
    indicatorValueLabel.text = @"";
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    while (referencedIndicator.isLoadingData) {
        //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        [NSThread sleepForTimeInterval:.1];
    }
    if (referencedIndicator.dataFinishedLoadingSuccessfully) {
        NSString *finalVal = referencedIndicator.value;
        if (referencedIndicator.valueType == IndicatorValueTypeMonetary) {
            float auxVal = [referencedIndicator.value floatValue];
            int ref = 1;
            while ((auxVal/10) > 1) {
                auxVal = auxVal/10;
                ref++;
            }
            if (ref>3) {
                finalVal = [NSString stringWithFormat:@"%.02f",auxVal];
            }
            switch (ref) {
                case 4:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em milhares)"];
                    break;
                case 5:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em dezenas de milhares)"];
                    break;
                case 6:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em centenas de milhares)"];
                    break;
                case 7:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em milhões)"];
                    break;
                case 8:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em dezenas de milhões)"];
                    break;
                case 9:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em centenas de milhões)"];
                    break;
                case 10:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em bilhões)"];
                    break;
                case 11:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em dezenas de bilhões)"];
                    break;
                case 12:
                    indicatorTitle.text = [indicatorTitle.text stringByAppendingString:@" (em centenas de bilhões)"];
                    break;
                default:
                    break;
            }
        }
        indicatorValueLabel.text = [[NSString stringWithFormat:@"%@ %@ %@",referencedIndicator.valuePrefix,finalVal,referencedIndicator.valueSufix] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
