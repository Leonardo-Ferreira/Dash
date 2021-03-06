//
//  SubscriberContextCell.m
//  Foil
//
//  Created by Leonardo Ferreira on 8/24/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import "SubscriberContextCell.h"
#import "Interaction.h"

@implementation SubscriberContextCell{
    BOOL imageSet, titleSet;
    IBOutlet UILabel *contextNameLabel;
    IBOutlet UIImageView *contextImageView;
}

@synthesize title = _title;
@synthesize thumbnailImage = _thumbnailImage;
@synthesize referenceContext;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageSet = NO;
        titleSet = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)requestCloseActivityIndicator{
        //1 for the label set and 1 for image set
    if(imageSet && titleSet){
        [_cellActivityIndicator stopAnimating];
    }
}

-(void)setTitle:(NSString *)title{
    if(!titleSet){
        [_cellActivityIndicator startAnimating];
        contextNameLabel.text = title;
        titleSet=YES;
        [self requestCloseActivityIndicator];
    }
}

-(void)setThumbnailImage:(NSString *)imageURL imageHash:(NSString *)imageHash{
    if(!imageSet){
        [_cellActivityIndicator startAnimating];
        [Util loadImageFromURL:imageURL imageHash:imageHash subscriberContext:referenceContext finishBlock:^(BasicImageInfo *image){
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               if(image.Image.size.height > contextImageView.bounds.size.height || image.Image.size.width > contextImageView.bounds.size.width){
                                   contextImageView.contentMode = UIViewContentModeScaleAspectFit;
                                   contextImageView.clipsToBounds = YES;
                               }
                               [contextImageView setImage:image.Image];
                               [contextImageView setContentMode:UIViewContentModeScaleAspectFit];
                               imageSet = YES;
                               [self requestCloseActivityIndicator];
                           });
        }];
    }
}



















@end
