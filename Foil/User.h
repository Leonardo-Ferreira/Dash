//
//  User.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSDate *lastLogin;

-(void)Login:(NSString *)password;
-(void)Logout;
@end
