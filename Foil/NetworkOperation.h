//
//  NetworkOperation.h
//  Foil
//
//  Created by Leonardo Ferreira on 10/7/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkOperation : NSObject

-(void)setToken:(NSString*)newToken;
-(NSString *)getToken;
-(void)StartOperation;
-(void)FinishOperation;

+(NetworkOperation *)getInstance;
@end
