//
//  MediaCache.h
//  Foil
//
//  Created by Leonardo Ferreira on 10/6/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicImageInfo.h"
#import "SubscriberContext.h"

@interface MediaCache : NSObject
+(BasicImageInfo *)cachedImageForURL:(NSString *)imageUrl imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context;
+(void)cacheImage:(BasicImageInfo *)imageInfo imageContext:(SubscriberContext *)context;
+(void)cleanCache;

-(void)cacheData:(BasicImageInfo *)imageInfo imageContext:(SubscriberContext *)context;
-(NSString *)generateFilePath:(SubscriberContext *)context imageHash:(NSString *)imageHash;
-(BasicImageInfo *)cachedDataForURL:(NSString *)imageUrl imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context;
@end
