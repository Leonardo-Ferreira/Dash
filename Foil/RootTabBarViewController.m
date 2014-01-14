//
//  RootTabBarViewController.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "SlidoutController.h"

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController{
    NSMutableArray *currentIndicators;
    Interaction *interaction;
    dispatch_queue_t concurrentQueue;
    IndicatorDisplayCell *selectedCell;
    UIRefreshControl *refreshControl;
    __weak IBOutlet UIView *toolTipUIView;
    __weak IBOutlet UILabel *toolTipUILabel;
    CGRect tooltipOriginalPosition;
    __weak IBOutlet UIBarButtonItem *assistedModeButton;
    
    TooltipState thisTooltip;
    BOOL stopTooltip;
    
    NSString *lastKnowSelectedTabBarItem;
    NSThread *tooltipThread;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.rootTabBar.selectedItem != nil){
        if (!interaction.availibleIndicatorsDiscovered) {
            
        }
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (Indicator *item in interaction.availibleIndicators) {
            if ([item.section.title caseInsensitiveCompare:self.rootTabBar.selectedItem.title] == NSOrderedSame) {
                [items addObject:item];
            }
        }
        currentIndicators = items;
    }
    return [currentIndicators count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IndicatorDisplayCell *cell = [self.collectionViewIndicatorsDisplay dequeueReusableCellWithReuseIdentifier:@"IndicatorBox" forIndexPath:indexPath];
    if(!cell.indicatorTitle.observationInfo){
        [cell.indicatorTitle addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
        [cell.indicatorTitle setFont:[UIFont systemFontOfSize:17.0f]];
    }
    
    Indicator *refIndicator = [currentIndicators objectAtIndex:indexPath.item];
    cell.indicatorTitle.text = refIndicator.title;
    
    [interaction loadIndicatorBaseValue:&refIndicator];
    
    [cell setReferencedIndicator:refIndicator];
    
    if (refIndicator == interaction.selectedIndicator) {
        [self highlight:cell];
    }
    else{
        [cell setHighlighted:NO];
        [cell setSelected:NO];
        [self unhighlight:cell];
    }
    return cell;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

////////////////////////// TOOLTIP CONTROLLER ///////////////////////////////

-(void)presentTooltip{
    toolTipUIView.alpha = 1;
    toolTipUIView.viewForBaselineLayout.layer.cornerRadius = 5;
    toolTipUIView.viewForBaselineLayout.layer.masksToBounds = YES;
    if (interaction.selectedIndicator != nil) {
        self.tooltipLabel.text = interaction.selectedIndicator.quickToolTip;
    }else{
        self.tooltipLabel.text = @"Selecione um indicador.";
    }
    
    if (CGRectIsEmpty(tooltipOriginalPosition)) {
        tooltipOriginalPosition = toolTipUIView.frame;
    }
    CGRect rect = toolTipUIView.frame;
    NSLog(@"originx %f, originy %f", rect.origin.x, rect.origin.y);
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
    
    [UIView transitionWithView:toolTipUIView duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        [toolTipUIView setFrame:newRect];
    } completion:^(BOOL completed){
        thisTooltip = TooltipPresented;
        [self restartTooltipFadeOut];
    }];
    
}

-(void)restartTooltipFadeOut{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        int tooltipDurationInSec = 5;
        
        tooltipThread = [NSThread currentThread];
        for (int i = 0; i < tooltipDurationInSec; i++) {
            [NSThread sleepForTimeInterval:1];
            if (stopTooltip == YES) {
                NSLog(@"the tooltip was cancelled");
                stopTooltip = NO;
                break;
            }
            if (thisTooltip == TooltipPresented) {
                if (i == tooltipDurationInSec - 1) {
                    dispatch_async(dispatch_get_main_queue(),^{
                            [self hideTooltip:2];
                    });
                }
            }
        }
    });
}


-(void)hideTooltip:(float)countInfo{
    CGRect rect = toolTipUIView.frame;
    CGRect newRect = CGRectMake(rect.origin.x, self.view.frame.size.height - 49, rect.size.width, rect.size.height);
    
    [UIView animateWithDuration:countInfo animations:^{
        thisTooltip = TooltipFading;
        toolTipUIView.alpha = 0;
    }completion:^(BOOL completed){
        NSLog(@"tooltip is now gone");
        thisTooltip = TooltipGone;
        [toolTipUIView setFrame:newRect];
    }];
}

- (IBAction)assistedModeClicked:(id)sender {
    NSLog(@"%i", thisTooltip);
    if (thisTooltip == TooltipGone && stopTooltip == NO) {  //The stoptooltip is a way to prevent user from
        thisTooltip = TooltipClicked;                       //creating multiple threads, which would cause
        [self presentTooltip];                              //the tooltip to hide before the expected time.
    }
    if (thisTooltip == TooltipFading) {
        NSLog(@"waiting for tooltip to fade");
    }
    if (thisTooltip == TooltipPresented) {
        stopTooltip = YES;
        [self hideTooltip:1];
    }
}

////////////////////////// ------------------- ///////////////////////////////


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self tabBar:self.rootTabBar didSelectItem:self.rootTabBar.selectedItem];
    
    //SWIPE GESTURE FOR SLIDE OUT MENU
    UISwipeGestureRecognizer *openSlideout = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeIn:)];
    openSlideout.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *closeSlideout = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeOut:)];
    closeSlideout.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:openSlideout];
    [self.view addGestureRecognizer:closeSlideout];
    
    //---------------------------------
    
    interaction = [Interaction getInstance];
    
    while (!interaction.availibleIndicatorsDiscovered) {
        [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    if (!interaction.availibleIndicatorsDiscoverySucceeded) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ops! Não era pra ser assim!"
                                                        message:@"Algo aconteceu e não foi possivel carregar os indicadores. Tente novamente mais tarde."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self removeFromParentViewController];
        return;
    }
    
    NSArray *sectionsArray = [interaction getIndicatorsSections:YES];
    NSOrderedSet *ordered = [NSOrderedSet orderedSetWithArray:sectionsArray];
    sectionsArray = [ordered sortedArrayUsingComparator:^(id obj1, id obj2){
        return (((IndicatorSection *)obj1).preferredOrder - ((IndicatorSection *)obj2).preferredOrder)%2;
    }];
    
    NSMutableArray *items = [[NSMutableArray alloc]initWithCapacity:[sectionsArray count]];
    
    for (IndicatorSection *section in sectionsArray) {
        UITabBarItem *item = [[UITabBarItem alloc]init];
        item.title = section.title;
        NSString *iconURL, *selectedURL, *iconHash, *selectedHash;
        if ([Util GetCurrentDeviceStyle].isRetina) {
            iconURL = section.retinaIconUrl;
            iconHash = section.retinaIconHash;
            selectedURL = section.retinaSelectedIconUrl;
            selectedHash = section.retinaSelectedIconHash;
        }else{
            iconURL = section.regularIconUrl;
            iconHash = section.regularIconHash;
            selectedURL = section.regularSelectedIconUrl;
            selectedHash = section.regularSelectedIconHash;
        }
        [Util loadImageFromURL:iconURL imageHash:iconHash subscriberContext:interaction.currentSubscriberContext finishBlock:^(BasicImageInfo *imageResult){
            dispatch_sync(dispatch_get_main_queue(), ^{
                item.image = imageResult.Image;
            });
        }];
        if (selectedURL) {
            [Util loadImageFromURL:selectedURL imageHash:selectedHash subscriberContext:interaction.currentSubscriberContext finishBlock:^(BasicImageInfo *imageResult){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    item.selectedImage = imageResult.Image;
                });
            }];
        }
        [items addObject:item];
    }
    thisTooltip = TooltipGone;
    self.rootTabBar.items = items;
    self.rootTabBar.selectedItem = items.firstObject;
    [self tabBar:self.rootTabBar didSelectItem:items.firstObject];
}

//SWIPE GESTURES METHODS FOR THE SLIDE OUT MENU

-(void)handleSwipeIn:(UISwipeGestureRecognizer*)swipeIn{
    SlidoutController *controller = [[SlidoutController alloc] init];
    [controller openSlideOut];
    stopTooltip = YES;
    [self hideTooltip:0];
    [_collectionViewIndicatorsDisplay setUserInteractionEnabled:NO];
    NSLog(@"Swipe In working as intended.");
}

-(void)handleSwipeOut:(UISwipeGestureRecognizer*)swipeOut{
    stopTooltip = NO;
    [_collectionViewIndicatorsDisplay setUserInteractionEnabled:YES];
    [self swipeOut];
    NSLog(@"Swipe Out working as intended.");
}

-(void)swipeOut{
    SlidoutController *controller = [[SlidoutController alloc] init];
    [controller closeSlideOut];
}

//---------------------------------------------//

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    [self becomeFirstResponder];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
    [self.collectionViewIndicatorsDisplay addSubview:refreshControl];
    self.collectionViewIndicatorsDisplay.alwaysBounceVertical = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [refreshControl removeFromSuperview];
}

-(void)refreshControlAction{
    NSLog(@"Refresh started.");
    NSString *selectedIndicatorTitle;
    if (selectedCell) {
        selectedIndicatorTitle = selectedCell.referencedIndicator.title;
        [self unhighlight:selectedCell];
    }
    NSMutableArray *indicatorsAux = [[NSMutableArray alloc]init];
    NSArray *indexes = self.collectionViewIndicatorsDisplay.indexPathsForVisibleItems;
    for (NSIndexPath *index in indexes) {
        IndicatorDisplayCell *cell = (IndicatorDisplayCell *)[self.collectionViewIndicatorsDisplay cellForItemAtIndexPath:index];
        [indicatorsAux addObject:cell.referencedIndicator.title];
    }
    [interaction reloadAllIndicators];
    [self.collectionViewIndicatorsDisplay reloadData];
    /*if (selectedIndicatorTitle) {
        for (NSIndexPath *index in self.collectionViewIndicatorsDisplay) {
            IndicatorDisplayCell *cell = (IndicatorDisplayCell *)[self.collectionViewIndicatorsDisplay cellForItemAtIndexPath:index];
            if ([cell.referencedIndicator.title isEqualToString:selectedIndicatorTitle]) {
                [self highlight:cell];
                break;
            }
        }
    }*/
    [refreshControl endRefreshing];
    NSLog(@"Refresh Concluded");
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (lastKnowSelectedTabBarItem == nil || [lastKnowSelectedTabBarItem compare:item.title] != NSOrderedSame) {
        if (selectedCell) {
            [self collectionView:self.collectionViewIndicatorsDisplay didSelectItemAtIndexPath:[self.collectionViewIndicatorsDisplay indexPathForCell:selectedCell]];
        }
        [self.collectionViewIndicatorsDisplay reloadData];
        lastKnowSelectedTabBarItem = item.title;
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (void) orientationChanged:(NSNotification *)note
{
    if (interaction.selectedIndicator != nil) {
        UIDevice * device = note.object;
        switch(device.orientation)
        {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                [self pushView];
                break;
            default:
                break;
        };
    }else{
        UIDevice * device = note.object;
        switch(device.orientation)
        {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                [self pushTipView];
                break;
            default:
                break;
        };
    }
}

-(void)pushView{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    UIStoryboard *b = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    DefaultChartViewController *control = [b instantiateViewControllerWithIdentifier:@"ChartView"];
    
    //THIS time we are using present, instead of push, because not only do we not need this viewcontroller to be
    //in our navigation controller, but we also need both presented view and dismissed view to keep track of its
    //orientation, and presenting automatically do that job for us.
    [self presentViewController:control animated:YES completion:nil];
}

-(void)pushTipView{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    UIStoryboard *b = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    DefaultChartViewController *control = [b instantiateViewControllerWithIdentifier:@"NoIndicatorSelected"];
    
    //THIS time we are using present, instead of push, because not only do we not need this viewcontroller to be
    //in our navigation controller, but we also need both presented view and dismissed view to keep track of its
    //orientation, and presenting automatically do that job for us.
    [self presentViewController:control animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.subtype  == UIEventSubtypeMotionShake) {
        if ([self isKindOfClass:[UIViewController class]]) {
            [self goBack];
        }else{
            [((UIViewController *)self.nextResponder).navigationController popViewControllerAnimated:YES];
        }
    }
    if([super respondsToSelector:@selector(motionEnded:withEvent:)]){
        [super motionEnded:motion withEvent:event];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    UITextView *textView = object;
    
    CGFloat topCorret = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0;
    topCorret = (topCorret <0.0 ?0.0:topCorret);
    //textView.contentOffSet = (CGPoint){.x=0, .y=-topCorret};
    [textView setContentInset:UIEdgeInsetsMake(topCorret, 0, 0, 0)];
}

- (void)highlight:(IndicatorDisplayCell *)cell {
    NSLog(@"Highlighting cell of indicator '%@'",cell.referencedIndicator.title);
    UIColor *backcolor = [UIColor colorWithRed:18.0/255.0 green:146.0/255.0 blue:208.0/255.0 alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor *bottomBarColor = [UIColor colorWithRed:0.0f green:126.0f/255.0f blue:188.0f/255.0f alpha:1.0f];
    
    cell.indicatorTitle.backgroundColor = backcolor;
    cell.indicatorTitle.textColor = textColor;
    cell.backgroundColor = backcolor;
    cell.indicatorValueLabel.textColor = textColor;
    cell.bottomBarUIView.backgroundColor = bottomBarColor;
    
    cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (void)unhighlight:(IndicatorDisplayCell *)cell {
    NSLog(@"Unhighlighting cell of indicator '%@'",cell.referencedIndicator.title);
    UIColor *backcolor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    UIColor *valueTextColor = [UIColor colorWithRed:18.0f/256.0f green:147.0f/256.0f blue:209.0f/256.0f alpha:1.0f];
    UIColor *bottomBarColor = [UIColor colorWithRed:189.0/255.0 green:195.0/255.0 blue:199.0/255.0 alpha:1.0f];
    
    cell.indicatorTitle.backgroundColor = backcolor;
    cell.indicatorTitle.textColor = textColor;
    cell.backgroundColor = backcolor;
    cell.indicatorValueLabel.textColor = valueTextColor;
    cell.bottomBarUIView.backgroundColor = bottomBarColor;
    
    cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IndicatorDisplayCell *cell = (IndicatorDisplayCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (interaction.selectedIndicator == cell.referencedIndicator) {
        [self unhighlight:cell];
        interaction.selectedIndicator = nil;
        [cell setSelected:NO];
        [cell setHighlighted:NO];
        selectedCell = nil;
    }else{
        [self highlight:cell];
        [interaction loadIndicatorData:cell.referencedIndicator startDate:nil finishDate:nil];
        interaction.selectedIndicator = cell.referencedIndicator;
        [cell setSelected:YES];
        [cell setHighlighted:YES];
        if (selectedCell) {
            [self unhighlight:selectedCell];
        }
        selectedCell = cell;
    }
}


- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    [self unhighlight:selectedCell];
    interaction.selectedIndicator = nil;
    [selectedCell setSelected:NO];
    selectedCell = nil;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    //BOOL res = interaction.selectedIndicator == ((IndicatorDisplayCell *)[collectionView cellForItemAtIndexPath:indexPath]).referencedIndicator;
    return YES;
}

- (IBAction)backButton:(UIBarButtonItem *)sender {
    [self goBack];
}
@end
