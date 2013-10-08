//
//  Util.m
//  Foil
//
//  Created by Leonardo Ferreira on 8/24/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "Util.h"

@implementation Util{
    NSMutableData *_data;
    successBlock_t _successBlock;
    completeBlock_t _completeBlock;
    errorBlock_t _errorBlock;
    NSUInteger networkActivityCounter;
}

@synthesize operationCompleted = _operationCompleted;

+(NSString *)azureBaseUrl{
    return [NSString stringWithFormat:@"http://dashcloudtest.cloudapp.net"];
    //return @"http://fabricawks69:81";
}

+(NSString *)azureBaseBlobUrl{
    return @"http://dashteststorage.blob.core.windows.net";
}

+(id)get:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;{
    Util *res = [[Util alloc]init];
    [res get:resourceURL successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
    return res;
}

+(id)post:(NSString *)resourceURL content:(NSString *)content headers:(NSDictionary *)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock{
    Util *res = [[Util alloc]init];
    [res post:resourceURL content:content headers:headers successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
    return res;
}

-(id)init{
    if(self = [super init]){
        _data=[[NSMutableData alloc]init];
    }
    return self;
}

-(void)post:(NSString *)resourceURL content:(NSString *)content headers:(NSDictionary *)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock{
    _operationCompleted = NO;
    _successBlock = [successBlock copy];
    _completeBlock = [completeBlock copy];
    _errorBlock = [errorBlock copy];
    
    NSURL *url = [NSURL URLWithString:resourceURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:5];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    
    BOOL contentLengthSet, hostSet = NO;
    for (NSString *key in [headers allKeys]) {
        NSString *value = [headers objectForKey:key];
        [request addValue:value forHTTPHeaderField:key];
        if ([key caseInsensitiveCompare:@"content-length"] == NSOrderedSame) {
            contentLengthSet = YES;
        }else{
            if ([key caseInsensitiveCompare:@"host"] == NSOrderedSame) {
                hostSet=YES;
            }
        }
    }
    if (!contentLengthSet) {
        [request addValue:[NSString stringWithFormat:@"%d",[content length]] forHTTPHeaderField:@"Content-Length"];
    }
    if (!hostSet) {
        [request addValue:[[NSURL URLWithString:resourceURL] host] forHTTPHeaderField:@"Host"];
    }

    NSURLConnection *_conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (_conn) {
        NSLog(@"Post Started");
    }else{
        NSLog(@"Connection is nil.");
    }
    //[_conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    //[_conn start];
}

-(void)get:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;{
    _operationCompleted = NO;
    _successBlock = [successBlock copy];
    _completeBlock = [completeBlock copy];
    _errorBlock = [errorBlock copy];
    
    NSURL *url = [NSURL URLWithString:resourceURL];
    NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *_conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    //[_conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_conn start];
    NSLog(@"Request Started.");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (!_data) {
        _data = [[NSMutableData alloc]init];
    }
    [_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSLog(@"Authentication Required");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    
    id jsonResult=nil;
    if ([jsonObjects respondsToSelector:@selector(allKeys)]) {
        id key = [[jsonObjects allKeys] firstObject];
        jsonResult = [jsonObjects objectForKey:key];
    }else{
        jsonResult = jsonObjects;
    }
    
    _successBlock(_data, jsonResult);
    _completeBlock();
    _operationCompleted = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _errorBlock(error);
    _completeBlock();
}

+(NSString *)generateMD5HashForImage:(NSData *)imageData{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(imageData.bytes, imageData.length, md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+(DeviceStyle *)GetCurrentDeviceStyle{
    return [[DeviceStyle alloc]init];
}

+(float)randomInt:(int)lowerBound upperBound:(int)upperBound{
    return lowerBound+arc4random() % (upperBound-lowerBound);
}

+(UIImage *)getImageFromURL:(NSString *)imageURL imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context{
    BasicImageInfo *result = [MediaCache cachedImageForURL:imageURL imageHash:imageHash subscriberContext:context];
    if (imageHash == nil) {
        result=nil;
    }
    if (result == nil || result.ImageHash != imageHash) {
        [self loadImageFromURL:imageURL subscriberContext:context finishBlock:NULL];
        NSUInteger count=0;
        do {
            [NSThread sleepForTimeInterval:.5];
            result = [MediaCache cachedImageForURL:imageURL imageHash:imageHash subscriberContext:context];
            count++;
        } while (result == nil && count < 41);//arbitrary number = 20 seconds
    }
    return result.Image;
}

+(void)getImageFromURLAsync:(NSString *)imageURL imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context finishBlock:(finishBlock)finishBlock{
    BasicImageInfo *result = [MediaCache cachedImageForURL:imageURL imageHash:imageHash subscriberContext:context];
    if (imageHash != nil && imageHash != NULL) {
        result = nil;
    }
    if (result == nil || result.ImageHash != imageHash) {
        [self loadImageFromURL:imageURL subscriberContext:context finishBlock:finishBlock];
        /*NSUInteger count=0;
         do {
         [NSThread sleepForTimeInterval:.5];
         result = [MediaCache cachedImageForURL:imageURL imageHash:imageHash subscriberContext:context];
         count++;
         } while (result == nil && count < 11);//arbitrary number = 20 seconds*/
    }
}

+(void)loadImageFromURL:(NSString *)imageURL subscriberContext:(SubscriberContext *)context finishBlock:(finishBlock)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Starting image download.");
        NSString *iUrl = [imageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString: iUrl]];
        UIImage *image = [UIImage imageWithData:imgData];
        /*NSString *requestUrl = [NSString stringWithFormat:@"%@/MediaInfo?URL=%@", Util.azureBaseUrl, iUrl];
        NSLog(@"Image download done. Image size = %.0fx%.0f. Getting hash. requestUrl = \"%@\"",image.size.width,image.size.height,requestUrl);
        __block NSString *hash = nil;
        Util *op = [self get:requestUrl successBlock:^(NSData *data, id jsonData){
            hash = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(hash != nil){
                BasicImageInfo *info = [[BasicImageInfo alloc]init];
                info.Image = image;
                info.ImageHash = hash;
                info.ImageUrl = imageURL;
                NSLog(@"Setting image to dictionary. Key = %@",imageURL);
                [MediaCache cachedImageForURL:imageURL imageHash:hash subscriberContext:context];
                if (block != NULL) {
                    block(image);
                }
            }
            else{
                NSLog(@"Hash for image IS NIL");
            }
        } errorBlock: NULL completeBlock:^{}];
        while (!op.operationCompleted) {
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }*/
        BasicImageInfo *info = [[BasicImageInfo alloc]init];
        info.Image = image;
        info.ImageHash = [self generateMD5HashForImage:imgData];
        info.ImageUrl = imageURL;
        NSLog(@"Setting image to dictionary. Key = %@",imageURL);
        [MediaCache cacheImage:info imageContext:context];
        
    });
}





@end
