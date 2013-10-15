//
//  RootTabBarViewController.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "RootTabBarViewController.h"

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
    [cell.indicatorTitle addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    Indicator *refIndicator = [currentIndicators objectAtIndex:indexPath.item];
    cell.indicatorTitle.text = refIndicator.title;
    
    [interaction loadIndicatorBaseValue:refIndicator];
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Indicator Value being updated");
        [cell setReferencedIndicator:refIndicator];
    });*/
    [cell setReferencedIndicator:refIndicator];
    [cell.indicatorTitle setFont:[UIFont systemFontOfSize:17.0f]];
    return cell;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)presentTooltip{
    if (CGRectIsEmpty(tooltipOriginalPosition)) {
        tooltipOriginalPosition = toolTipUIView.frame;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:[self view] cache:YES];
    CGRect rect = toolTipUIView.frame;
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
    [toolTipUIView setFrame:newRect];
    [UIView commitAnimations];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [NSThread sleepForTimeInterval:2];
        dispatch_async(dispatch_get_main_queue(),^{
            [self hideTooltip];});
    });
}

-(void)hideTooltip{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    toolTipUIView.alpha = 0;
    [UIView commitAnimations];
    toolTipUIView.alpha = 1;
    [toolTipUIView setFrame:tooltipOriginalPosition];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self tabBar:self.rootTabBar didSelectItem:self.rootTabBar.selectedItem];
    interaction = [Interaction getInstance];
    
    NSArray *sectionsArray = [interaction getIndicatorsSections:YES];
    NSOrderedSet *ordered = [NSOrderedSet orderedSetWithArray:sectionsArray];
    sectionsArray = [ordered sortedArrayUsingComparator:^(id obj1, id obj2){
        return (((IndicatorSection *)obj1).preferredOrder - ((IndicatorSection *)obj2).preferredOrder)%2;
    }];
    
    NSMutableArray *items = [[NSMutableArray alloc]initWithCapacity:[sectionsArray count]];
    
    for (IndicatorSection *section in sectionsArray) {
        UITabBarItem *item = [[UITabBarItem alloc]init];
        item.title = section.title;
        NSString *iconURL, *selectedURL;
        if ([Util GetCurrentDeviceStyle].isRetina) {
            iconURL = section.retinaIconUrl;
            selectedURL = section.retinaSelectedIconUrl;
        }else{
            iconURL = section.regularIconUrl;
            selectedURL = section.regularSelectedIconUrl;
        }
        [Util loadImageFromURL:iconURL imageHash:nil subscriberContext:interaction.currentSubscriberContext finishBlock:^(BasicImageInfo *imageResult){
            item.image = imageResult.Image;
        }];
        if (selectedURL) {
            [Util loadImageFromURL:selectedURL imageHash:nil subscriberContext:interaction.currentSubscriberContext finishBlock:^(BasicImageInfo *imageResult){
                item.selectedImage = imageResult.Image;
            }];
        }
        [items addObject:item];
    }
    self.rootTabBar.items = items;
    self.rootTabBar.selectedItem = items.firstObject;
    [self tabBar:self.rootTabBar didSelectItem:items.firstObject];
}

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

-(void)refreshControlAction{
    NSMutableArray *indicatorsAux = [[NSMutableArray alloc]init];
    NSArray *indexes = self.collectionViewIndicatorsDisplay.indexPathsForVisibleItems;
    for (NSIndexPath *index in indexes) {
        IndicatorDisplayCell *cell = (IndicatorDisplayCell *)[self.collectionViewIndicatorsDisplay cellForItemAtIndexPath:index];
        [indicatorsAux addObject:cell.referencedIndicator];
    }
    [interaction reloadIndicators:indicatorsAux];
    [self.collectionViewIndicatorsDisplay reloadData];
    [refreshControl endRefreshing];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [self.collectionViewIndicatorsDisplay reloadData];
}

-(BOOL)shouldAutorotate{
    return interaction.selectedIndicator != nil;
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
    }
}

-(void)pushView{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    UIStoryboard *b = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    DefaultChartViewController *control = [b instantiateViewControllerWithIdentifier:@"ChartView"];
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
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [((UIViewController *)self.nextResponder) dismissViewControllerAnimated:YES completion:nil];
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
    textView.contentOffset = (CGPoint){.x=0, .y=-topCorret};
}

- (void)highlight:(IndicatorDisplayCell *)cell {
    
    UIColor *backcolor = [UIColor colorWithRed:18.0/255.0 green:146.0/255.0 blue:208.0/255.0 alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor *bottomBarColor = [UIColor colorWithRed:0.0/255.0 green:126.0/255.0 blue:188.0/255.0 alpha:1.0f];
    
    cell.indicatorTitle.backgroundColor = backcolor;
    cell.indicatorTitle.textColor = textColor;
    cell.backgroundColor = backcolor;
    cell.indicatorValueLabel.textColor = textColor;
    cell.bottomBarUIView.backgroundColor = bottomBarColor;
    
    cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (void)unhighlight:(IndicatorDisplayCell *)cell {
    
    UIColor *backcolor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    UIColor *bottomBarColor = [UIColor colorWithRed:189.0/255.0 green:195.0/255.0 blue:199.0/255.0 alpha:1.0f];
    
    cell.indicatorTitle.backgroundColor = backcolor;
    cell.indicatorTitle.textColor = textColor;
    cell.backgroundColor = backcolor;
    cell.indicatorValueLabel.textColor = textColor;
    cell.bottomBarUIView.backgroundColor = bottomBarColor;
    
    cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IndicatorDisplayCell *cell = (IndicatorDisplayCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (interaction.selectedIndicator == cell.referencedIndicator) {
        [self unhighlight:(IndicatorDisplayCell *)[collectionView cellForItemAtIndexPath:indexPath]];
        interaction.selectedIndicator = nil;
        [cell setSelected:NO];
        selectedCell = nil;
    }else{
        [self highlight:cell];
        [interaction loadIndicatorData:cell.referencedIndicator startDate:nil finishDate:nil];
        interaction.selectedIndicator = cell.referencedIndicator;
        [cell setSelected:YES];
        selectedCell = cell;
    }
}
- (IBAction)assistedModeClicked:(id)sender {
    [self presentTooltip];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
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

@end
