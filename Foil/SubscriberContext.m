    //
    //  SubscriberContext.m
    //  Foil
    //
    //  Created by Leonardo Ferreira on 7/29/13.
    //  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
    //

#import "SubscriberContext.h"
#import <sys/utsname.h>
#import "Interaction.h"

@implementation SubscriberContext
{
    NSString *_rootURL;
}

@synthesize UniqueId=_contextId;
@synthesize ContextName=_subscriberName;
@synthesize ContextDisplayTitle;

#define KEY_FOR_SubscriberFullScreenImageHash @"SFSIH"
#define KEY_FOR_SubscriberIconHash @"SIH"
#define KEY_FOR_SubscriberLoadingImageHash @"SLIH"
@synthesize ThumbImageHash=_subscriberIconHash;
@synthesize ThumbImageUrl;

@synthesize ExternalBaseURL=_webRootURL;
@synthesize InternalBaseURL=_internalRootURL;
    //@synthesize welcomeMessage=_welcomeMessage;

- (void)UpdateDefaultEntries:(NSUserDefaults *)defaults dictionary:(NSDictionary *)dictionary keyForDictionary:(NSString *)keyForDictionary
{
    [defaults removeObjectForKey:keyForDictionary];
    [defaults setObject:dictionary forKey:keyForDictionary];
    [defaults synchronize];
}

- (NSData *)getImage:(NSString *)subscriberImageHash imageDictionary:(NSDictionary *)imageDictionary keyForDefaultSettings:(NSString *)keyForDefaultSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *image;
    if(imageDictionary){
            //try to retrive pre-downloaded image
        image = (NSData *)[imageDictionary valueForKey:subscriberImageHash];
    }
    if(!image)
    {
            //TODO: Download Image and initialize
        imageDictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:image, nil] forKeys:[[NSArray alloc] initWithObjects:imageDictionary, nil]];
        [self UpdateDefaultEntries:defaults dictionary:imageDictionary keyForDictionary:keyForDefaultSettings];
    }
    return image;
}

-(id)initWithContext:(NSString *)contextId :(NSString *)subscriberName :(NSString *)subscriberFullScreenImageHash :(NSString *)subscriberIconHash :(NSString *)subscriberLoadingImageHash :(NSString *)webRootUrl :(NSString *)internalRootUrl :(NSString *) welcomeMessage
{
    self=[super init];
    _contextId = contextId;
    _subscriberName = subscriberName;
    _webRootURL = webRootUrl;
    _internalRootURL = internalRootUrl;
        //_welcomeMessage=welcomeMessage;
    
    return self;
}

-(id)initWithJsonDictionary:(NSDictionary *)json{
    self = [super init];
    _contextId = [json objectForKey:@"UniqueId"];
    _internalRootURL = [json objectForKey:@"InternalBaseURL"];
    _webRootURL = [json objectForKey:@"ExternalBaseURL"];
    _ContextDomain = [json objectForKey:@"ContextDomain"];
    _subscriberIconHash = [json objectForKey:@"ThumbImageHash"];
    ThumbImageUrl = [json objectForKey:@"ThumbImageUrl"];
    _subscriberName = [json objectForKey:@"ContextName"];
    ContextDisplayTitle = [json objectForKey:@"ContextDisplayTitle"];
    
    return self;
}

-(NSData *)downloadImage:(NSString *)imageHash{
    Interaction *interaction = [Interaction getInstance];
    NSData *result;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSString *screenSizeDescription = [NSString stringWithFormat:@"%fx%f",screenRect.size.width,screenRect.size.height];
    NSMutableString *blobRootURL = nil;
    [blobRootURL appendString:@"/"];
    [blobRootURL appendString:_subscriberName];
    [blobRootURL appendString:@"/"];
    [blobRootURL appendString:imageHash];
    [blobRootURL appendString:screenSizeDescription];
    [blobRootURL appendString:@".png"];
    if([interaction requestConnectivity])
    {
        result=[NSData dataWithContentsOfURL:[NSURL URLWithString: @"http://example.com/image.jpg"]];
    }
    return result;
}

-(NSString *)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

-(NSString *)rootURLForCurrentSubscriberContext{
    if (_rootURL) {
        return _rootURL;
    } else{
        NSString *result = nil;
        if (_internalRootURL != nil) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[_internalRootURL stringByAppendingString:@"/status"]]];
            if ([data length]>0) {
                result = _internalRootURL;
            }
        }
        
        if(result == nil && _webRootURL != nil)
        {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[_webRootURL stringByAppendingString:@"/status"]]];
            if ([data length]>0) {
                result = _webRootURL;
            }
        }
        _rootURL = result;
        return result;
    }
}

@end




















