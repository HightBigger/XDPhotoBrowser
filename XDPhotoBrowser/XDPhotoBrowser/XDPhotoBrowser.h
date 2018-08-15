//
//  XDPhotoBrowser.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/8.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDPhotoBrowserDefinition.h"
/**
 控件的基本结构
 |-------------------------XDPhotoBrowserImageContainer(clear)------------------------|
 |-------------------------XDPhotoBrowserCollectionCell(clear)------------------------|
 |--------------------------------UICollectionView(black)-----------------------------|
 |--------------------------------XDPhotoBrowser(black)-------------------------------|
 */

@class XDPhotoBrowser;

@protocol XDPhotoBrowserLoadDelegate <NSObject>
@optional
/**
 图片缩略图，高清图加载过程中，会使用该图片作为占位图

 @param browser 当前的图片浏览器
 @param index 当前图片的索引
 @return 图片缩略图
 */
- (UIImage *)photoBrowser:(XDPhotoBrowser *)browser
 placeholderImageForIndex:(NSInteger)index;


/**
 原图片相对于window的frame，可以用以下方法获取（PhotoBrowserShowTypeScale方式下，必须实现该方法）

 CGRect rect = [self.imageSuperView convertRect:imageView.frame toView:[UIApplication sharedApplication].keyWindow];
 
 @param browser 当前的图片浏览器
 @param index 当前图片的索引
 @return 原图片相对于window的frame
 */
- (CGRect)photoBrowser:(XDPhotoBrowser *)browser
       oldFrameOfIndex:(NSInteger)index;

/**
 图片高清图，从缓存获取，若有缓存，则传缓存图片，没有缓存传nil

 @param browser 当前的图片浏览器
 @param index 当前图片的索引
 @return 图片高清图
 */
- (UIImage *)photoBrowser:(XDPhotoBrowser *)browser
 highQualityImageForIndex:(NSInteger)index;
/**
 图片浏览器将要加载到某一需要下载的图片的时候调用，图片在下载中，下载成功，下载失败，都不会再走该回调

 @param browser 当前的图片浏览器
 @param index 当前图片的索引
 @param completionHandler 下载完成回调
 */
@required
- (void)photoBrowser:(XDPhotoBrowser *)browser
       willLoadImage:(NSInteger)index
  loadImageCompleted:(void (^)(UIImage *image, NSData *data))completionHandler;

@end

@interface XDPhotoBrowser : UIViewController

@property (nonatomic,weak) id<XDPhotoBrowserLoadDelegate> loadDelegate;

/** 图片总数 */
@property (nonatomic,assign) NSInteger totalCount;
/** 隐藏pageControl，默认不隐藏 */
@property (nonatomic,assign) BOOL hidePageControl;
/** 显示右上角按钮，默认不显示 */
@property (nonatomic,assign) BOOL showMore;
/** 默认选中的index，默认为0 */
@property (nonatomic,assign) NSInteger currentIndex;
/** 点击右上角更多按钮回调 */
@property (nonatomic,copy) void (^clickMoreImageBtn)(void);
/** 长按手势，currentIndex为当前展示图片索引，若返回currentImage为nil，则当前展示图片为下载成功 */
@property (nonatomic,copy)  void (^longPressGesture)(NSInteger currentIndex,UIImage *currentImage);

/**
 图片浏览器显示方式，当前只支持该方法present方式，不得自主显示

 @param vc 展示图片浏览器的viewController
 @param showType 展示方式
 */
- (void)showFromViewController:(UIViewController *)vc
                  withShowType:(XDPhotoBrowserShowType)showType;


/**
 显示actionSheet

 @param title 标题
 @param btnArray 按钮数组
 @param block 回调
 */
- (void)showActionSheet:(NSString *)title
           buttonTitles:(NSArray *)btnArray
                  block:(void(^)(UIAlertController *actionSheet,NSInteger buttonIndex))block;
@end
