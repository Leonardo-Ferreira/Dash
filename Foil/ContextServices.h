//
//  ContextServices.h
//  Foil
//
//  Created by Leonardo Ferreira on 7/29/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContextServices : NSObject


//-(NSString *)GetIndicator:(NSString *)indicatorTitle;
-(NSDictionary *)GetIndicatorChartData:(NSString *)indicatorTitle;


@end
