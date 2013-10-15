//
//  IndicatorSection.m
//  Foil
//
//  Created by Leonardo Ferreira on 10/4/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "IndicatorSection.h"

@implementation IndicatorSection

@synthesize title = _title;
@synthesize uniqueId = _uniqueId;
@synthesize regularIconUrl = _regularIconUrl;
@synthesize regularIconHash = _regularIconHash;
@synthesize regularSelectedIconUrl = _regularSelectedIconUrl;
@synthesize regularSelectedIconHash = _regularSelectedIconHash;
@synthesize retinaIconUrl = _retinaIconUrl;
@synthesize retinaIconHash = _retinaIconHash;
@synthesize retinaSelectedIconUrl = _retinaSelectedIconUrl;
@synthesize retinaSelectedIconHash = _retinaSelectedIconHash;
@synthesize preferredOrder = _preferredOrder;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDictionary{
    self = [super init];
    
    _title = [jsonDictionary objectForKey:@"Title"];
    _uniqueId = [jsonDictionary objectForKey:@"UniqueId"];
    id auxNSNULL = [jsonDictionary objectForKey:@"RegularIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _regularIconUrl = auxNSNULL;
    }
    auxNSNULL = [jsonDictionary objectForKey:@"RegularIconHash"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _regularIconHash = auxNSNULL;
    }
    
    auxNSNULL = [jsonDictionary objectForKey:@"SelectedRegularIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _regularSelectedIconUrl = auxNSNULL;
    }
    auxNSNULL = [jsonDictionary objectForKey:@"SelectedRegularIconHash"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _regularSelectedIconHash = auxNSNULL;
    }
    
    auxNSNULL = [jsonDictionary objectForKey:@"RetinaIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _retinaIconUrl = auxNSNULL;
    }
    auxNSNULL = [jsonDictionary objectForKey:@"RetinaIconHash"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _retinaIconHash = auxNSNULL;
    }
    
    auxNSNULL = [jsonDictionary objectForKey:@"SelectedRetinaIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _retinaSelectedIconUrl = auxNSNULL;
    }
    auxNSNULL = [jsonDictionary objectForKey:@"SelectedRetinaIconHash"];
    if (auxNSNULL != (NSString *)[NSNull null] && ![auxNSNULL isEqualToString:@"\"\""]) {
        _retinaSelectedIconHash = auxNSNULL;
    }
    
    _preferredOrder = [[jsonDictionary objectForKey:@"PreferredOrder"] integerValue];
    
    return self;
}

-(BOOL)isEqual:(id)object{
    BOOL res=NO;
    if ([object class]==[self class]) {
        res = [((IndicatorSection *)object).uniqueId isEqualToString:self.uniqueId];
    }
    return res;
}

-(NSUInteger)hash{
    return [[NSValue valueWithNonretainedObject:self.uniqueId] hash];
}

@end
