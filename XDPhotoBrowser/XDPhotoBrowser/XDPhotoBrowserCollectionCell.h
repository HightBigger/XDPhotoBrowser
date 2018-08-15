//
//  XDPhotoBrowserCollectionCell.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/8.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDPhotoBrowserModel.h"
#import "XDPhotoBrowserImageContainer.h"

@interface XDPhotoBrowserCollectionCell : UICollectionViewCell

@property (nonatomic,strong) XDPhotoBrowserImageContainer *container;

@property (nonatomic,strong) XDPhotoBrowserModel *model;
//单击
@property (nonatomic,copy) void (^singleTap)(void);

@end
