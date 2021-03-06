//
//  DefaultChartViewController.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "DefaultChartViewController.h"
#import <ShinobiCharts/ShinobiChart.h>
#import <ShinobiGrids/ShinobiDataGrid.h>
#import "objc/message.h"

@interface DefaultChartViewController ()<SChartDatasource,SDataGridDataSource>
@end

@implementation DefaultChartViewController{
    Indicator *referencedIndicator;
    UILabel *textLabel;
    UIView *modalView;
    UIActivityIndicatorView *wheel;
    NSNumber *maxValueY,*minValueY;
    ShinobiChart *chart;
    ShinobiDataGrid* dataGrid;
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

- (void)setupDataGrid{
    dataGrid = [[ShinobiDataGrid alloc] initWithFrame:CGRectInset(self.view.bounds, 40,40)];
    //dataGrid.licenseKey = [[Interaction getInstance] getShinobiKey];
    NSString *auxk = [[Interaction getInstance] getShinobiKey];
    dataGrid.licenseKey = auxk;
    SDataGridColumn *defaultColumn = [[SDataGridColumn alloc] initWithTitle:@"Data"];
    [dataGrid addColumn:defaultColumn];
    
    NSArray *auxData = referencedIndicator.data;
    for (IndicatorData *dataSerie in auxData) {
        SDataGridColumn *column = [[SDataGridColumn alloc] initWithTitle:dataSerie.serieInfo.title];
        [dataGrid addColumn:column];
    }
    
    [self.view addSubview:dataGrid];
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (void)setupChart {
    CGFloat margin = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10.0 : 50.0;
    chart = [[ShinobiChart alloc] initWithFrame:CGRectInset(self.view.bounds, margin, margin)];
    chart.title = referencedIndicator.title;
    NSString *auxk = [[Interaction getInstance] getShinobiKey];
    chart.licenseKey = auxk;
    chart.autoresizingMask =  ~UIViewAutoresizingNone;
    SChartAxis *xAxis;
    SChartAxis *yAxis;
    
    switch (referencedIndicator.xAxisType) {
        case IndicatorValueTypeDateTime:
            xAxis = [[SChartDateTimeAxis alloc]init];
            xAxis.title = @"Data";
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
            //yAxis.title = referencedIndicator.title;
            yAxis.rangePaddingLow = @(0.1);
            yAxis.rangePaddingHigh = @(0.1);
            break;
    }
    
    yAxis.enableGesturePanning = YES;
    yAxis.enableGestureZooming = YES;
    xAxis.enableGesturePanning = YES;
    xAxis.enableGestureZooming = YES;
    
    chart.xAxis = xAxis;
    chart.yAxis = yAxis;
    
    chart.datasource = self;
    [self.view addSubview:chart];
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
    if (referencedIndicator.chartType == IndicatorChartNone) {
        
    }
    [self setupChart];
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
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), UIInterfaceOrientationPortrait);
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

- (NSInteger)numberOfItemsInSection:(NSInteger)seriesIndex {
    IndicatorData *data = (IndicatorData*)[referencedIndicator.data objectAtIndex:(NSUInteger)seriesIndex];
    NSArray *allKeys = [data.indicatorSeriesData allKeys];
    return [allKeys count];
}

- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    return [self numberOfItemsInSection:seriesIndex];
}

-(NSUInteger)shinobiDataGrid:(ShinobiDataGrid *)grid numberOfRowsInSection:(int)sectionIndex
{
    return [self numberOfItemsInSection:sectionIndex];
}

- (void)shinobiDataGrid:(ShinobiDataGrid *)grid prepareCellForDisplay:(SDataGridCell *)cell
{
    SDataGridTextCell* textCell = (SDataGridTextCell*)cell;

    IndicatorData *auxData = ((IndicatorData *)referencedIndicator.data[cell.coordinate.column.displayIndex]);
    
    NSArray *auxKeysArray = [auxData.indicatorSeriesData allKeys];
    
    if (cell.coordinate.column.displayIndex == 0)
    {
        textCell.textField.text = auxKeysArray[cell.coordinate.row.rowIndex];
    }
    else
    {
        textCell.textField.text = [auxData.indicatorSeriesData valueForKey:auxKeysArray[cell.coordinate.row.rowIndex]];
    }
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
                if (!dateFromString) {
                    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:SS"];
                    dateFromString = [dateFormatter dateFromString:auxKey];
                }
                [orderedKeys addObject:dateFromString];
            }
        }else if (referencedIndicator.xAxisType == IndicatorValueTypeNumeric || referencedIndicator.xAxisType == IndicatorValueTypeMonetary){
            for (NSString *auxKey in auxKeys) {
                [orderedKeys addObject: [NSNumber numberWithFloat:[auxKey floatValue]]];
            }
        }
        else{
            [orderedKeys addObjectsFromArray:auxKeys];
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
