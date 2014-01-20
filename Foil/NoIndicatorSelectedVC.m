//
//  NoIndicatorSelectedVC.m
//  Foil
//
//  Created by AeC on 12/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "NoIndicatorSelectedVC.h"
#import "objc/message.h"

@interface NoIndicatorSelectedVC (){
    UIAlertView *alert;
}

@end

@implementation NoIndicatorSelectedVC

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

-(void)alertUser{
    
    alert = [[UIAlertView alloc]initWithTitle:@"Visualização Avançada" message:@"Selecione um indicador e gire seu aparelho para acessar o modo de visualização avançada." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    [self alertUser];
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            [alert dismissWithClickedButtonIndex:0 animated:NO];
            [self pushView];
            break;
            
        default:
            break;
    };
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

- (IBAction)reAlert:(UIButton *)sender {
    [self alertUser];
}
@end
