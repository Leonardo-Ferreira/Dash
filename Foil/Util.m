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
    finishBlock _finishBlock;
    NSUInteger networkActivityCounter;
}

@synthesize operationCompleted = _operationCompleted;
@synthesize operationStatusCode = _operationStatusCode;

+(NSString *)azureBaseUrl{
    return [NSString stringWithFormat:@"http://dashcloudtest.cloudapp.net"];
    //return @"http://fabricawks69:81";
}

+(NSString *)azureBaseBlobUrl{
    return @"http://dashteststorage.blob.core.windows.net";
}

+(Util *)get:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;{
    Util *res = [[Util alloc]init];
    [res get:resourceURL successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
    return res;
}

+(Util *)post:(NSString *)resourceURL content:(NSString *)content headers:(NSDictionary *)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock{
    Util *res = [[Util alloc]init];
    [res post:resourceURL content:content headers:headers successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
    return res;
}

-(id)init{
    if(self = [super init]){
        _data = [[NSMutableData alloc]init];
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
    
    //BOOL contentLengthSet, hostSet = NO;  //contentLenghtSet still YES
    BOOL hostSet = NO;
    BOOL contentLengthSet = NO;
    NSArray *keys = [headers allKeys];
    for (NSString *key in keys) {
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
    [request addValue:[[NetworkOperation getInstance] getToken] forHTTPHeaderField:@"dash-Token"];
    
    NSURLConnection *_conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (_conn) {
        NSLog(@"Post Started");
    }else{
        NSLog(@"Connection is nil.");
    }
    //[_conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_conn start];
}

-(void)get:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;{
    _operationCompleted = NO;
    _successBlock = [successBlock copy];
    _completeBlock = [completeBlock copy];
    _errorBlock = [errorBlock copy];
    
    NSURL *url = [NSURL URLWithString:resourceURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *val =  [[NetworkOperation getInstance] getToken];
    if (!val) {
        val = @"";
    }
    [request addValue:val forHTTPHeaderField:@"dash-Token"];
    NSURLConnection *_conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    //[_conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_conn start];
    NSLog(@"Request Started.");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
    _operationStatusCode = httpResp.statusCode;
    NSDictionary *headers = [httpResp allHeaderFields];
    if ([[headers allKeys]containsObject:@"dash-Token"]) {
        NSString *tokenVal = [headers objectForKey:@"dash-Token"];
        if (tokenVal) {
            [[NetworkOperation getInstance] setToken:tokenVal];
        }
    }
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

+(BasicImageInfo *)getImageFromURL:(NSString *)imageURL imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context{
    BasicImageInfo *result = [MediaCache cachedImageForURL:imageURL imageHash:imageHash subscriberContext:context];
    if (imageHash == nil) {
        result=nil;
    }
    if (result == nil || result.ImageHash != imageHash) {
        [self loadImageFromURL:imageURL imageHash:imageHash subscriberContext:context finishBlock:nil];
        NSUInteger count=0;
        do {
            [NSThread sleepForTimeInterval:.5];
            result = [MediaCache cachedImageForURL:imageURL imageHash:imageHash subscriberContext:context];
            count++;
        } while (result == nil && count < 41);//arbitrary number = 20 seconds
    }
    return result;
}

+(UIView *)retrieveFirstResponder:(UIView *)topView{
    if(topView.isFirstResponder){
        return topView;
    }else{
        for (UIView *subView in topView.subviews) {
            return [Util retrieveFirstResponder:subView];
        }
    }
    return nil;
}

+(void)loadImageFromURL:(NSString *)imageURL imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context finishBlock:(finishBlock)block{
    Util *ref = [[Util alloc]init];
    [ref loadImageFromURL:imageURL imageHash:imageHash subscriberContext:context finishBlock:block];
    
}

-(void)loadImageFromURL:(NSString *)imageURL imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context finishBlock:(finishBlock)block{
    _finishBlock = [block copy];
    __block BasicImageInfo *result = nil;
    if (imageHash != nil && [imageHash class] != [NSNull class]) {
        result = [MediaCache cachedImageForURL:imageURL imageHash:imageHash subscriberContext:context];
    }
    if (result == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Starting image download.");
            NSString *iUrl = [imageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString: iUrl]];
            UIImage *image = [UIImage imageWithData:imgData];
            result = [[BasicImageInfo alloc]init];
            result.Image = image;
            result.ImageHash = imageHash;
            result.ImageUrl = imageURL;
            NSLog(@"Setting image to dictionary. Key = %@",imageURL);
            [MediaCache cacheImage:result imageContext:context];
            
            if (_finishBlock) {
                _finishBlock(result);
            }
        });
    }else{
        NSLog(@"cache HIT!");
        if (_finishBlock) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _finishBlock(result);
            });
        }
    }
}





@end
