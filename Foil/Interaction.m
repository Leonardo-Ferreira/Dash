//
//  Interaction.m
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "Interaction.h"

@implementation Interaction{
    NSUInteger networkActivityCounter;
    NSMutableArray *_indicators;
    NSString *userNameAux;
    NSMutableDictionary *imagesDictionary;
    BOOL startUpCompleted;
    BOOL locationEnabled;
    dispatch_queue_t indicatorLoadingQueue;
    dispatch_queue_t contextsLoaderQueue;
    dispatch_queue_t imageDownloadingQueue;
    NSMutableDictionary *_loadedIndicatorsDictionary;
}

#define DAYS_BETWEEN_REQUEST 7
#define KEY_LAST_ASKED_LOCATION  @"lastAskedForLocationOn"

@synthesize startDateTime;
@synthesize finishDateTime;
@synthesize startLocation;
@synthesize finishLocation;
@synthesize operatingSystem;
@synthesize deviceModel;
@synthesize actions = _actions;
@synthesize currentUser = _currentUser;
@synthesize currentSubscriberContext = _currentSubscriberContext;
@synthesize contextsLoadingCompleted = _loadingContextsCompleted;
@synthesize allContextsForCurrentUser = _allContextsForCurrentUser;
@synthesize loadedIndicatorsDictionary = _loadedIndicatorsDictionary;
@synthesize availibleIndicators = _indicators;
@synthesize availibleIndicatorsDiscovered = _availibleIndicatorsDiscovered;
@synthesize selectedIndicator;

static Interaction *sharedInstance = nil;

+(Interaction *)getInstance{
    if(!sharedInstance){
        NSLog(@"Creating Interaction instance.");
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

-(BOOL)locationAvailible{
    return [CLLocationManager locationServicesEnabled];
}

-(void)publishInteraction{
    
}

-(id)init{
    self = [super init];
    _indicators = [[NSMutableArray alloc]init];
    [self startUp];
    return self;
}

-(void)startUp{
    startUpCompleted = false;
    imagesDictionary = [[NSMutableDictionary alloc]init];
        //Load Dictionary with default images
    startUpCompleted = true;
}

-(void)addAction:(ActionPerformed *)action{
    
}

-(BOOL)requestConnectivity{
    @synchronized(self){
        networkActivityCounter++;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return YES;
}

-(void)releaseConnectivity{
    @synchronized(self){
        if(networkActivityCounter){
            networkActivityCounter--;
        }
        if (!networkActivityCounter) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

-(void)loadAllContextsForUser:(NSString *)username{
    userNameAux = username;
    _loadingContextsCompleted = NO;
    if (contextsLoaderQueue == NULL) {
        contextsLoaderQueue = dispatch_queue_create("contextsLoaderQueue", NULL);
    }
    
    dispatch_async(contextsLoaderQueue, ^{
        NSLog(@"Loading all contexts block started");
        [self requestConnectivity];
        
        Util *ref = [Util Get:[NSString stringWithFormat:@"%@/userContext?username=%@", Util.azureBaseUrl, [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                 successBlock:^(NSData *data, id jsonData){
                     NSLog(@"Loading all contexts block succeeded");
                     if([userNameAux isEqualToString:username]){
                         _allContextsForCurrentUser = [[NSSet alloc]initWithArray: jsonData];
                     }
                 } errorBlock:^(NSError *error){
                     NSLog(@"%@",error);
                 } completeBlock:^{
                     NSLog(@"load all contexts for user async block completed.");
                     _loadingContextsCompleted = YES;
                     [self releaseConnectivity];
                 }];
        //Keep Thread alive without blocking. This is not equal to
        while (!ref.operationCompleted) {
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    });
    NSLog(@"Load All Contexts Dispatched. It should start at any moment if it not already.");
}

-(void)loadImageFromURL:(NSString *)imageURL finishBlock:(FinishBlock)block{
    if (imageDownloadingQueue == NULL) {
        imageDownloadingQueue = dispatch_queue_create("imageDownloadingQueue", NULL);
    }
    dispatch_async(imageDownloadingQueue, ^{
        NSLog(@"Starting image download.");
        [self requestConnectivity];
        NSString *iUrl = [imageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString: iUrl]];
        UIImage *image = [UIImage imageWithData:imgData];
        NSString *requestUrl = [NSString stringWithFormat:@"%@/MediaInfo?URL=%@", Util.azureBaseUrl, iUrl];
        NSLog(@"Image download done. Image size = %.0fx%.0f. Getting hash. requestUrl = \"%@\"",image.size.width,image.size.height,requestUrl);
        __block NSString *hash = nil;
        [self requestConnectivity];
        Util *ref = [Util Get:requestUrl successBlock:^(NSData *data, id jsonData){
            hash = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(hash != nil){
                BasicImageInfo *info = [[BasicImageInfo alloc]init];
                info.Image = image;
                info.ImageHash = hash;
                info.ImageUrl = imageURL;
                NSLog(@"Setting image to dictionary. Key = %@",imageURL);
                [imagesDictionary setObject:info forKey:info.ImageUrl];
                if (block != NULL) {
                    block(image);
                }
            }
            else{
                NSLog(@"Hash for image IS NIL");
            }
        } errorBlock: NULL completeBlock:^{[self releaseConnectivity];}];
        while (!ref.operationCompleted) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    });
}

-(UIImage *)getImageFromURL:(NSString *)imageURL imageHash:(NSString *)imageHash{
    BasicImageInfo *result=[imagesDictionary objectForKey:imageURL];
    if (imageHash == nil) {
        result=nil;
    }
    if (result == nil || result.ImageHash != imageHash) {
        [self loadImageFromURL:imageURL finishBlock:NULL];
        NSUInteger count=0;
        do {
            [NSThread sleepForTimeInterval:.5];
            result = [imagesDictionary objectForKey:imageURL];
            count++;
        } while (result == nil && count < 41);//arbitrary number = 20 seconds
    }
    return result.Image;
}

-(void)getImageFromURLAsync:(NSString *)imageURL imageHash:(NSString *)imageHash finishBlock:(FinishBlock)finishBlock{
    BasicImageInfo *result = [imagesDictionary objectForKey:imageURL];
    if (imageHash == nil) {
        result=nil;
    }
    if (result == nil || result.ImageHash != imageHash) {
        [self loadImageFromURL:imageURL finishBlock:finishBlock];
        /*NSUInteger count=0;
        do {
            [NSThread sleepForTimeInterval:.5];
            result = [imagesDictionary objectForKey:imageURL];
            count++;
        } while (result == nil && count < 11);//arbitrary number = 20 seconds*/
    }
}


-(BOOL)shouldAskToEnableLocation{
    return ([self.lastAskedToEnableLocation timeIntervalSinceNow] / ( 60 * 60 * 24) > DAYS_BETWEEN_REQUEST);
}

-(NSDate *)lastAskedToEnableLocation{
    NSString *dateString = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_LAST_ASKED_LOCATION];
    NSDate *lastTime;
    if(dateString){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd hh:mm:ss"];
        lastTime = [dateFormat dateFromString:dateString];
    }else{
        lastTime = [[NSDate alloc]initWithTimeIntervalSince1970:0];
    }
    return lastTime;
}

-(void)askToEnableLocationDate{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KEY_LAST_ASKED_LOCATION];
}

-(void)interactionFinished{
    
}

-(BOOL)validateUser:(NSString *)username password:(NSString *)password againstContext:(SubscriberContext *)context{
    IdentityServices *service = [[IdentityServices alloc]init];
    service.validateAgainstURL = [NSString stringWithFormat:@"%@/authentication?operation=authenticate", context.rootURLForCurrentSubscriberContext];
    if (contextsLoaderQueue == NULL) {
        NSLog(@"contextsLoaderQueue is NULL");
    }
    dispatch_async(contextsLoaderQueue, ^{
        [service validateCredentialsAsync:username password:password];
        while (!service.validationDone) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    });
    while (!service.validationDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        NSLog(@"validation not done. zzzZZZzzzZZZzzz");
    }
    if (service.userValidated) {
        _currentSubscriberContext = context;
    }
    return service.userValidated;
}

-(void)loadIndicatorBaseValue:(Indicator *)indicator{
    indicator.isLoadingData = YES;
    indicator.dataFinishedLoading = NO;
    indicator.dataFinishedLoadingSuccessfully = NO;
    if(indicatorLoadingQueue == NULL){
        indicatorLoadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    
    completeBlock_t completeBlock =
    ^{
        indicator.isLoadingData = NO;
        indicator.dataFinishedLoading=YES;
        NSLog(@"Operation completed.");
        [self releaseConnectivity];
    };
    
    successBlock_t successBlock = ^(NSData *data, id jsonData){
        indicator.dataFinishedLoadingSuccessfully=YES;
        //NSString *value = [jsonData objectForKey:@"value"];
        [indicator dataDictionaryDidLoad:jsonData];
        [_loadedIndicatorsDictionary setValue:indicator forKey:indicator.title];
    };
    
    dispatch_async(indicatorLoadingQueue, ^{
        [self requestConnectivity];
        
        [_loadedIndicatorsDictionary removeObjectForKey:indicator.title];
        NSString *requestStr =[NSString stringWithFormat:@"%@/indicators?name=%@", [_currentSubscriberContext rootURLForCurrentSubscriberContext],indicator.internalName];
        
        Util *refOp = [Util Get:requestStr successBlock:successBlock errorBlock:^(NSError *error){} completeBlock:completeBlock];
        
        while (!refOp.operationCompleted) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    });
}

-(void)loadIndicatorData:(Indicator *)indicatorBase startDate:(NSDate *)startDate finishDate:(NSDate *)finishDate{
    
    if(indicatorLoadingQueue == NULL){
        indicatorLoadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    
    if (indicatorBase.isLoadingData || [indicatorBase hasDataForInterval:startDate endDate:finishDate]) {
        return;
    }
    indicatorBase.isLoadingData = YES;
    indicatorBase.dataFinishedLoading = NO;
    
    completeBlock_t completeBlock =
    ^{
        NSLog(@"Operation completed.");
        indicatorBase.dataFinishedLoading = YES;
        indicatorBase.isLoadingData = NO;
        [self releaseConnectivity];
    };
    
    successBlock_t successBlock = ^(NSData *data, id jsonData){
        [indicatorBase dataDictionaryDidLoad:jsonData];
        
        indicatorBase.dataFinishedLoadingSuccessfully = YES;
    };
    
    //NSString *payload = @"";
    //NSDictionary *headers = [[NSDictionary alloc]init];
    
    dispatch_async(indicatorLoadingQueue, ^
    {
        [self requestConnectivity];
        NSString *requestStr =[NSString stringWithFormat:@"%@/indicators?name=%@&resumed=false", [_currentSubscriberContext rootURLForCurrentSubscriberContext], indicatorBase.internalName];
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setObject:@"application/json; charset=utf-8" forKey:@"content-type"];
        [headers setObject:@"http://integrationservices.hospitale.aec.com.br/VerificarUsuario" forKey:@"SOAPAction"];
        
        [Util Post:requestStr content:@"" headers:headers successBlock:successBlock errorBlock:^(NSError *error){} completeBlock:completeBlock];
        /*[Util Post:[_currentSubscriberContext rootURLForCurrentSubscriberContext] content:payload headers:headers successBlock:successBlock errorBlock:^(NSError *error){indicatorBase.dataFinishedLoadingSuccessfully = NO;} completeBlock:completeBlock];*/
        
        while (!indicatorBase.dataFinishedLoading) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    });
}

-(void)discoverIndicators{
    completeBlock_t completed =
    ^{
        NSLog(@"Indicators discovery completed.");
        _availibleIndicatorsDiscovered = YES;
        [self releaseConnectivity];
    };
    
    successBlock_t succeded = ^(NSData *data, id jsonData){
        for (int i=0; i<[jsonData count]; i++) {
            Indicator *item = [[Indicator alloc]initWithJsonDictionary:[jsonData objectAtIndex:i]];
            [_indicators addObject:item];
        }
    };
    if (!indicatorLoadingQueue) {
        indicatorLoadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //indicatorLoadingQueue = dispatch_queue_create("loaderQ", NULL);
    }
    dispatch_async(indicatorLoadingQueue, ^
    {
        [_indicators removeAllObjects];
        [self requestConnectivity];
        _availibleIndicatorsDiscovered = NO;
        NSLog(@"%@/indicator",_currentSubscriberContext.ExternalBaseURL);
        [Util Get:[NSString stringWithFormat:@"%@/indicators",[_currentSubscriberContext rootURLForCurrentSubscriberContext]] successBlock:succeded errorBlock:^(NSError *error){
            NSLog(@"%@" , error.description);
        } completeBlock:completed];
        while (!_availibleIndicatorsDiscovered) {
            //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    });
}

@end





















