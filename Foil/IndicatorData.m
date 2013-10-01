//
//  IndicatorData.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "IndicatorData.h"

@implementation IndicatorData{
        //KEY: Data key, like a Date
        //VALUE: Data value, like R$ 400
    NSMutableDictionary *_indicatorSeriesData;
}

@synthesize serieInfo=_serieInfo;
@synthesize indicatorSeriesData = _indicatorSeriesData;
@synthesize loaded = _loaded;

-(id)init{
    self=[super init];
    _indicatorSeriesData=[[NSMutableDictionary alloc]init];
    return self;
}

-(void)feedObject:(NSString *)key value:(id)value{
    if (![_indicatorSeriesData objectForKey:key]) {
        [_indicatorSeriesData setValue:value forKey:key];
    }
}

@end
