//
//  SlideoutViewController.m
//  Foil
//
//  Created by AeC on 10/16/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "SlideoutViewController.h"
#import "SlidoutController.h"
#import "EntranceViewController.h"
#import "TutorialViewController.h"
#import "AboutViewController.h"
#import "FoilNavigationController.h"
#import "FoilAppDelegate.h"

@interface SlideoutViewController ()
    @property (nonatomic, strong) NSArray *menuItems;

@end

@implementation SlideoutViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Rear View", nil);

    self.view.backgroundColor = [UIColor colorWithRed:0.0f green:116/255.0 blue:178/255.0 alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.0f green:116/255.0 blue:178/255.0 alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    
    _menuItems = @[@"about", @"tutorial", @"logout"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIView *bgColorView = [[UIView alloc]init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.0 green:96/255.0 blue:158/255.0 alpha:1.0f]];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    FoilAppDelegate *del = (FoilAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (row == 0) {
        AboutViewController *viewController = (AboutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"aboutView"];
        if ([del.navigationController.topViewController isKindOfClass:[AboutViewController class]]) {
            [self closeSlideout];
        }
        else{
            [del.navigationController pushViewController:viewController animated:YES];
            [self closeSlideout];
            //[self presentViewController:viewController animated:YES completion:nil];
            //This could be presented, but sinse it can link the user to the tutorial view, and also has accessto our slideout, we decided to add to the navigation controller.
        }
    }
    
    if (row == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Gostaria de reiniciar o tutorial?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", @"Somente desta página", nil];
        [alert show];
        
    }
    
    if (row == 2) {
        
        [self logOut];
        
        ///////////////TEMPORARIO DELETAR////////////////////////
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        /////////////////////////////////////////////////////////
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    FoilAppDelegate* myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (buttonIndex == 0) {
        return;
    }else if (buttonIndex == 1) {
        
        myAppDelegate.tutorialState = ResetTutorial;
        [myAppDelegate.window makeKeyAndVisible]; // this is important because the UIAlertView runs under its own UIWindow. So whenever I try to close the slideout menu, I cant find it, causing several bugs. By doing that I am forcing my UIWindow back to the top.
        [self logOut];
        
    }else if (buttonIndex == 2){
        [myAppDelegate.window makeKeyAndVisible]; // this is important because the UIAlertView runs under its own UIWindow. So whenever I try to close the slideout menu, I cant find it, causing several bugs. By doing that I am forcing my UIWindow back to the top.
        NSLog(@"%@", [self lastViewController]);
        if ([[self lastViewController] isKindOfClass:[AuthenticationViewController class]]) {
            AuthenticationViewController *viewController = (AuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AuthenticationView"];
            [viewController restartThisPagesTutorialOnly];
        }else if ([[self lastViewController] isKindOfClass:[SubscriberContextSelectionViewController class]]){
            SubscriberContextSelectionViewController *viewController = (SubscriberContextSelectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ContextSelectionView"];
            [viewController restartThisPagesTutorialOnly];
        }
    }
}

-(UIViewController *)lastViewController{
    FoilAppDelegate* myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    if (numberOfViewControllers < 2) {
        return nil;
    }else{
        return [myAppDelegate.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
    }
}

-(void)closeSlideout{
    SlidoutController *controller = [[SlidoutController alloc] init];
    [controller closeSlideOut];
}

-(void)logOut{
    
    [self closeSlideout];
    FoilAppDelegate *del = (FoilAppDelegate *)[UIApplication sharedApplication].delegate;
    NSLog(@"%i", del.navigationController.viewControllers.count);
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    AuthenticationViewController *viewController = (AuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AuthenticationView"];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
    del.navigationController.viewControllers = @[viewController];
    NSLog(@"%i", del.navigationController.viewControllers.count);

}


@end
