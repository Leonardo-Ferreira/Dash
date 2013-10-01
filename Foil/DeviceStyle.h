//
//  DeviceStyle.h
//  Foil
//
//  Created by Leonardo Ferreira on 9/2/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceStyle : NSObject

@property(nonatomic) NSInteger Height;
@property(nonatomic) NSInteger Width;
@property(nonatomic) bool IsRetina;
@property(nonatomic) bool IsFlatDesigned;

-(id)initWithFormattedString:(NSString *) formattedString;

@end
