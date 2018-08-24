//
//  XDPhotoBrowserManager.m
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/13.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import "XDPhotoBrowserManager.h"
#import "XDPhotoBrowser.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+GIF.h>

@interface XDPhotoBrowserManager()<XDPhotoBrowserLoadDelegate>

@property (nonatomic,strong) XDPhotoBrowser *photoBrowser;

@property (nonatomic,strong) NSArray *imageURLs;

@property (nonatomic,strong) UICollectionView *imageSuperView;

@end

@implementation XDPhotoBrowserManager

+ (XDPhotoBrowserManager *)shareIntance
{
    static XDPhotoBrowserManager* shareIntance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareIntance = [[XDPhotoBrowserManager alloc] init];
    });
    return shareIntance;
}

- (void)showImageWithWebImageCodes:(NSArray *)imageCodes
                     selectedIndex:(NSInteger)index
                         superView:(UICollectionView *)superview
                 fromViewContoller:(UIViewController *)viewController
                          showType:(XDPhotoBrowserShowType)showType
                   titleClickBlock:(titleClickBlock)bolck
{
    self.imageSuperView = superview;
    self.imageURLs = imageCodes;
    
    NSArray *titles = @[@"保存",@"发送"];
    
    _photoBrowser = [[XDPhotoBrowser alloc]init];
    _photoBrowser.currentIndex = index;
    _photoBrowser.totalCount = imageCodes.count;
    _photoBrowser.hidePageControl = imageCodes.count<=1;
    _photoBrowser.showMore = NO;
    _photoBrowser.loadDelegate = self;
    
    __weak XDPhotoBrowser* weakBrowser = _photoBrowser;
    [_photoBrowser setLongPressGesture:^(NSInteger currentIndex, UIImage *currentImage) {
       
        [weakBrowser showActionSheet:nil
                        buttonTitles:titles
                               block:^(UIAlertController *actionSheet, NSInteger buttonIndex) {
                                   NSLog(@"点击了第%ld个选项",(long)buttonIndex);
                                   bolck(buttonIndex,currentIndex,currentImage);
                               }];
    }];
    
    __weak typeof(self) weakSelf = self;
    [_photoBrowser setPhotoBrowserDidDisMiss:^{
        weakSelf.photoBrowser = nil;
    }];
    
    [_photoBrowser showFromViewController:viewController withShowType:PhotoBrowserShowTypeScale];
}

#pragma mark - XDPhotoBrowserLoadDelegate
//缩略图
- (UIImage *)photoBrowser:(XDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell *cell = [self.imageSuperView cellForItemAtIndexPath:indexPath];
    UIImageView *imgView = [cell.contentView viewWithTag:tagOfImageOfCell];
    return imgView.image;
}
//高清图
- (UIImage *)photoBrowser:(XDPhotoBrowser *)browser highQualityImageForIndex:(NSInteger)index
{
    NSString *imagePath = self.imageURLs[index];
    
    NSData *cacheImageData = [[SDWebImageManager sharedManager].imageCache diskImageDataForKey:imagePath];
    
    UIImage *cacheImage = [UIImage sd_animatedGIFWithData:cacheImageData];
    
    return cacheImage;
}
//缩略图相对于屏幕的frame
- (CGRect)photoBrowser:(XDPhotoBrowser *)browser oldFrameOfIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell *cell = [self.imageSuperView cellForItemAtIndexPath:indexPath];
    CGRect rect = [self.imageSuperView convertRect:cell.frame toView:[UIApplication sharedApplication].keyWindow];
    return rect;
}
//高清图需要下载的回调，下载可以自己实现
- (void)photoBrowser:(XDPhotoBrowser *)browser willLoadImage:(NSInteger)index loadImageCompleted:(void (^)(UIImage *, NSData *))completionHandler {
    
    NSString *imagePath = self.imageURLs[index];
    
    NSURL *url = [NSURL URLWithString:imagePath];
    SDWebImageOptions option = SDWebImageAllowInvalidSSLCertificates;
    if (url.fileURL)
        option |= SDWebImageRetryFailed;
    
    [[SDWebImageManager sharedManager] loadImageWithURL:url
                                                options:option
                                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                   
                                               } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                   completionHandler(image,data);
                                               }];
}
@end
