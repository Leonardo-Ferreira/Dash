//
//  SubscriberContextSelectionViewController.m
//  Foil
//
//  Created by Leonardo Ferreira on 8/23/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "SubscriberContextSelectionViewController.h"

@interface SubscriberContextSelectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>

@end

@implementation SubscriberContextSelectionViewController{
    NSSet *contexts;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"Number of itens in section");
    Interaction *interact = [Interaction getInstance];
    
    if (!interact.contextsLoadingCompleted) {
        NSLog(@"contexts not loaded yet. Will wait for loading to complete.");
        while (!interact.contextsLoadingCompleted) {
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    }
    else{
        NSLog(@"Contexts already loaded.");
    }
    contexts = interact.allContextsForCurrentUser;
    [self.loadingView removeFromSuperview];
    return contexts.count;
    //return 3;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"View did appear");
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
        [((UIViewController *)self.nextResponder) dismissViewControllerAnimated:YES completion:nil];
    }
    if([super respondsToSelector:@selector(motionEnded:withEvent:)]){
        [super motionEnded:motion withEvent:event];
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Cell for item at indexpath");
    SubscriberContextCell *cell = [self.colletionView dequeueReusableCellWithReuseIdentifier:@"subscriberContext" forIndexPath:indexPath];
    NSArray *aux = [contexts allObjects];
    
    SubscriberContext *auxContext = [[SubscriberContext alloc]initWithJsonDictionary:[aux objectAtIndex:indexPath.item]];//(SubscriberContext *)[aux objectAtIndex:indexPath.item];
    cell.referenceContext = auxContext;
    [cell setThumbnailImage:auxContext.ThumbImageUrl imageHash:auxContext.ThumbImageHash];
    
    [cell setTitle:auxContext.ContextDisplayTitle];
    
    cell.viewForBaselineLayout.layer.cornerRadius = 5;
    cell.viewForBaselineLayout.layer.masksToBounds = YES;
    
    /*if (indexPath.item == [aux count]-1) {
        self.loadingView.hidden = YES;
    }*/
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
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
    
    Interaction *interact = [Interaction getInstance];
    if ([interact validateUser:usernameEntered password:passwordEntered againstContext: ((SubscriberContextCell*)[self.colletionView cellForItemAtIndexPath:indexPath]).referenceContext]) {
        [interact discoverIndicators];
        [auxLabel setText:@"Sincronizando Itens"];
        while (!interact.availibleIndicatorsDiscovered) {
            [NSThread sleepForTimeInterval:1];
        }
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            //RootTabBarViewController *ctr = [board instantiateViewControllerWithIdentifier:@"RootTabBarView"];
        RootTabBarViewController *ctr = [board instantiateViewControllerWithIdentifier:@"DynamicRootTabBarView"];
        
        [self presentViewController:ctr animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Autenticação" message:@"As credenciais fornecidas não foram validadas pelo contexto selecionado" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Trocar Usuário", nil];
        [alert show];
    }
    [wheel stopAnimating];
    [modalView removeFromSuperview];
    [auxLabel removeFromSuperview];
    [wheel removeFromSuperview];
    wheel = nil;
    modalView = nil;
    auxLabel = nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex > 0) {
        exit(0);
    }
}

@end
