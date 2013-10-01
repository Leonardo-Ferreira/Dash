//
//  DeviceStyle.m
//  Foil
//
//  Created by Leonardo Ferreira on 9/2/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "DeviceStyle.h"

@implementation DeviceStyle
@synthesize Height;
@synthesize Width;
@synthesize IsFlatDesigned;
@synthesize IsRetina;

-(id)initWithFormattedString:(NSString *)formattedString{
    self = [super init];
    
    NSString *auxValue = [formattedString substringToIndex:[formattedString rangeOfString:@"x"].location];
    NSString *auxString = [formattedString stringByReplacingOccurrencesOfString:auxValue withString:@""];
    auxString = [auxString stringByReplacingOccurrencesOfString:@"x" withString:@""];
    self.Height = [auxValue integerValue];
    
    auxValue = [auxString substringToIndex:[auxString rangeOfString:@":"].location];
    auxString = [formattedString stringByReplacingOccurrencesOfString:auxValue withString:@""];
    auxString = [auxString stringByReplacingOccurrencesOfString:@":" withString:@""];
    self.Width = [auxValue integerValue];
    
    auxValue = [NSString stringWithFormat:@"%c", [auxString characterAtIndex:0]];
    self.IsRetina = [auxValue boolValue];
    
    auxValue = [NSString stringWithFormat:@"%c", [auxString characterAtIndex:1]];
    self.IsFlatDesigned = [auxValue boolValue];
    
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%dx%d:%d%d",self.Width,self.Height,[[NSNumber numberWithBool:self.IsRetina]intValue], [[NSNumber numberWithBool:self.IsFlatDesigned]intValue]];
}
@end
