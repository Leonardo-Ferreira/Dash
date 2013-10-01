//
//  BasicImageInfo.h
//  Foil
//
//  Created by Leonardo Ferreira on 9/2/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicImageInfo : NSObject
@property(nonatomic) NSString *ImageUrl;
@property(nonatomic) NSString *ImageHash;
@property(atomic) UIImage *Image;
@end
