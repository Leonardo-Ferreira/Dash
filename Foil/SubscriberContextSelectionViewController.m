//
//  SubscriberContextSelectionViewController.m
//  Foil
//
//  Created by Leonardo Ferreira on 8/23/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "SubscriberContextSelectionViewController.h"
#import "SlidoutController.h"
#import "Reachability.h"
#import "AuthenticationViewController.h"
#import "FoilAppDelegate.h"

@interface SubscriberContextSelectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate,UINavigationBarDelegate>

@end

@implementation SubscriberContextSelectionViewController{
    NSSet *contexts;
    BOOL viewAlreadyAppeared;
    FoilAppDelegate *myAppDelegate;
    BOOL forthTipAnimationSide;
    BOOL forthTipDisplayed;
    NSInteger lastContentOffset;
    NSIndexPath *collectionViewIndexPath;
    UIAlertView *tutorialAlertView;
}

@synthesize usernameEntered;
@synthesize passwordEntered;

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
    viewAlreadyAppeared = NO;
    
    UISwipeGestureRecognizer *openSlideout = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeIn:)];
    openSlideout.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *closeSlideout = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeOut:)];
    closeSlideout.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:openSlideout];
    [self.view addGestureRecognizer:closeSlideout];
    
    
    //Change the back Button design to fit both iOS 7 and earlier versions.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [_backButton setTintColor: [UIColor whiteColor]];
    }
}

-(void)handleSwipeIn:(UISwipeGestureRecognizer*)swipeIn{
    [_colletionView setUserInteractionEnabled:NO];
    SlidoutController *controller = [[SlidoutController alloc] init];
    [controller openSlideOut];
}

-(void)handleSwipeOut:(UISwipeGestureRecognizer*)swipeOut{
    [_colletionView setUserInteractionEnabled:YES];
    [self swipeOut];
}

-(void)swipeOut{
    SlidoutController *controller = [[SlidoutController alloc] init];
    [controller closeSlideOut];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if (viewAlreadyAppeared) {
        NSLog(@"Number of itens in section");
        Interaction *interact = [Interaction getInstance];
        
        if (!interact.contextsLoadingCompleted) {
            NSLog(@"contexts not loaded yet. Will wait for loading to complete.");
            while (!interact.contextsLoadingCompleted) {
                int count = 20;
                NetworkStatus internetStatus = [reachability currentReachabilityStatus];
                if (internetStatus == NotReachable) {
                    NSLog(@"Internet connection not available. Will try %d more times",count);
                    [NSThread sleepForTimeInterval:.5];
                    [self connectionLost];
                    [self logoutUser];
                    count--;
                    if (count == 0) {
                        break;
                    }
                }
                [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
            }
        }
        else{
            NSLog(@"Contexts already loaded.");
        }
        contexts = interact.allContextsForCurrentUser;
        return contexts.count;
    }else{
        return 0;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self restartAction];
    NSLog(@"View did appear");
    viewAlreadyAppeared = YES;
    [self becomeFirstResponder];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.colletionView reloadData];});
        //[self.loadingView removeFromSuperview];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:_loadingView duration:.1 options:UIViewAnimationOptionTransitionNone animations:^{
                _loadingView.alpha = 0;} completion:NULL];
        });
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (IBAction)backButtonClick:(UIBarButtonItem *)sender {
    [self swipeOut];
    [self goBack];
}

- (void)goBack {
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    myAppDelegate.reviewThisPagesTutorial = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.subtype  == UIEventSubtypeMotionShake) {
        [self goBack];
    }
    if([super respondsToSelector:@selector(motionEnded:withEvent:)]){
        [super motionEnded:motion withEvent:event];
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SubscriberContextCell *cell = [self.colletionView dequeueReusableCellWithReuseIdentifier:@"subscriberContext" forIndexPath:indexPath];
    NSArray *aux = [contexts allObjects];
    
    SubscriberContext *auxContext = [[SubscriberContext alloc]initWithJsonDictionary:[aux objectAtIndex:indexPath.item]];//(SubscriberContext *)[aux objectAtIndex:indexPath.item];
    cell.referenceContext = auxContext;
    [cell setThumbnailImage:auxContext.ThumbImageUrl imageHash:auxContext.ThumbImageHash];
    
    [cell setTitle:auxContext.ContextDisplayTitle];
    
    cell.viewForBaselineLayout.layer.cornerRadius = 5;
    cell.viewForBaselineLayout.layer.masksToBounds = YES;
    
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate]; //needed to access the tutorialstate for the procedure below.
    [self presentForthTip];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissFifthTip];
    collectionViewIndexPath = indexPath;
    if (myAppDelegate.tutorialState == ForthTipPresented) {
        [self userGaveUpFollowingTheTutorial];
    }else{
        [self didSelectContextAction];
    }
    
}

-(void)didSelectContextAction{
    [self performSelectorInBackground:@selector(dismissAlertView:) withObject:tutorialAlertView];
    
    UIView *modalView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    modalView.backgroundColor = [UIColor blackColor];
    modalView.alpha = 0.8f;
    UILabel *auxLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    auxLabel.backgroundColor = [UIColor clearColor];
    auxLabel.text = @"Contactando Contexto";
    auxLabel.textColor = [UIColor whiteColor];
    auxLabel.center = CGPointMake(modalView.center.x, modalView.center.y-40);
    auxLabel.textAlignment = NSTextAlignmentCenter;
    [modalView insertSubview:auxLabel atIndex:10];
    
    UIActivityIndicatorView *wheel = [[UIActivityIndicatorView alloc]init];
    wheel.hidesWhenStopped = YES;
    
    [[self view] insertSubview:modalView atIndex:1000];
    [[self view] insertSubview:wheel atIndex:1001];
    wheel.center = self.view.center;
    [wheel startAnimating];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        [self connectionLost];
    }else{
        Interaction *interact = [Interaction getInstance];
        if ([interact validateUser:usernameEntered password:passwordEntered againstContext: ((SubscriberContextCell*)[self.colletionView cellForItemAtIndexPath:collectionViewIndexPath]).referenceContext]) {
            [interact discoverIndicators];
            [auxLabel setText:@"Sincronizando Itens"];
            while (!interact.availibleIndicatorsDiscovered) {
                [NSThread sleepForTimeInterval:1];
            }
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            //RootTabBarViewController *ctr = [board instantiateViewControllerWithIdentifier:@"RootTabBarView"];
            RootTabBarViewController *ctr = [board instantiateViewControllerWithIdentifier:@"DynamicRootTabBarView"];
            
            [self.navigationController pushViewController:ctr animated:YES];
            //[self presentViewController:ctr animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Autenticação" message:@"As credenciais fornecidas não foram validadas pelo contexto selecionado." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Trocar Usuário", nil];
            [alert show];
        }
    }
    [wheel stopAnimating];
    [modalView removeFromSuperview];
    [auxLabel removeFromSuperview];
    [wheel removeFromSuperview];
    wheel = nil;
    modalView = nil;
    auxLabel = nil;
}

-(void)connectionLost{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Conexão de Rede" message:@"Não foi possível estabelecer uma conexão de rede. Certifique-se de que os \"Dados Celulares\", \"3G\", ou \"WiFi\" estão ativados, que a conexão com sua operadora de rede está funcionando e tente mais tarde." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    myAppDelegate = (FoilAppDelegate *)[UIApplication sharedApplication].delegate;
    if (alertView.tag == 1) {
        if (buttonIndex ==1) {
            [myAppDelegate.window makeKeyAndVisible];
            [self disableTutorial];
            myAppDelegate.reviewThisPagesTutorial = NO;
            [self didSelectContextAction];
        }else if(buttonIndex == 2){
            myAppDelegate.reviewThisPagesTutorial = NO;
            [self disableTutorial];
            myAppDelegate.tutorialState = SixthTipPresented;
            [self didSelectContextAction];
        }
        return;
    }
    if (buttonIndex > 0) {
        [self logoutUser];
    }
}

-(void)logoutUser{
    myAppDelegate = (FoilAppDelegate *)[UIApplication sharedApplication].delegate;
    NSLog(@"%i", myAppDelegate.navigationController.viewControllers.count);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    AuthenticationViewController *viewController = (AuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AuthenticationView"];
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    myAppDelegate.navigationController.viewControllers = @[viewController];
    NSLog(@"%i", myAppDelegate.navigationController.viewControllers.count);
}

////////////////////////////// DANGER TUTORIAL AREA BELOW////////////////////////////////////

-(void)presentForthTip{
    if (myAppDelegate.tutorialState == ForthTipPresented && contexts.count > 1 && forthTipDisplayed == NO) {
        forthTipDisplayed = YES;
        myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
        _forthTipView.viewForBaselineLayout.layer.cornerRadius = 5;
        _forthTipView.viewForBaselineLayout.layer.masksToBounds = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _forthTipView.alpha = 1;
            _forthTipText.alpha = 1;
        }completion:^(BOOL completed){
            [self forthTipAnimation];
        }];
    }else if(myAppDelegate.tutorialState == ForthTipPresented && contexts.count == 1){
        myAppDelegate.tutorialState = FifthTipPresented;
        [self presentFifthTip];
    }
}

-(void)forthTipAnimation{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect rect = _forthTipImage.frame;
    CGRect newRect = CGRectMake(80, rect.origin.y, rect.size.width, rect.size.height);
    CGRect resetRect = CGRectMake(200, rect.origin.y, rect.size.width, rect.size.height);
    
    [UIView animateWithDuration:1.5 animations:^{
        _forthTipImage.alpha = 1;
        [_forthTipImage setFrame:newRect];
    }completion:^(BOOL completed){
        
        [UIView animateWithDuration:0.3 animations:^{
            _forthTipImage.alpha = 0;
        }completion:^(BOOL completed){
            [_forthTipImage setFrame:resetRect];
            if (myAppDelegate.tutorialState == ForthTipPresented && forthTipAnimationSide == NO) {
                [self forthTipAnimation];
            }else if (myAppDelegate.tutorialState == ForthTipPresented && forthTipAnimationSide == YES) {
                [self forthTipAnimationTwo];
            }
        }];
    }];
}

-(void)forthTipAnimationTwo{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect rect = _forthTipImage.frame;
    CGRect newRect = CGRectMake(200, rect.origin.y, rect.size.width, rect.size.height);
    CGRect resetRect = CGRectMake(80, rect.origin.y, rect.size.width, rect.size.height);
    [_forthTipImage setFrame:resetRect];
    
    [UIView animateWithDuration:1.5 animations:^{
        _forthTipImage.alpha = 1;
        [_forthTipImage setFrame:newRect];
    }completion:^(BOOL completed){
        
        [UIView animateWithDuration:0.3 animations:^{
            _forthTipImage.alpha = 0;
        }completion:^(BOOL completed){
            [_forthTipImage setFrame:resetRect];
            if (myAppDelegate.tutorialState == ForthTipPresented && forthTipAnimationSide == YES) {
                [self forthTipAnimationTwo];
            }
        }];
    }];
}

-(void)dismissForthTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == ForthTipPresented) {
        myAppDelegate.tutorialState = FifthTipPresented;
        [UIView animateWithDuration:0.3 animations:^{
            _forthTipView.alpha = 0;
            _forthTipText.alpha = 0;
        }completion:^(BOOL completed){
            [self presentFifthTip];
        }];
        _forthTipImage.alpha = 0;
    }
}

-(void)presentFifthTip{
    if (myAppDelegate.tutorialState == FifthTipPresented) {
        forthTipDisplayed = YES;
        myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
        _fifthTipView.viewForBaselineLayout.layer.cornerRadius = 5;
        _fifthTipView.viewForBaselineLayout.layer.masksToBounds = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _fifthTipView.alpha = 1;
            _fifthTipText.alpha = 1;
        }completion:^(BOOL completed){
            [self fifthTipAnimation];
        }];
    }
}

-(void)dismissFifthTip{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (myAppDelegate.tutorialState == FifthTipPresented) {
        if (myAppDelegate.reviewThisPagesTutorial == YES) {
            myAppDelegate.tutorialState = DisableTutorial;
            myAppDelegate.reviewThisPagesTutorial = NO;
        }else{
            myAppDelegate.tutorialState = SixthTipPresented;
        }
        [UIView animateWithDuration:0.3 animations:^{
            _fifthTipView.alpha = 0;
            _fifthTipText.alpha = 0;
        }completion:^(BOOL completed){
            
        }];
        _fifthTipImage.alpha = 0;
    }
}

-(void)fifthTipAnimation{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [UIView animateWithDuration:0.75 animations:^{
        _fifthTipImage.alpha = 1;
    }completion:^(BOOL completed){
        [UIView animateWithDuration:0.75 animations:^{
            _fifthTipImage.alpha = 0;
        }completion:^(BOOL completed){
            if (myAppDelegate.tutorialState == FifthTipPresented) {
                [self fifthTipAnimation];
            }
        }];
    }];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (forthTipAnimationSide == NO){
        forthTipAnimationSide = YES;
    }
    return;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (lastContentOffset > scrollView.contentOffset.x){
        //direction == left
        [self dismissForthTip];
    }else if (lastContentOffset < scrollView.contentOffset.x){
        //direction == right
    }
    lastContentOffset = scrollView.contentOffset.x;
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
        myAppDelegate.tutorialState = ForthTipPresented;
        [self presentForthTip];
    }
    return;
}

-(void) disableTutorial{
    myAppDelegate = (FoilAppDelegate*)[[UIApplication sharedApplication] delegate];
    _forthTipView.alpha = 0;
    _forthTipText.alpha = 0;
    _forthTipImage.alpha = 0;
    _fifthTipView.alpha = 0;
    _fifthTipText.alpha = 0;
    _fifthTipImage.alpha = 0;
    forthTipDisplayed = NO;
    if (myAppDelegate.reviewThisPagesTutorial == NO) {
        myAppDelegate.tutorialState = DisableTutorial;
    }
}

-(void)userGaveUpFollowingTheTutorial{
    NSString *text = @"Gostaria de encerrar o tutorial e continuar a navegação?";
    NSString *thisViewOnly = @"Somente desta tela";
    if (myAppDelegate.reviewThisPagesTutorial == YES) {
        thisViewOnly = nil;
    }
    tutorialAlertView = [[UIAlertView alloc] initWithTitle:nil message:text delegate:self cancelButtonTitle:@"Ainda não" otherButtonTitles:@"Sim", thisViewOnly, nil];
    [tutorialAlertView setTag:1];
    [tutorialAlertView show];
}

-(void)dismissAlertView:(UIAlertView *) alert{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
