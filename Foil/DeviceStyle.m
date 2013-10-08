//
//  DeviceStyle.m
//  Foil
//
//  Created by Leonardo Ferreira on 9/2/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "DeviceStyle.h"

@implementation DeviceStyle
@synthesize height = _height;
@synthesize width = _width;
@synthesize isFlatDesigned = _isFlatDesigned;
@synthesize isRetina = _isRetina;

-(id)initWithFormattedString:(NSString *)formattedString{
    self = [super init];
    
    NSString *auxValue = [formattedString substringToIndex:[formattedString rangeOfString:@"x"].location];
    NSString *auxString = [formattedString stringByReplacingOccurrencesOfString:auxValue withString:@""];
    auxString = [auxString stringByReplacingOccurrencesOfString:@"x" withString:@""];
    _height = [auxValue integerValue];
    
    auxValue = [auxString substringToIndex:[auxString rangeOfString:@":"].location];
    auxString = [formattedString stringByReplacingOccurrencesOfString:auxValue withString:@""];
    auxString = [auxString stringByReplacingOccurrencesOfString:@":" withString:@""];
    _width = [auxValue integerValue];
    
    auxValue = [NSString stringWithFormat:@"%c", [auxString characterAtIndex:0]];
    _isRetina = [auxValue boolValue];
    
    auxValue = [NSString stringWithFormat:@"%c", [auxString characterAtIndex:1]];
    _isFlatDesigned = [auxValue boolValue];
    
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%dx%d:%d%d",_width,_height,[[NSNumber numberWithBool:_isRetina]intValue], [[NSNumber numberWithBool:_isFlatDesigned]intValue]];
}

-(id)init{
    self = [super init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _height = screenRect.size.height;
    _width = screenRect.size.width;
    _isRetina = [[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0);
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    _isFlatDesigned = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedDescending);
    
    return self;
}

@end
