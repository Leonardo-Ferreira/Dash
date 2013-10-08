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
@synthesize regularSelectedIconUrl = _regularSelectedIconUrl;
@synthesize retinaIconUrl = _retinaIconUrl;
@synthesize retinaSelectedIconUrl = _retinaSelectedIconUrl;
@synthesize preferredOrder = _preferredOrder;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDictionary{
    self = [super init];
    
    /*string Title { get; set; }
     string RegularIconUrl { get; set; }
     string SelectedRegularIconUrl { get; set; }
     string RetinaIconUrl { get; set; }
     string SelectedRetinaIconUrl { get; set; }
     int PreferredOrder { get; set; }*/
    
    _title = [jsonDictionary objectForKey:@"Title"];
    _uniqueId = [jsonDictionary objectForKey:@"UniqueId"];
    id auxNSNULL = [jsonDictionary objectForKey:@"RegularIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null]) {
        _regularIconUrl = auxNSNULL;
    }
    auxNSNULL = [jsonDictionary objectForKey:@"SelectedRegularIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null]) {
        _regularSelectedIconUrl = auxNSNULL;
    }
    auxNSNULL = [jsonDictionary objectForKey:@"RetinaIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null]) {
        _retinaIconUrl = auxNSNULL;
    }
    auxNSNULL = [jsonDictionary objectForKey:@"SelectedRetinaIconUrl"];
    if (auxNSNULL != (NSString *)[NSNull null]) {
        _retinaSelectedIconUrl = auxNSNULL;
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
