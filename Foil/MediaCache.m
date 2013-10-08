//
//  MediaCache.m
//  Foil
//
//  Created by Leonardo Ferreira on 10/6/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "MediaCache.h"

@implementation MediaCache{
    NSMutableDictionary *imagesDictionary;
}

static MediaCache *sharedInstance;

+(BasicImageInfo *)cachedImageForURL:(NSString *)imageUrl imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context{
    BasicImageInfo *result = nil;
    if (!imageHash) {
        if (!sharedInstance) {
            sharedInstance = [[MediaCache alloc]init];
        }
        result = [sharedInstance cachedImageForURL:imageUrl imageHash:imageHash subscriberContext:context];
    }
    return result;
}


+(void)cacheImage:(BasicImageInfo *)imageInfo imageContext:(SubscriberContext *)context{
    if(imageInfo==nil || imageInfo.ImageHash == nil){
        return;
    }
    if (!sharedInstance) {
        sharedInstance = [[MediaCache alloc]init];
    }
    [sharedInstance cacheImage:imageInfo imageContext:context];
}

+(void)cleanCache{
    if (!sharedInstance) {
        sharedInstance = [[MediaCache alloc]init];
    }
    [sharedInstance cleanCache];
}

-(BasicImageInfo *)cachedImageForURL:(NSString *)imageUrl imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context{
    NSString *filePath;
    if(context!=nil){
        filePath = [context.ContextDomain stringByAppendingPathComponent:context.ContextName];
        filePath = [filePath stringByAppendingPathComponent:imageHash];
    }
    else{
        filePath = imageHash;
    }
    BasicImageInfo *res = nil;
    if ([[imagesDictionary allKeys] containsObject:filePath]) {
        res = [imagesDictionary objectForKey:filePath];
    }else{
        NSString *filePath = [self generateFilePath:context imageHash:imageHash];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data != nil) {
            res = [[BasicImageInfo alloc]init];
            res.ImageUrl = imageUrl;
            res.ImageHash = imageHash;
            res.Image = [UIImage imageWithData:data];
        }
    }
    
    return res;
}

- (NSString *)generateFilePath:(SubscriberContext *)context imageHash:(NSString *)imageHash {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"images"]; //Add the file name
    if(context != nil){
        filePath = [filePath stringByAppendingPathComponent:context.ContextDomain];
        filePath = [filePath stringByAppendingPathComponent:context.ContextName];
    }
    else{
        filePath = [filePath stringByAppendingPathComponent:@"globalImages"];
    }
    filePath = [filePath stringByAppendingPathComponent:imageHash];
    filePath = [filePath stringByAppendingPathExtension:@"png"];
    return filePath;
}

-(void)cacheImage:(BasicImageInfo *)imageInfo imageContext:(SubscriberContext *)context{
    NSData *data = UIImagePNGRepresentation(imageInfo.Image);
    NSString *auxFilePath = [context.ContextDomain stringByAppendingPathComponent:context.ContextName];
    auxFilePath = [auxFilePath stringByAppendingPathComponent:imageInfo.ImageHash];
    [imagesDictionary setObject:imageInfo forKey:auxFilePath];
    
    NSString *filePath = [self generateFilePath:context imageHash:imageInfo.ImageHash];
    [data writeToFile:filePath atomically:YES]; //Write the file
}

-(void)cleanCache{
    [imagesDictionary removeAllObjects];
}

-(id)init{
    self = [super init];
    imagesDictionary = [[NSMutableDictionary alloc]init];
    return self;
}

@end
