//
//  Interaction.m
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "Interaction.h"
#import "Reachability.h"
#import "NetworkOperation.h"

@implementation Interaction{
    NSMutableArray *_indicators;
    NSString *userNameAux;
    BOOL startUpCompleted;
    BOOL locationEnabled;
    dispatch_queue_t indicatorLoadingQueue;
    dispatch_queue_t contextsLoaderQueue;
    dispatch_queue_t imageDownloadingQueue;
    NSMutableDictionary *_loadedIndicatorsDictionary;
    NSTimer *timer;
    NSString *_chartKey;
}

#define DAYS_BETWEEN_REQUEST 7
#define KEY_LAST_ASKED_LOCATION  @"lastAskedForLocationOn"

@synthesize startDateTime;
@synthesize finishDateTime;
@synthesize startLocation;
@synthesize finishLocation;
@synthesize actions = _actions;
@synthesize currentUser = _currentUser;
@synthesize currentSubscriberContext = _currentSubscriberContext;
@synthesize contextsLoadingCompleted = _loadingContextsCompleted;
@synthesize allContextsForCurrentUser = _allContextsForCurrentUser;
@synthesize loadedIndicatorsDictionary = _loadedIndicatorsDictionary;
@synthesize availibleIndicators = _indicators;
@synthesize availibleIndicatorsDiscovered = _availibleIndicatorsDiscovered;
@synthesize availibleIndicatorsDiscoverySucceeded = _availibleIndicatorsDiscoverySucceeded;
@synthesize selectedIndicator;
@synthesize isAssistedModeOn;

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
    startUpCompleted = true;
}

-(void)addAction:(ActionPerformed *)action{
    
}

-(void)loadAllContextsForUser:(NSString *)username{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    userNameAux = username;
    _loadingContextsCompleted = NO;
    
    if (contextsLoaderQueue == NULL) {
        contextsLoaderQueue = dispatch_queue_create("contextsLoaderQueue", NULL);
    }
    
    dispatch_async(contextsLoaderQueue, ^{
        NSLog(@"Loading all contexts block started");
        Util *ref = [Util get:[NSString stringWithFormat:@"%@/userContext?username=%@", Util.azureBaseUrl, [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
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
                 }];
        //Keep Thread alive without blocking. This is not equal to
        int count = 20;
        while (!ref.operationCompleted) {
            NetworkStatus internetStatus = [reachability currentReachabilityStatus];
            if (internetStatus == NotReachable) {
                NSLog(@"Internet connection not available. Will try %d more times",count);
                [NSThread sleepForTimeInterval:.5];
                count--;
                _allContextsForCurrentUser = nil;
                if (count == 0) {
                    break;
                }
            }
            //[[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
        }
    });
    NSLog(@"Load All Contexts Dispatched. It should start at any moment if it not already.");
    
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
    service.validateAgainstURL = [NSString stringWithFormat:@"%@/authentication?operation=authenticateV2", context.rootURLForCurrentSubscriberContext];
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
    if(service.userValidated)
    {
        _currentSubscriberContext = context;
    }
    return service.userValidated;
}

-(void)loadIndicatorBaseValue:(Indicator **)indicator{
    if (!_loadedIndicatorsDictionary) {
        _loadedIndicatorsDictionary = [[NSMutableDictionary alloc]init];
    }
    if (![_loadedIndicatorsDictionary objectForKey:(*indicator).title]) {
        (*indicator).isLoadingData = YES;
        (*indicator).dataFinishedLoading = NO;
        (*indicator).dataFinishedLoadingSuccessfully = NO;
        if(indicatorLoadingQueue == NULL){
            indicatorLoadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        }
        
        __block Indicator *auxRef = *indicator;
        __block Util *refOp;
        
        completeBlock_t completeBlock =
        ^{
            auxRef.isLoadingData = NO;
            auxRef.dataFinishedLoading = YES;
            NSLog(@"Operation completed.");
        };
        
        successBlock_t successBlock = ^(NSData *data, id jsonData){
            if (refOp.operationStatusCode == 200) {
                auxRef.dataFinishedLoadingSuccessfully = YES;
                [auxRef dataDictionaryDidLoad:jsonData];
                [_loadedIndicatorsDictionary setValue:auxRef forKey:auxRef.title];
            }
            else{
                auxRef.dataFinishedLoadingSuccessfully = NO;
            }
        };
        
        errorBlock_t errorBlock = ^(NSError *error){
            NSLog(@"%@",error.description);
        };
        
        dispatch_async(indicatorLoadingQueue, ^{
            NSString *requestStr = [NSString stringWithFormat:@"%@/indicators?name=%@", [_currentSubscriberContext rootURLForCurrentSubscriberContext],auxRef.internalName];
            
            refOp = [Util get:requestStr successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
            
            while (!refOp.operationCompleted) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
            }
        });
    }
    else{
        Indicator *auxI = [_loadedIndicatorsDictionary objectForKey:(*indicator).title];
        *indicator = auxI;
        NSLog(@"Indicator already loaded. Cache HIT!");
    }
}

-(void)reloadIndicators:(NSArray *)indicators{
    NSArray *keys = [_loadedIndicatorsDictionary allKeys];
    int c = 0;
    for (NSString *item in indicators) {
        if ([keys containsObject:item]) {
            NSLog(@"Reseting indicator %@",item);
            Indicator *auxRef = (Indicator *)[_loadedIndicatorsDictionary objectForKey:item];
            [_loadedIndicatorsDictionary removeObjectForKey:item];
            [auxRef resetData];
            [self loadIndicatorBaseValue: &auxRef];
        }
        c++;
    }
}

-(void)reloadAllIndicators{
    [_loadedIndicatorsDictionary removeAllObjects];
}

-(void)loadIndicatorData:(Indicator *)indicatorBase startDate:(NSDate *)startDate finishDate:(NSDate *)finishDate{
    if (![indicatorBase hasDataForInterval:startDate endDate:finishDate]) {
        if(indicatorLoadingQueue == NULL){
            indicatorLoadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        }
        
        if (indicatorBase.isLoadingData || [indicatorBase hasDataForInterval:startDate endDate:finishDate]) {
            return;
        }
        indicatorBase.isLoadingData = YES;
        indicatorBase.dataFinishedLoading = NO;
        
        __block Util *refOp;
        
        completeBlock_t completeBlock =
        ^{
            NSLog(@"Operation completed.");
            indicatorBase.dataFinishedLoading = YES;
            indicatorBase.isLoadingData = NO;
        };
        
        successBlock_t successBlock = ^(NSData *data, id jsonData){
            if (refOp.operationStatusCode == 200) {
                [indicatorBase dataDictionaryDidLoad:jsonData];
                
                indicatorBase.dataFinishedLoadingSuccessfully = YES;
            }
            else{
                indicatorBase.dataFinishedLoadingSuccessfully = NO;
            }
            
        };
        
        dispatch_async(indicatorLoadingQueue, ^
                       {
                           NSString *requestStr =[NSString stringWithFormat:@"%@/indicators?name=%@&resumed=false", [_currentSubscriberContext rootURLForCurrentSubscriberContext], indicatorBase.internalName];
                           NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
                           [headers setObject:@"application/json; charset=utf-8" forKey:@"content-type"];
                           
                           refOp = [Util post:requestStr content:@"" headers:headers successBlock:successBlock errorBlock:^(NSError *error){NSLog(@"Error at network stack of 'loadIndicatorData'. Error = %@",[error description]);} completeBlock:completeBlock];
                           
                           while (!refOp.operationCompleted) {
                               [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
                           }
                       });
    }
}

-(void)discoverIndicators{
    __block Util *refOp;
    completeBlock_t completed =
    ^{
        NSLog(@"Indicators discovery completed.");
        _availibleIndicatorsDiscovered = YES;
    };
    
    successBlock_t succeded = ^(NSData *data, id jsonData){
        if (refOp.operationStatusCode == 200) {
            for (int i = 0; i < [jsonData count]; i++) {
                Indicator *item = [[Indicator alloc]initWithJsonDictionary:[jsonData objectAtIndex:i]];
                [_indicators addObject:item];
            }
            _availibleIndicatorsDiscoverySucceeded = YES;
        }
        else if (refOp.operationStatusCode >= 500){
            _availibleIndicatorsDiscoverySucceeded = NO;
        }
        
    };
    
    errorBlock_t errorBlock = ^(NSError *error){
        NSLog(@"%@" , error.description);
    };
    if (!indicatorLoadingQueue) {
        indicatorLoadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //indicatorLoadingQueue = dispatch_queue_create("loaderQ", NULL);
    }
    dispatch_async(indicatorLoadingQueue, ^
                   {
                       [_indicators removeAllObjects];
                       _availibleIndicatorsDiscovered = NO;
                       NSLog(@"%@/indicator",_currentSubscriberContext.ExternalBaseURL);
                       refOp = [Util get:[NSString stringWithFormat:@"%@/indicators",[_currentSubscriberContext rootURLForCurrentSubscriberContext]] successBlock:succeded errorBlock:errorBlock completeBlock:completed];
                       while (!refOp.operationCompleted) {
                           //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
                           [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
                       }
                   });
}

-(NSArray *)getIndicatorsSections:(BOOL)waitForIndicatorsDiscover{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (Indicator *indicator in _indicators) {
        if (![result containsObject:indicator.section]) {
            [result addObject:indicator.section];
        }
    }
    return result;
}

-(NSString *)getShinobiKey{
    if (!_chartKey) {
        if (_currentSubscriberContext) {
            dispatch_async(contextsLoaderQueue, ^{
                [Util get:[NSString stringWithFormat:@"%@/chartinghelper?key=shinobikey", [_currentSubscriberContext rootURLForCurrentSubscriberContext]]
             successBlock:^(NSData *data, id jsonData) {
                 NSString *auxStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                 _chartKey = [auxStr substringWithRange:NSMakeRange(1, auxStr.length-2)];
             }
               errorBlock:^(NSError *error) {
                   _chartKey = error.description;
               }
            completeBlock:^{
            }];
                while (!_chartKey) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
                }
            });
            while (!_chartKey) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
            }
        }
        else{
            return nil;
        }
    }
    return _chartKey;
}

@end





















