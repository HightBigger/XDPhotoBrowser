//
//  XDPhotoBrowserModel.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/9.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDPhotoBrowserDefinition.h"

@interface XDPhotoBrowserModel : NSObject

@property (nonatomic, assign) XDPhotoBrowserShowType showType;

@property (nonatomic, strong) UIImage *thumbnailImage;
/** 图片下载完成后，将该值放在这里 */
@property (nonatomic, strong) UIImage *image;
/** 原尺寸（相对于window的原尺寸） */
@property (nonatomic, assign) CGRect oldFrame;
/** 是否展示入场的缩放动画 */
@property (nonatomic, assign) BOOL showEnterAnimation;
/** 是否正在下载 */
@property (nonatomic, assign) BOOL isLoading;
///** 该值表示图片是否加载成功，正在下载或失败都为NO */
//@property (nonatomic, assign, readonly) BOOL loadSuccess;
///** 是否为动图 */
//@property (nonatomic, assign, readonly) BOOL isGif;
///** 动图data */
//@property (nonatomic, strong, readonly) NSData *gifData;
/** 开始下载回调（显示loading） */
@property (nonatomic , copy)void (^loadImageBegainLoadBlock)(void);
/** 下载完成回调（隐藏loading，展示原图） */
@property (nonatomic , copy)void (^loadImageCompletedBlock)(XDPhotoBrowserModel *loadModel);

- (void)configModelWithData:(NSData *)data andImage:(UIImage *)image;

@end
