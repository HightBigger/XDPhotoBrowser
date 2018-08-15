//
//  XDPhotoBrowserManager.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/13.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDPhotoBrowserDefinition.h"

typedef void (^titleClickBlock)(NSInteger titleIndex,NSInteger imageIndex,UIImage* image);

/** 该类需要用户自己按照需求自己实现 */
@interface XDPhotoBrowserManager : NSObject

+ (XDPhotoBrowserManager *)shareIntance;

/**
 web图片使用该方法
 
 @param imageCodes 图片的uuid数组
 @param index index
 */

/**
 web图片使用该方法

 @param imageCodes 图片的url数组
 @param index 选中的index
 @param superview 父视图
 @param viewController 来源vc
 @param showType 展示方式
 */
- (void)showImageWithWebImageCodes:(NSArray *)imageCodes
                     selectedIndex:(NSInteger)index
                         superView:(UIView *)superview
                 fromViewContoller:(UIViewController *)viewController
                          showType:(XDPhotoBrowserShowType)showType
                   titleClickBlock:(titleClickBlock)bolck;

@end
