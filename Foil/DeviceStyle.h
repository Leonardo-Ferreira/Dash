//
//  DeviceStyle.h
//  Foil
//
//  Created by Leonardo Ferreira on 9/2/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceStyle : NSObject

@property(nonatomic, readonly) NSInteger height;
@property(nonatomic, readonly) NSInteger width;
@property(nonatomic, readonly) bool isRetina;
@property(nonatomic, readonly) bool isFlatDesigned;

-(id)initWithFormattedString:(NSString *) formattedString;

@end
