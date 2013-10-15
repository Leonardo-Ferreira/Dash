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

static MediaCache *sharedMediaCacheInstance;

+(BasicImageInfo *)cachedImageForURL:(NSString *)imageUrl imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context{
    BasicImageInfo *result = nil;
    if (imageHash) {
        if(!sharedMediaCacheInstance){
            sharedMediaCacheInstance = [[super allocWithZone:NULL] init];
        }
        result = [sharedMediaCacheInstance cachedDataForURL:imageUrl imageHash:imageHash subscriberContext:context];
    }
    return result;
}


+(void)cacheImage:(BasicImageInfo *)imageInfo imageContext:(SubscriberContext *)context{
    if(imageInfo==nil || imageInfo.ImageHash == nil){
        return;
    }
    if(!sharedMediaCacheInstance){
        sharedMediaCacheInstance = [[super allocWithZone:NULL] init];
    }
    [sharedMediaCacheInstance cacheData:imageInfo imageContext:context];
}

+(void)cleanCache{
    if(!sharedMediaCacheInstance){
        sharedMediaCacheInstance = [[super allocWithZone:NULL] init];
    }
    [sharedMediaCacheInstance clean];
}

-(BasicImageInfo *)cachedDataForURL:(NSString *)imageUrl imageHash:(NSString *)imageHash subscriberContext:(SubscriberContext *)context{
    BasicImageInfo *res = nil;
    if (imageHash) {
        NSString *filePath;
        if(context){
            filePath = [self generateFilePath:context imageHash:imageHash];
        }
        else{
            filePath = imageHash;
        }
        if ([[imagesDictionary allKeys] containsObject:filePath]) {
            res = [imagesDictionary objectForKey:filePath];
        }else{
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            if (data) {
                res = [[BasicImageInfo alloc]init];
                res.ImageUrl = imageUrl;
                res.ImageHash = imageHash;
                res.Image = [UIImage imageWithData:data];
            }
        }
    }
    return res;
}

-(NSString *)generateFilePath:(SubscriberContext *)context imageHash:(NSString *)imageHash {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = @"";
    if(context){
        filePath = [documentsPath stringByAppendingPathComponent:@"images"];
        filePath = [filePath stringByAppendingPathComponent:context.ContextDomain];
        filePath = [filePath stringByAppendingPathComponent:context.ContextName];
    }
    else{
        filePath = [filePath stringByAppendingPathComponent:@"generalimages"];
    }
    filePath = [filePath stringByAppendingPathComponent:imageHash];
    filePath = [filePath stringByAppendingPathExtension:@"png"];
    return filePath;
}

-(void)cacheData:(BasicImageInfo *)imageInfo imageContext:(SubscriberContext *)context{
    if (!imageInfo.Image) {
        NSLog(@"The Image is 'nil'. Returning");
        return;
    }
    NSData *data = UIImagePNGRepresentation(imageInfo.Image);
    NSString *auxFilePath = [self generateFilePath:context imageHash:imageInfo.ImageHash];
    NSString *directory = [auxFilePath stringByDeletingLastPathComponent];
    NSLog(@"Caching image in path %@.", auxFilePath);
    [imagesDictionary setObject:imageInfo forKey:auxFilePath];
    
    NSString *filePath = [self generateFilePath:context imageHash:imageInfo.ImageHash];
    if([[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil]){
        NSError *error;
        if([data writeToFile:filePath options:NSDataWritingAtomic error:&error]){//Write the file
            NSLog(@"File written to disk");
        }
        else{
            NSLog(@"File NOT written! ERROR = %@",[error description]);
        }
    }
}

-(void)clean{
    [imagesDictionary removeAllObjects];
}

-(id)init{
    self = [super init];
    imagesDictionary = [[NSMutableDictionary alloc]init];
    return self;
}

@end
