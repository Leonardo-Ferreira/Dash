//
//  DefaultChartViewController.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "DefaultChartViewController.h"
#import <ShinobiCharts/ShinobiChart.h>

@interface DefaultChartViewController ()<SChartDatasource>
@end

@implementation DefaultChartViewController{
    Indicator *referencedIndicator;
    UILabel *textLabel;
    UIView *modalView;
    UIActivityIndicatorView *wheel;
    NSNumber *maxValueY,*minValueY;
    ShinobiChart *chart;
    NSMutableOrderedSet *orderedKeys;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    referencedIndicator = [Interaction getInstance].selectedIndicator;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    
    if (!referencedIndicator.dataFinishedLoading) {
            //_errorLabel.text = @"Este indicador não possui dados. Para maiores informações contate a sua T.I.";
        
            //Show Loading
        [[self view] insertSubview:modalView atIndex:1000];
        [[self view] insertSubview:wheel atIndex:1001];
        wheel.center = self.view.center;
        [wheel startAnimating];
        
        while(!referencedIndicator.dataFinishedLoading)
        {
            [NSThread sleepForTimeInterval:.1];
        }
        
        [wheel stopAnimating];
        [modalView removeFromSuperview];
        [textLabel removeFromSuperview];
        [wheel removeFromSuperview];
        wheel = nil;
        modalView = nil;
        textLabel = nil;
    }
    
    CGFloat margin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0 : 50.0;
    chart = [[ShinobiChart alloc] initWithFrame:CGRectInset(self.view.bounds, margin, margin)];
    chart.title = referencedIndicator.title;
    chart.licenseKey = @"Wxk+ejvrO/iQH86MjAxMzExMTZpbmZvQHNoaW5vYmljb250cm9scy5jb20=DkfcPmQ4d+jutfumEIzOpsfnEgJjp/2SYZEoTKAxrteGtDA1SiX1oprxJ0Q4ic5B79SAU5UThnW2uUL6oDrGAWx8wJ7wh61bQaEjnEOox2oT84JamUBSeMPKwVdBm7eBb04CKLtvcVAuNWLyVXNLtcJ18OWA=BQxSUisl3BaWf/7myRmmlIjRnMU2cA7q+/03ZX9wdj30RzapYANf51ee3Pi8m2rVW6aD7t6Hi4Qy5vv9xpaQYXF5T7XzsafhzS3hbBokp36BoJZg8IrceBj742nQajYyV7trx5GIw9jy/V6r0bvctKYwTim7Kzq+YPWGMtqtQoU=PFJTQUtleVZhbHVlPjxNb2R1bHVzPnh6YlRrc2dYWWJvQUh5VGR6dkNzQXUrUVAxQnM5b2VrZUxxZVdacnRFbUx3OHZlWStBK3pteXg4NGpJbFkzT2hGdlNYbHZDSjlKVGZQTTF4S2ZweWZBVXBGeXgxRnVBMThOcDNETUxXR1JJbTJ6WXA3a1YyMEdYZGU3RnJyTHZjdGhIbW1BZ21PTTdwMFBsNWlSKzNVMDg5M1N4b2hCZlJ5RHdEeE9vdDNlMD08L01vZHVsdXM+PEV4cG9uZW50PkFRQUI8L0V4cG9uZW50PjwvUlNBS2V5VmFsdWU+";
    chart.autoresizingMask =  ~UIViewAutoresizingNone;
    SChartAxis *xAxis;
    SChartAxis *yAxis;
    
    switch (referencedIndicator.xAxisType) {
        case IndicatorValueTypeDateTime:
            xAxis = [[SChartDateTimeAxis alloc]init];
            break;
        default:
            xAxis = [[SChartNumberAxis alloc]init];
            break;
    }
    switch (referencedIndicator.yAxisType) {
        case IndicatorValueTypeDateTime:
            yAxis = [[SChartDateTimeAxis alloc]init];
            break;
        default:
            yAxis = [[SChartNumberAxis alloc]init];
            break;
    }
    
    
    chart.xAxis = xAxis;
    chart.yAxis = yAxis;
    
    chart.datasource = self;
    [self.view addSubview:chart];
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:    
        case UIDeviceOrientationPortraitUpsideDown:
            
            [self pushView];
            break;
            
        default:
            break;
    };
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)pushView{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)numberOfSeriesInSChart:(ShinobiChart *)chart {
    NSInteger num = [referencedIndicator.data count];
    return num;
}

-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index {
    SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
    
    // the first series is a cosine curve, the second is a sine curve
    lineSeries.title = ((IndicatorData*)[referencedIndicator.data objectAtIndex:index]).serieInfo.title;
    lineSeries.style.lineColor = ((IndicatorData*)[referencedIndicator.data objectAtIndex:index]).serieInfo.color;
    
    return lineSeries;
}

- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    IndicatorData *data = (IndicatorData*)[referencedIndicator.data objectAtIndex:(NSUInteger)seriesIndex];
    NSArray *allKeys = [data.indicatorSeriesData allKeys];
    return [allKeys count];
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex {
    
    SChartDataPoint *datapoint = [[SChartDataPoint alloc] init];
    IndicatorData *refData = [referencedIndicator.data objectAtIndex:(NSUInteger)seriesIndex];
    NSArray *auxKeys = [refData.indicatorSeriesData allKeys];
    if (!orderedKeys) {
        orderedKeys = [[NSMutableOrderedSet alloc]init];
        if (referencedIndicator.xAxisType == IndicatorValueTypeDateTime) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:SS"];
            
            for (NSString *auxKey in auxKeys) {
                NSDate *dateFromString = [[NSDate alloc] init];
                dateFromString = [dateFormatter dateFromString:auxKey];
                [orderedKeys addObject:dateFromString];
            }
        }else if (referencedIndicator.xAxisType == IndicatorValueTypeNumeric || referencedIndicator.xAxisType == IndicatorValueTypeMonetary){
            for (NSString *auxKey in auxKeys) {
                [orderedKeys addObject: [NSNumber numberWithFloat:[auxKey floatValue]]];
            }
        }
        [orderedKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSDate *date1 = (NSDate *)obj1;
            NSDate *date2 = (NSDate *)obj2;
            return [date1 compare:date2];
        }];
    }
    id xValue = [orderedKeys objectAtIndex:dataIndex];
    datapoint.xValue = xValue;
    datapoint.yValue = [refData.indicatorSeriesData objectForKey:[auxKeys objectAtIndex:dataIndex]];
    
    return datapoint;
}

@end
