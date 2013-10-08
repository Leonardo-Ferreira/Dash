//
//  IndicatorDisplayViewController.m
//  Foil
//
//  Created by AeC on 9/18/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "IndicatorDisplayViewController.h"

@interface IndicatorDisplayViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>


@end

@implementation IndicatorDisplayViewController
{
    NSMutableArray *currentIndicators;
    dispatch_queue_t concurrentQueue;
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
    concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    Interaction *interaction = [Interaction getInstance];
    if (!interaction.availibleIndicatorsDiscovered) {
        
    }
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for (Indicator *item in interaction.availibleIndicators) {
        if ([item.section.title caseInsensitiveCompare:self.tabBarItem.title] == NSOrderedSame) {
            [items addObject:item];
        }
    }
    currentIndicators = items;
    return [items count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"Cell for item at indexpath");
    IndicatorDisplayCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"IndicatorBox" forIndexPath:indexPath];
    [cell.indicatorTitle addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    Indicator *refIndicator = [currentIndicators objectAtIndex:indexPath.item];
    cell.indicatorTitle.text = refIndicator.title;
    
    Interaction *interaction = [Interaction getInstance];
    [interaction loadIndicatorBaseValue:refIndicator];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Indicator Value being updated");
        [cell setReferencedIndicator:refIndicator];
    });
    [cell.indicatorTitle setFont:[UIFont systemFontOfSize:17.0f]];
    return cell;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
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
    
    UIColor *backcolor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    cell.indicatorTitle.backgroundColor = backcolor;
    cell.indicatorTitle.textColor = textColor;
    cell.backgroundColor = backcolor;
    cell.indicatorValueLabel.textColor = textColor;
    
    cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (void)unhighlight:(IndicatorDisplayCell *)cell {
    
    UIColor *backcolor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    
    cell.indicatorTitle.backgroundColor = backcolor;
    cell.indicatorTitle.textColor = textColor;
    cell.backgroundColor = backcolor;
    cell.indicatorValueLabel.textColor = textColor;
    
    cell.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Interaction *interaction = [Interaction getInstance];
    IndicatorDisplayCell *cell = (IndicatorDisplayCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self highlight:cell];

    [interaction loadIndicatorData:cell.referencedIndicator startDate:nil finishDate:nil];
    interaction.selectedIndicator = cell.referencedIndicator;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self unhighlight:(IndicatorDisplayCell *)[collectionView cellForItemAtIndexPath:indexPath]];
}

@end


























