    //
    //  FoilViewController.m
    //  Foil
    //
    //  Created by Leonardo Ferreira on 7/25/13.
    //  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
    //

#import "EntranceViewController.h"

@interface EntranceViewController ()

@end

@implementation EntranceViewController


-(BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        // Do any additional setup after loading the view, typically from a nib.
    UIImage *img = [UIImage imageNamed:@"LoadingScreen"];
    _loadingScreenImageView.image = img;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.spinner startAnimating];
    [NSThread sleepForTimeInterval:2.0];
        //CHECK IF LOCATION SERVICES IS ON
    
    
    
    Interaction *interaction = [Interaction getInstance];
    if(!interaction.locationAvailible && [interaction shouldAskToEnableLocation]){
            //ASK THE USER TO TURN IT ON
        
    }
    else{
        
    }
    [self doneProcessing];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
                //CLICKED CANCEL
                //DATE MASK "yyyyMMdd hh:mm:ss"
        case 0:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

-(void)doneProcessing{
        //Transition to the Login View
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    AuthenticationViewController *viewController = (AuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AuthenticationView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
