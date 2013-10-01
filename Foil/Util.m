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
}

@synthesize operationCompleted=_operationCompleted;

+(NSString *)azureBaseUrl{
    return [NSString stringWithFormat:@"http://dashcloudtest.cloudapp.net"];
    //return @"http://fabricawks69:81";
}

+(NSString *)azureBaseBlobUrl{
    return @"http://dashteststorage.blob.core.windows.net";
}

+(id)Get:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;{
    return [[self alloc]initGet:resourceURL successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

+(id)Post:(NSString *)resourceURL content:(NSString *)content headers:(NSDictionary *)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock{
    return [[self alloc]initPost:resourceURL content:content headers:headers successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

-(id)initPost:(NSString *)resourceURL content:(NSString *)content headers:(NSDictionary *)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock{
    if(self=[super init]){
        _data=[[NSMutableData alloc]init];
    }
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
    
    return self;
}

-(id)initGet:(NSString *)resourceURL successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t)completeBlock;{
    if(self=[super init]){
        _data=[[NSMutableData alloc]init];
    }
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
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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

+(DeviceStyle *)GetCurrentDeviceStyle{
    DeviceStyle *result = [[DeviceStyle alloc]init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    result.Height = screenRect.size.height;
    result.Width = screenRect.size.width;
    
    return result;
}

+(float)randomInt:(int)lowerBound upperBound:(int)upperBound{
    return lowerBound+arc4random() % (upperBound-lowerBound);
}






@end
