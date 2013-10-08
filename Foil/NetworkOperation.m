//
//  NetworkOperation.m
//  Foil
//
//  Created by Leonardo Ferreira on 10/7/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "NetworkOperation.h"

@implementation NetworkOperation{
    NSUInteger networkActivityCounter;
}

static NetworkOperation *sharedInstance;

-(void)StartOperation{
    if (sharedInstance == nil) {
        sharedInstance = [[NetworkOperation alloc]init];
    }
    [sharedInstance requestConnectivity];
}

-(void)FinishOperation{
    if (sharedInstance == nil) {
        sharedInstance = [[NetworkOperation alloc]init];
    }
    [sharedInstance releaseConnectivity];
}

-(BOOL)requestConnectivity{
    @synchronized(self){
        networkActivityCounter++;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return YES;
}

-(void)releaseConnectivity{
    @synchronized(self){
        if(networkActivityCounter){
            networkActivityCounter--;
        }
        if (!networkActivityCounter) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}
@end
