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

@synthesize title=_title;
@synthesize thumbnailImage=_thumbnailImage;
@synthesize referenceContext;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    titleSet=NO;
    [_cellActivityIndicator startAnimating];
    contextNameLabel.text = title;
    titleSet=YES;
    [self requestCloseActivityIndicator];
}

-(void)setThumbnailImage:(NSString *)imageURL imageHash:(NSString *)imageHash{
    imageSet = NO;
    [_cellActivityIndicator startAnimating];
    Interaction *interactionRef = [Interaction getInstance];
    [interactionRef getImageFromURLAsync:imageURL imageHash:imageHash finishBlock:^(UIImage *image){
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           if(image.size.height > contextImageView.bounds.size.height || image.size.width > contextImageView.bounds.size.width){
                               contextImageView.contentMode = UIViewContentModeScaleAspectFit;
                               contextImageView.clipsToBounds = YES;
                           }
                           [contextImageView setImage:image];
                           [contextImageView setContentMode:UIViewContentModeScaleAspectFit];
                       });
        imageSet=YES;
        [self requestCloseActivityIndicator];
    }];
}



















@end
