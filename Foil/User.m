//
//  User.m
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username;
@synthesize displayName;
@synthesize lastLogin;

-(void)Login:(NSString *)password{
    lastLogin=[NSDate date];
}

-(void)Logout{
    
}

@end
