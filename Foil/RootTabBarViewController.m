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
    Interaction *interaction;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
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
        [Util getImageFromURLAsync:iconURL imageHash:nil subscriberContext:interaction.currentSubscriberContext finishBlock:^(UIImage *imageResult){
            item.image = imageResult;
        }];
        if (selectedURL) {
            [Util getImageFromURLAsync:selectedURL imageHash:nil subscriberContext:interaction.currentSubscriberContext finishBlock:^(UIImage *imageResult){
                item.selectedImage = imageResult;
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
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
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
        [((UIViewController *)self.nextResponder) dismissViewControllerAnimated:YES completion:nil];
    }
    if([super respondsToSelector:@selector(motionEnded:withEvent:)]){
        [super motionEnded:motion withEvent:event];
    }
}

@end
