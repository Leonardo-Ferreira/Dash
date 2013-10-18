//
//  SerieInformation.m
//  Foil
//
//  Created by Leonardo Ferreira on 9/27/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "SerieInformation.h"

@implementation SerieInformation
@synthesize color;
@synthesize zIndex;
@synthesize title;

-(id)initWithJsonString:(NSString *)jsonString{
    self = [super init];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *aux = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSString *auxColor = [aux objectForKey:@"ARGBColor"];
    NSArray *array = [auxColor componentsSeparatedByString:@","];
    if ([array count]==4) {
        self.color = [[UIColor alloc]initWithRed:[[array objectAtIndex:1] floatValue] green:[[array objectAtIndex:2] floatValue] blue:[[array objectAtIndex:3] floatValue] alpha:[[array objectAtIndex:0] floatValue]];
    }else{
        self.color = [[UIColor alloc]initWithRed:[[array objectAtIndex:0] floatValue]/255 green:[[array objectAtIndex:1] floatValue]/255 blue:[[array objectAtIndex:2] floatValue]/255 alpha:1];
    }
    
    self.title = [aux objectForKey:@"SeriesTitle"];
    self.zIndex = [[aux objectForKey:@"ZIndex"] integerValue];
    return self;
}

-(NSString *)description{
    CGFloat red=0,green=0,blue=0,alpha=0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
        //"\"SeriesTitle\":\"Serie 1\",\"ZIndex\":0,\"ARGBColor\":\"255,255,255,255\""
        //NSString *result = [NSString stringWithFormat:@"\"SeriesTitle\":\"%@\",\"ZIndex\":%d,\"ARGBColor\":\"%.0f,%.0f,%.0f,%.0f\"",title,zIndex,alpha*255,red*255,green*255,blue*255];
        //NSLog(@"Description is '%@'", result);
    NSString *result = title;
    return result;
}

-(id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setColor: [self.color copyWithZone:zone]];
        [copy setZIndex: self.zIndex];
        [copy setTitle: [self.title copyWithZone:zone]];
    }
    
    return copy;
}

-(BOOL)isEqual:(id)object{
    BOOL res = NO;
    if ([object class] == [self class]) {
        res = [((SerieInformation *)object).title isEqualToString:self.title];
    }
    return res;
}

-(NSUInteger)hash{
    return [[NSValue valueWithNonretainedObject:[self description]] hash];
}



@end
