//
//  SerieInformation.h
//  Foil
//
//  Created by Leonardo Ferreira on 9/27/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SerieInformation : NSObject<NSCopying>
@property NSString *title;
@property int zIndex;
@property UIColor *color;

-(id)initWithJsonString:(NSString *)jsonString;
-(NSString *)description;
-(BOOL)isEqual:(id)object;
-(NSUInteger)hash;
@end
