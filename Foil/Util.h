//
//  Util.h
//  Foil
//
//  Created by Leonardo Ferreira on 8/24/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceStyle.h"

typedef void (^successBlock_t)(NSData *data, id jsonData);
typedef void (^errorBlock_t)(NSError *error);
typedef void (^completeBlock_t)();

@interface Util : NSObject<NSURLConnectionDelegate>
@property (nonatomic,readonly) BOOL operationCompleted;

+(NSString *)azureBaseUrl;
+(NSString *)azureBaseBlobUrl;
+(id)Get:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;
+(id)Post:(NSString *)resourceURL content:(NSString *)content headers:(NSDictionary *)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;
+(DeviceStyle *)GetCurrentDeviceStyle;

+(float)randomInt:(int)lowerBound upperBound:(int)upperBound;

-(id)initGet:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;


@end
