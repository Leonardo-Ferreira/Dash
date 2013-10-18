//
//  IndicatorData.h
//  Foil
//
//  Created by AeC on 9/11/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndicatorData.h"
#import "Util.h"
#import "SerieInformation.h"
#import "IndicatorSection.h"

@interface Indicator : NSObject

typedef NS_ENUM(NSInteger, IndicatorChartType){
    NoChart = 0,
    PieChart = 1,
    LineChart = 2,
    BarChart = 3
};

typedef NS_ENUM(NSInteger, IndicatorValueType){
    IndicatorValueTypeFree = 0,
    IndicatorValueTypeMonetary = 1,
    IndicatorValueTypePercentage = 2,
    IndicatorValueTypeNumeric = 3,
    IndicatorValueTypeDateTime = 4,
    IndicatorValueTypeDateTimeOffset = 5
};

@property (nonatomic,readonly) IndicatorSection *section;
@property (nonatomic,readonly) NSString *internalName;
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) NSString *valuePrefix;
@property (nonatomic,readonly) NSString *valueSufix;
@property (nonatomic,readonly) NSDate *obtainedOn;
@property (nonatomic,readonly) NSString *value;
@property (nonatomic,readonly) NSArray *data;
@property (nonatomic,readonly) NSDate *dataStartRange;
@property (nonatomic,readonly) NSDate *dataEndRange;
@property (atomic,readwrite) BOOL isLoadingData;
@property (atomic,readwrite) BOOL dataFinishedLoading;
@property (atomic,readwrite) BOOL dataFinishedLoadingSuccessfully;
@property (nonatomic, readonly) IndicatorChartType chartType;
@property (nonatomic, readonly) IndicatorValueType valueType;
@property (nonatomic, readonly) IndicatorValueType xAxisType;
@property (nonatomic, readonly) IndicatorValueType yAxisType;

+(Indicator *)mountIndicator :(NSString *)title indicatorValue:(NSString *)value;
-(void)dataDidLoad:(IndicatorData *)data;
-(void)dataDictionaryDidLoad:(NSDictionary *)data;
-(void)parseDataDictionary:(NSDictionary *)data;
-(id)initWithJsonDictionary:(NSDictionary *)jsonDictionary;
-(BOOL)hasDataForInterval:(NSDate *)startDate endDate:(NSDate *)endDate;
-(NSSet *)getIndicatorValuesKeys;
-(void)resetData;
@end
