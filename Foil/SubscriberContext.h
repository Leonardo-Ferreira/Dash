//
//  SubscriberContext.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/29/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubscriberContextExtension.h"
#import "Reachability.h"


@interface SubscriberContext : NSObject

@property (nonatomic,readonly) NSString *UniqueId;
@property (nonatomic,readonly) NSString *ContextName;
@property (nonatomic,readonly) NSString *ContextDomain;
@property (nonatomic) NSString *ContextDisplayTitle;

@property (nonatomic) NSString *ThumbImageUrl;
@property (nonatomic,readonly) NSString *ThumbImageHash;

@property (nonatomic,readonly) NSString *ExternalBaseURL;
@property (nonatomic,readonly) NSString *InternalBaseURL;

    //@property (nonatomic,readonly) NSString *welcomeMessage;

-(id)initWithContext:(NSString *)contextId :(NSString *)subscriberName :(NSString *)subscriberFullScreenImageHash :(NSString *)subscriberIconHash :(NSString *)subscriberLoadingImageHash :(NSString *)webRootUrl :(NSString *)internalRootUrl :(NSString *) welcomeMessage;
-(NSString *)rootURLForCurrentSubscriberContext;
-(id)initWithJsonDictionary:(NSDictionary *)json;

/*
string InternalBaseURL { get; }
string ExternalBaseURL { get; }
string ContextName { get; }
string ContextDomain { get; }
string ContextDisplayTitle { get; }
string ThumbImageUrl { get; }
string ThumbImageHash { get; }
*/

@end
