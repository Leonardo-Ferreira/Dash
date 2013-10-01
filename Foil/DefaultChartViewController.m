//
//  DefaultChartViewController.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "DefaultChartViewController.h"

@interface DefaultChartViewController ()

@end

@implementation DefaultChartViewController{
    CPTGraphHostingView *hostView;
    CPTTheme *selectedTheme;
    Indicator *referencedIndicator;
    UILabel *textLabel;
    UIView *modalView;
    UIActivityIndicatorView *wheel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)renderChart{
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)loadingChartView{
    modalView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    modalView.backgroundColor = [UIColor blackColor];
    modalView.alpha = 0.8f;
    textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width, 40)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = @"Carregando Informações";
    textLabel.textColor = [UIColor whiteColor];
    textLabel.center = CGPointMake(modalView.center.x,modalView.center.y-40);
    textLabel.textAlignment = NSTextAlignmentCenter;
    [modalView insertSubview:textLabel atIndex:10];
    
    wheel = [[UIActivityIndicatorView alloc]init];
    wheel.hidesWhenStopped = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    referencedIndicator = [Interaction getInstance].selectedIndicator;
}

-(void)configurePlots{
    CPTGraph *graph = hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    NSMutableArray *plots = [[NSMutableArray alloc]init];
    
    for (IndicatorData *item in referencedIndicator.data) {
        CPTScatterPlot *p = [[CPTScatterPlot alloc]init];
        p.dataSource = self;
        
        CPTMutableLineStyle *style = [p.dataLineStyle mutableCopy];
            //CPTColor *color = [[CPTColor alloc] initWithComponentRed:CPTFloat([Util randomInt:0 upperBound:100]/100) green:CPTFloat([Util randomInt:0 upperBound:100]/100) blue:CPTFloat([Util randomInt:0 upperBound:100]/100) alpha:CPTFloat(1.0)];
        CPTColor *color = [CPTColor colorWithCGColor:[item.serieInfo.color CGColor]];

        style.lineColor = color;
        p.dataLineStyle = style;
        
        CPTPlotSymbol *symbol = [CPTPlotSymbol ellipsePlotSymbol];
        symbol.fill = [CPTFill fillWithColor:color];
        symbol.size = CGSizeMake(6.0f, 6.0f);
        p.plotSymbol = symbol;
        
        p.identifier = item.serieInfo.title;
        
        [graph addPlot:p toPlotSpace:plotSpace];
        [plots addObject:p];
    }
    
    [plotSpace scaleToFitPlots:plots];

}

-(void)configureAxes{
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 2.0f;
    //CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;
    
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Data";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:[referencedIndicator.data count]];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:[referencedIndicator.data count]];
    NSInteger i = 0;
    for (NSString *item in [referencedIndicator getIndicatorValuesKeys]) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc]initWithText:[item substringToIndex:10] textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if(label){
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
}

-(void)configureHost{
    hostView = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    hostView.allowPinchScaling = YES;
    hostView.allowPinchScaling = NO;
    [self.view addSubview:hostView];
}

-(void)configureGraph{
    CPTGraph *graph = [[CPTXYGraph alloc]initWithFrame:hostView.bounds];
    //[graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    hostView.hostedGraph = graph;
    //graph.paddingLeft = 0.0f;
    //graph.paddingTop = 0.0f;
    //graph.paddingRight = 0.0f;
    //graph.paddingBottom = 0.0f;
    //graph.axisSet = nil;
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;
    
    NSString *title = referencedIndicator.title;
    graph.title = title;
    graph.titleTextStyle = textStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
    
    selectedTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:selectedTheme];
    
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    [self renderChart];
    if (!referencedIndicator.dataFinishedLoading) {
            //_errorLabel.text = @"Este indicador não possui dados. Para maiores informações contate a sua T.I.";
        
            //Show Loading
        [[self view] insertSubview:modalView atIndex:1000];
        [[self view] insertSubview:wheel atIndex:1001];
        wheel.center = self.view.center;
        [wheel startAnimating];
        
        while(!referencedIndicator.dataFinishedLoading)
        {
            [NSThread sleepForTimeInterval:1];
        }
        
        [wheel stopAnimating];
        [modalView removeFromSuperview];
        [textLabel removeFromSuperview];
        [wheel removeFromSuperview];
        wheel = nil;
        modalView = nil;
        textLabel = nil;
    }
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

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    NSUInteger res = [referencedIndicator.data count];
    return res;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
    
    NSNumber *result = [NSDecimalNumber zero];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            result = [NSNumber numberWithUnsignedInt:idx];
            break;
        case CPTScatterPlotFieldY:
            for (IndicatorData *subItem in referencedIndicator.data) {
                if([subItem.serieInfo.title isEqualToString:(NSString *)plot.identifier] == YES){
                    id auxKey = [[subItem.indicatorSeriesData allKeys] objectAtIndex:idx];
                    id val = [subItem.indicatorSeriesData objectForKey: auxKey];
                    float fValue = [((NSString *)val) floatValue];
                    result = [NSNumber numberWithFloat: fValue/10000];
                }
            }
            break;
        default:
            break;
    }
    return result;
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

@end
