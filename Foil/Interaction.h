//
//  Interaction.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/26/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "ActionPerformed.h"
#import "User.h"
#import "SubscriberContext.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Util.h"
#import "BasicImageInfo.h"
#import "IdentityServices.h"
#import "Indicator.h"
#import "IndicatorData.h"

@interface Interaction : NSObject

@property (nonatomic,readonly) User *currentUser;
@property (nonatomic,readonly) SubscriberContext *currentSubscriberContext;
@property (nonatomic) NSDate *startDateTime;
@property (nonatomic) NSDate *finishDateTime;
@property (nonatomic) CLLocation *startLocation;
@property (nonatomic) CLLocation *finishLocation;
@property (atomic,readonly) NSMutableDictionary *actions;
@property (readonly) BOOL contextsLoadingCompleted;
@property (atomic,readonly) NSSet *allContextsForCurrentUser;
@property (readonly) BOOL locationAvailible;
@property (atomic,readonly) NSDate *lastAskedToEnableLocation;
@property (strong,nonatomic,readonly) NSDictionary *loadedIndicatorsDictionary;
@property (nonatomic,readonly) NSArray *availibleIndicators;
@property (nonatomic,readonly) BOOL availibleIndicatorsDiscovered;
@property (atomic, readwrite) Indicator *selectedIndicator;
@property (nonatomic, readwrite) BOOL isAssistedModeOn;

-(void)addAction:(ActionPerformed*) action;
-(void)publishInteraction;
-(void)loadAllContextsForUser:(NSString *)username;
-(void)discoverIndicators;
-(void)loadIndicatorBaseValue:(Indicator *)indicator;
-(void)loadIndicatorData :(Indicator *)indicatorBase startDate:(NSDate *)startDate finishDate:(NSDate *)finishDate;
-(BOOL)shouldAskToEnableLocation;
-(void)interactionFinished;
-(void)askToEnableLocationDate;
-(BOOL)validateUser:(NSString *)username password:(NSString *)password againstContext:(SubscriberContext *)context;
-(NSArray *)getIndicatorsSections:(BOOL)waitForIndicatorsDiscover;
-(void)reloadIndicators:(NSArray *)indicators;


+(Interaction *)getInstance;

@end
