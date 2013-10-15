//
//  IndicatorSection.h
//  Foil
//
//  Created by Leonardo Ferreira on 10/4/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndicatorSection : NSObject

@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) NSString *uniqueId;
@property (nonatomic,readonly) NSString *regularIconUrl;
@property (nonatomic,readonly) NSString *regularIconHash;
@property (nonatomic,readonly) NSString *regularSelectedIconUrl;
@property (nonatomic,readonly) NSString *regularSelectedIconHash;
@property (nonatomic,readonly) NSString *retinaIconUrl;
@property (nonatomic,readonly) NSString *retinaIconHash;
@property (nonatomic,readonly) NSString *retinaSelectedIconUrl;
@property (nonatomic,readonly) NSString *retinaSelectedIconHash;
@property (nonatomic,readonly) NSInteger preferredOrder;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDictionary;
-(BOOL)isEqual:(id)object;
-(NSUInteger)hash;

@end
