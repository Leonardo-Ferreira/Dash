//
//  Util.h
//  Foil
//
//  Created by Leonardo Ferreira on 8/24/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceStyle.h"
#import "BasicImageInfo.h"
#import "MediaCache.h"
#import "NetworkOperation.h"
#import <CommonCrypto/CommonDigest.h>

typedef void (^successBlock_t)(NSData *data, id jsonData);
typedef void (^errorBlock_t)(NSError *error);
typedef void (^completeBlock_t)();
typedef void (^ finishBlock)(BasicImageInfo *imageResult);

@interface Util : NSObject<NSURLConnectionDelegate>
@property (nonatomic,readonly) BOOL operationCompleted;
@property (nonatomic,readonly) int operationStatusCode;

+(NSString *)azureBaseUrl;
+(NSString *)azureBaseBlobUrl;
+(Util *)get:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;
+(Util *)post:(NSString *)resourceURL content:(NSString *)content headers:(NSDictionary *)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;
+(DeviceStyle *)GetCurrentDeviceStyle;
+(float)randomInt:(int)lowerBound upperBound:(int)upperBound;
+(BasicImageInfo *)getImageFromURL:(NSString *)imageURL imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context;
+(void)loadImageFromURL:(NSString *)imageURL imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context finishBlock:(finishBlock)finishBlock;
+(UIView *)retrieveFirstResponder:(UIView *)topView;


@end
