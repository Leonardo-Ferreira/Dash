//
//  SubscriberContextCell.h
//  Foil
//
//  Created by Leonardo Ferreira on 8/24/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SubscriberContext.h"

@interface SubscriberContextCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *contextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cellActivityIndicator;
@property (atomic, readonly) NSString *title;
@property (atomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, readwrite) SubscriberContext *referenceContext;
-(void)setTitle :(NSString *)title;
-(void)setThumbnailImage :(NSString *)imageURL imageHash:(NSString *)imageHash;

@end
