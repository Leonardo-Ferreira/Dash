//
//  IndicatorData.h
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerieInformation.h"

@interface IndicatorData : NSObject

@property (nonatomic,readwrite) SerieInformation *serieInfo;
@property (nonatomic,readonly) NSDictionary *indicatorSeriesData;
@property (nonatomic,readonly) BOOL loaded;

-(void)feedObject:(NSString *)key value:(id)value;
@end
