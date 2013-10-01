//
//  IdentityServices.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Util.h"
#import "SubscriberContext.h"

@interface IdentityServices : NSObject<NSXMLParserDelegate>
@property (nonatomic) NSString *validateAgainstURL;
@property (atomic,readonly) BOOL validationDone;
@property (atomic,readonly) BOOL userValidated;
-(void)validateCredentialsAsync:(NSString *)userName password:(NSString *)password;
-(User *)getUserIdentity:(NSString *) userName;
@end
