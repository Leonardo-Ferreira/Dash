//
//  IndicatorDisplayViewController.h
//  Foil
//
//  Created by AeC on 9/18/13.
//  Copyright (c) 2013 Leonardo Ferreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorDisplayCell.h"
#import "Interaction.h"

@interface IndicatorDisplayViewController : UIViewController<UITabBarControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, readwrite) NSString *referencedSection;
@end
