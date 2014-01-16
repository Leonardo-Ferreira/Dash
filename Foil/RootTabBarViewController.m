//
//  RootTabBarViewController.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "SlidoutController.h"
#import "FoilAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController{
    FoilAppDelegate *myAppDelegate;
    NSMutableArray *currentIndicators;
    Interaction *interaction;
    dispatch_queue_t concurrentQueue;
    IndicatorDisplayCell *selectedCell;
    UIRefreshControl *refreshControl;
    __weak IBOutlet UIView *toolTipUIView;
    __weak IBOutlet UILabel *toolTipUILabel;
    CGRect tooltipOriginalPosition;
    __weak IBOutlet UIBarButtonItem *assistedModeButton;
    
    BOOL sixthTipStillPresent;
    BOOL tutorialOnProgress;
    
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
    CGRect sixthTipRect = _sixthTipView.frame;
    CGRect newTipRect = CGRectMake(sixthTipRect.origin.x, sixthTipRect.origin.y + rect.size.height, sixthTipRect.size.width, sixthTipRect.size.height);
    
    [UIView animateWithDuration:countInfo animations:^{
        thisTooltip = TooltipFading;
        toolTipUIView.alpha = 0;
    }completion:^(BOOL completed){
        [self presentEighthTip];
        NSLog(@"tooltip is now gone");
        thisTooltip = TooltipGone;
        [_sixthTipView setFrame:newTipRect];
        [toolTipUIView setFrame:newRect];
    }];
}

- (IBAction)assistedModeClicked:(id)sender {
    NSLog(@"%i", thisTooltip);
    if (thisTooltip == TooltipGone && stopTooltip == NO) {  //The stoptooltip is a way to prevent user from
        thisTooltip = TooltipClicked;                       //creating multiple threads, which would cause
        [self presentTooltip];                              //the tooltip to hide before the expected time.
        [self dismissSeventhTip];
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
    NSLog(@"Swipe In working as intended.");
}

-(void)handleSwipeOut:(UISwipeGestureRecognizer*)swipeOut{
    [_collectionViewIndicatorsDisplay setUserInteractionEnabled:YES];
    [self swipeOut];
    NSLog(@"Swipe Out working as intended.");
}

-(void)swipeOut{
    SlidoutController *controller = [[SlidoutController alloc] init];
    [controller closeSlideOut];
    stopTooltip = NO;
}

//---------------------------------------------//

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self restartAction];
    
    [self showUserInterface];
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
    [self presentSixthTip];
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
                [self dismissEighthTip];
                [self pushView];
                break;
            default:
                break;
        };
    }else if(tutorialOnProgress == YES){
        return;
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
        [self dismissSixthTip];
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

////////////////////////////// DANGER TUTORIAL AREA BELOW////////////////////////////////////

-(void)hideUserInterface{
    _tutorialBackground.alpha = 1;
    [self.rootTabBar setUserInteractionEnabled:NO];
    self.collectionViewIndicatorsDisplay.scrollEnabled = NO;
    tutorialOnProgress = YES;
}

-(void)resetAndhideUserInterface{
    [UIView animateWithDuration:0.3 animations:^{
        _tutorialBackground.alpha = 1;
        [[self collectionViewIndicatorsDisplay] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }completion:^(BOOL completed){
        stopTooltip = NO;
        [self.rootTabBar setUserInteractionEnabled:NO];
        self.collectionViewIndicatorsDisplay.scrollEnabled = NO;
        tutorialOnProgress = YES;
    }];
}

-(void)showUserInterface{
    if (tutorialOnProgress == YES) {
        [UIView animateWithDuration:0.3 animations:^{
            _tutorialBackground.alpha = 0;
        }completion:^(BOOL completed){
            tutorialOnProgress = NO;
            self.collectionViewIndicatorsDisplay.scrollEnabled = YES;
            [self.rootTabBar setUserInteractionEnabled:YES];
        }];
    }
}

-(void)presentSixthTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == SixthTipPresented && currentIndicators.count > 0 && sixthTipStillPresent == NO) {
        if (myAppDelegate.reviewThisPagesTutorial == NO) {
            [self hideUserInterface];
        }else{
            [self resetAndhideUserInterface];
        }
        sixthTipStillPresent = YES;
        _sixthTipView.viewForBaselineLayout.layer.cornerRadius = 5;
        _sixthTipView.viewForBaselineLayout.layer.masksToBounds = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _sixthTipView.alpha = 1;
            _sixthTipText.alpha = 1;
        }completion:^(BOOL completed){
            
            [self sixthTipAnimation];
        }];
    }
}

-(void)dismissSixthTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == SixthTipPresented) {
        [UIView animateWithDuration:0.3 animations:^{
            _sixthTipView.alpha = 0;
            _sixthTipText.alpha = 0;
            myAppDelegate.tutorialState = SeventhTipPresented;
        }completion:^(BOOL completed){
            sixthTipStillPresent = NO;
            [self presentSeventhTip];
        }];
        _sixthTipImage.alpha = 0;
        
    }
}

-(void)sixthTipAnimation{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [UIView animateWithDuration:0.75 animations:^{
        _sixthTipImage.alpha = 1;
    }completion:^(BOOL completed){
        [UIView animateWithDuration:0.75 animations:^{
            _sixthTipImage.alpha = 0;
        }completion:^(BOOL completed){
            if (myAppDelegate.tutorialState == SixthTipPresented) {
                [self sixthTipAnimation];
            }
        }];
    }];
}

-(void)presentSeventhTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == SeventhTipPresented) {
        _seventhTipView.viewForBaselineLayout.layer.cornerRadius = 5;
        _seventhTipView.viewForBaselineLayout.layer.masksToBounds = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _seventhTipView.alpha = 1;
            _seventhTipText.alpha = 1;
        }completion:^(BOOL completed){
            [self seventhTipAnimation];
        }];
    }
}

-(void)dismissSeventhTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == SeventhTipPresented) {
        [UIView animateWithDuration:0.3 animations:^{
            _seventhTipView.alpha = 0;
            _seventhTipText.alpha = 0;
            myAppDelegate.tutorialState = EighthTipPresented;
        }completion:^(BOOL completed){
            [self hideTooltip:3];
        }];
        _seventhTipImage.alpha = 0;
        
    }
}

-(void)seventhTipAnimation{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [UIView animateWithDuration:0.75 animations:^{
        _seventhTipImage.alpha = 1;
    }completion:^(BOOL completed){
        [UIView animateWithDuration:0.75 animations:^{
            _seventhTipImage.alpha = 0;
        }completion:^(BOOL completed){
            if (myAppDelegate.tutorialState == SeventhTipPresented) {
                [self seventhTipAnimation];
            }
        }];
    }];
}

-(void)presentEighthTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == EighthTipPresented) {
        _eighthTipView.viewForBaselineLayout.layer.cornerRadius = 5;
        _eighthTipView.viewForBaselineLayout.layer.masksToBounds = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _eighthTipView.alpha = 1;
            _eighthTipText.alpha = 1;
        }completion:^(BOOL completed){
            [self eighthTipAnimation];
        }];
    }
}

-(void)dismissEighthTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == EighthTipPresented) {
        [UIView animateWithDuration:0.3 animations:^{
            _eighthTipView.alpha = 0;
            _eighthTipText.alpha = 0;
            myAppDelegate.reviewThisPagesTutorial = NO;
            myAppDelegate.tutorialState = DisableTutorial;
        }completion:^(BOOL completed){
            
        }];
        _eighthTipImage.alpha = 0;
        
    }
}

-(void)eighthTipAnimation{
    NSLog(@"Tip image center location start: X=%f Y=%f",_eighthTipImage.center.x,_eighthTipImage.center.y);
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:_eighthTipImage];
    
    [UIView animateWithDuration:0.3 animations:^{
        _eighthTipImage.alpha = 1;
    }completion:^(BOOL completed){
        /*[UIView animateWithDuration:1.75 animations:^{
            CGAffineTransform t1 = CGAffineTransformMakeRotation(-M_PI/2);
            CGFloat moveX = _eighthTipImage.bounds.size.height - _eighthTipImage.bounds.size.width;
            CGAffineTransform t2 = CGAffineTransformMakeTranslation(moveX, moveX*-1);
            CGAffineTransform t = CGAffineTransformMake(t1.a, t1.b, t1.c, t1.d, t2.tx, t2.ty);
            _eighthTipImage.transform = t;
        }completion:^(BOOL completed){
            [UIView animateWithDuration:0.75 animations:^{
                _eighthTipImage.alpha = 0;
                //[NSThread sleepForTimeInterval:1];
            }completion:^(BOOL completed){
                [UIView animateWithDuration:0.01 animations:^{
                    NSLog(@"Tip image center location finish: X=%f Y=%f",_eighthTipImage.center.x,_eighthTipImage.center.y);
                    _eighthTipImage.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    if (myAppDelegate.tutorialState == EighthTipPresented) {
                        [self eighthTipAnimation];
                    }
                }];
            }];
        }];*/
    }];
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view{
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);

    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

-(void) restartThisPagesTutorialOnly{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    myAppDelegate.reviewThisPagesTutorial = YES;
    [self swipeOut];
}

-(void) restartAction{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.reviewThisPagesTutorial == YES) {
        [self disableTutorial];
        myAppDelegate.tutorialState = SixthTipPresented;
        [self presentSixthTip];
    }
    return;
}

-(void) disableTutorial{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    _sixthTipView.alpha = 0;
    _sixthTipText.alpha = 0;
    _sixthTipImage.alpha = 0;
    _seventhTipView.alpha = 0;
    _seventhTipText.alpha = 0;
    _seventhTipImage.alpha = 0;
    _eighthTipView.alpha = 0;
    _eighthTipText.alpha = 0;
    _eighthTipImage.alpha = 0;
    _tutorialBackground.alpha = 0;
    sixthTipStillPresent = NO;
    if (myAppDelegate.reviewThisPagesTutorial == NO) {
        myAppDelegate.tutorialState = DisableTutorial;
    }
}

@end













