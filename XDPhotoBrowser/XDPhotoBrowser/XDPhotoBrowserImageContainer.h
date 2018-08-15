//
//  XDPhotoBrowserImageContainer.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/8.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDPhotoBrowserModel.h"

@interface XDPhotoBrowserImageContainer : UIScrollView

@property (nonatomic,assign) BOOL imageViewIsMoving;

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) XDPhotoBrowserModel *model;
//单击
@property (nonatomic,copy) void (^singleTap)(void);

- (void)showLoading;

- (void)hideLoading;

- (void)showEnterAnimationWithCompletionBlock:(void (^)(void))completion;

- (void)dismissAnimationWithCompletionBlock:(void (^)(void))completion;

@end
