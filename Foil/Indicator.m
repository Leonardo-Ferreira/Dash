//
//  IndicatorData.m
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "Indicator.h"
#import "IndicatorData.h"

@implementation Indicator{
    NSMutableArray *indicatorData;
}

@synthesize data = indicatorData;
@synthesize title = _title;
@synthesize dataEndRange = _dataEndRange;
@synthesize dataStartRange = _dataStartRange;
@synthesize obtainedOn = _obtainedOn;
@synthesize value = _value;
@synthesize chartType = _chartType;
@synthesize section = _section;
@synthesize internalName = _internalName;
@synthesize valuePrefix = _valuePrefix;
@synthesize valueSufix = _valueSufix;
@synthesize valueType = _valueType;
@synthesize xAxisType = _xAxisType;
@synthesize yAxisType = _yAxisType;

+(Indicator *)mountIndicator:(NSString *)title indicatorValue:(NSString *)value{
    return [[self alloc]initWithInfo:title indicatorValue:value];
}

-(id)initWithInfo:(NSString *)title indicatorValue:(NSString *)value{
    self=[super init];
    _title = title;
    _value = value;
    _obtainedOn = [NSDate date];
    _dataEndRange = nil;
    _dataStartRange = nil;
    indicatorData = nil;
    return self;
}

-(void)dataDidLoad:(IndicatorData *)data{
    if(indicatorData == nil){
        indicatorData = [[NSMutableArray alloc] initWithObjects:data,nil];
    }else{
        [indicatorData addObject:data];
    }
}

-(void)dataDictionaryDidLoad:(NSDictionary *)data{
    [self parseDataDictionary:data];
}

-(id)initWithJsonDictionary:(NSDictionary *)jsonDictionary{
    self = [super init];
    
    _isLoadingData = NO;
    _dataFinishedLoading = NO;
    _dataFinishedLoadingSuccessfully = NO;
    
    _section = [[IndicatorSection alloc]initWithJsonDictionary: [jsonDictionary objectForKey:@"Section"]];
    _title = [jsonDictionary objectForKey:@"IndicatorTitle"];
    _internalName = [jsonDictionary objectForKey:@"InternalName"];
    _chartType = (IndicatorChartType)[[jsonDictionary objectForKey:@"ChartType"] integerValue];
    _valueType = (IndicatorValueType)[[jsonDictionary objectForKey:@"ValueType"] integerValue];
    _xAxisType = (IndicatorValueType)[[jsonDictionary objectForKey:@"XAxisType"] integerValue];
    _yAxisType = (IndicatorValueType)[[jsonDictionary objectForKey:@"YAxisType"] integerValue];
    id aux = [jsonDictionary objectForKey:@"PrefixText"];
    if ([aux class] != [NSNull class]) {
        _valuePrefix = aux;
    }
    aux = [jsonDictionary objectForKey:@"SufixText"];
    if ([aux class] != [NSNull class]) {
        _valueSufix = aux;
    }
    return self;
}

-(BOOL)hasDataForInterval:(NSDate *)startDate endDate:(NSDate *)endDate{
    BOOL result = NO;
    if (!startDate || !endDate) {
        result = (indicatorData != nil) && ([indicatorData count] != 0);
    }else{
            //TODO: finish implementation
    }
    return result;
}

-(void)parseDataDictionary:(NSDictionary *)data{
    if ([[data allKeys]count] == 1) {
        NSDictionary *val1 = [data objectForKey:@""];
        if (val1!=nil){
            NSString *k = [[val1 allKeys] firstObject];
            _value = [val1 objectForKey:k];
        }else{
            indicatorData = [[self parseBigDataDictionary:data] mutableCopy];
        }
    }else{
        indicatorData = [[self parseBigDataDictionary:data] mutableCopy];
    }
}

-(NSArray *)parseBigDataDictionary:(NSDictionary *)dic{
    NSArray *allKeys = [dic allKeys];
    
    NSMutableDictionary *indicatorSeries = [[NSMutableDictionary alloc]init];
    
    for (int index = 0; index < [allKeys count]; index++) {
        NSString *key = [allKeys objectAtIndex:index];
        NSDictionary *subDic = [dic objectForKey:key];
        NSArray *subDicAllKeys = [subDic allKeys];
        for (NSString *title in subDicAllKeys) {
            SerieInformation *info = [[SerieInformation alloc] initWithJsonString:title];
            IndicatorData *serie = [indicatorSeries objectForKey:info.title];
            if (!serie) {
                serie = [[IndicatorData alloc] init];
                serie.serieInfo = info;
                [indicatorSeries setObject:serie forKey:info.title];
            }
            id objectValueToFeed = [subDic objectForKey:title];
            [serie feedObject:key value:objectValueToFeed];
        }
    }
    return [indicatorSeries allValues];
}

-(void)updateValue:(NSString *)value{
    _value = value;
}

-(void)resetData{
    [indicatorData removeAllObjects];
}

-(NSSet *)getIndicatorValuesKeys{
    NSMutableSet *mainSet = [[NSMutableSet alloc]init];
    for (IndicatorData *serie in indicatorData) {
        NSMutableSet *auxSet = [NSMutableSet setWithArray:[serie.indicatorSeriesData allKeys]];
        [mainSet unionSet:auxSet];
    }
    return mainSet;
}














@end
