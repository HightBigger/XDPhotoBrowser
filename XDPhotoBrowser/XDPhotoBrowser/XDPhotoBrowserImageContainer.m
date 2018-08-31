//
//  XDPhotoBrowserImageContainer.m
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/8.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import "XDPhotoBrowserImageContainer.h"
#import "UIView+XDExtension.h"
#import "XDPhotoBrowserLoading.h"
#import "XDPhotoBrowserDefinition.h"

@interface XDPhotoBrowserImageContainer()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) XDPhotoBrowserLoading *loadingView;

@end

@implementation XDPhotoBrowserImageContainer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.alwaysBounceVertical = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.panGestureRecognizer.delegate = self;
        self.minimumZoomScale = ScrollViewMinZoomScale;
        self.maximumZoomScale = ScrollViewMaxZoomScale;
        
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.imageView];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];

        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)setModel:(XDPhotoBrowserModel *)model
{
    _model = model;
    
    if (model.image)
    {
        self.imageView.image = model.image;
        [self resetScrollViewStatusWithImage:model.image];
    }
    else
    {
        //加载缩略图
        self.imageView.image = model.thumbnailImage;
        
        [self resetScrollViewStatusWithImage:model.thumbnailImage];
        
        __weak typeof(self) weakSelf = self;
        [model setLoadImageBegainLoadBlock:^{
            [weakSelf showLoading];
        }];
        
        [model setLoadImageCompletedBlock:^(XDPhotoBrowserModel *loadModel) {
            [weakSelf hideLoading];
            //图片下载完成后，加载高清图
            if (loadModel.image)
            {
                weakSelf.imageView.image = loadModel.image;
                [weakSelf resetScrollViewStatusWithImage:loadModel.image];
            }
        }];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
//    // 图片在移动的时候停止居中布局
    if (self.imageViewIsMoving == YES) return;
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter =  self.imageView.frame;
    // Horizontally floor：如果参数是小数，则求最大的整数但不大于本身.
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    // Center
    if (!CGRectEqualToRect( self.imageView.frame, frameToCenter)){
        self.imageView.frame = frameToCenter;
    }
    
}


#pragma mark - method
- (void)resetScrollViewStatusWithImage:(UIImage *)image
{
    self.zoomScale = ScrollViewMinZoomScale;
    
    self.imageView.frame = CGRectMake(0, 0, self.width, 0);
    if (image.size.height / image.size.width > self.height / self.width) {
        self.imageView.height = floor(image.size.height / (image.size.width / self.width));
    }else {
        CGFloat height = image.size.height / image.size.width * self.width;;
        self.imageView.height = floor(height);
        self.imageView.centerY = self.height / 2;
    }
    if (self.imageView.height > self.height && self.imageView.height - self.height <= 1) {
        self.imageView.height = self.height;
    }
    self.contentSize = CGSizeMake(self.width, MAX(self.imageView.height, self.height));
    [self setContentOffset:CGPointZero];
    
    if (self.imageView.height > self.height) {
        self.alwaysBounceVertical = YES;
    } else {
        self.alwaysBounceVertical = NO;
    }
    if (self.imageView.contentMode != UIViewContentModeScaleToFill)
    {
        self.imageView.contentMode =  UIViewContentModeScaleToFill;
        self.imageView.clipsToBounds = NO;
    }
}

- (void)showEnterAnimationWithCompletionBlock:(void (^)(void))completion
{
    CGRect currentFrame = self.imageView.frame;
    CGRect oldFrame = self.model.oldFrame;
    
    self.imageView.frame = oldFrame;
    self.superview.superview.superview.backgroundColor = [UIColor blackColor];
    
    __weak typeof(self) wself = self;
    
    self.imageViewIsMoving = YES;
    [UIView animateWithDuration:0.2 animations:^{
        wself.imageView.frame = currentFrame;
    }completion:^(BOOL finished) {
        wself.imageViewIsMoving = NO;
        [wself layoutSubviews];
        if (completion)
            completion();
    }];
}

- (void)dismissAnimationWithCompletionBlock:(void (^)(void))completion
{
    if (self.model.showType == PhotoBrowserShowTypeScale)
    {
        CGRect oldFrame = self.model.oldFrame;
        self.imageViewIsMoving = YES;
        
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.2 animations:^{
            wself.zoomScale = ScrollViewMinZoomScale;
            wself.contentOffset = CGPointZero;
            wself.imageView.frame = oldFrame;
            wself.imageView.contentMode = UIViewContentModeScaleAspectFill;
            wself.imageView.clipsToBounds = YES;
            wself.superview.superview.superview.backgroundColor = [UIColor clearColor];
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                wself.imageView.alpha = 0;
            } completion:^(BOOL finished) {
                if (completion)
                    completion();
            }];
        }];
    }
    else
    {
        if (completion)
            completion();
    }
}

#pragma mark - action
/** 单击 */
- (void)didSingleTap:(UITapGestureRecognizer *)tap
{
    if (self.singleTap)
        self.singleTap();
}

/** 双击 */
- (void)didDoubleTap:(UITapGestureRecognizer *)tap
{
    CGPoint touchPoint = [tap locationInView:(UIView *)self.imageView];
    
    if (self.maximumZoomScale == self.minimumZoomScale) {
        return;
    }
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = self.maximumZoomScale ;
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)showLoading
{
    [self addSubview:self.loadingView];
}

- (void)hideLoading
{
    [self.loadingView removeFromSuperview];
}

#pragma mark - ScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//scrollView捏合手势
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if (scrollView.minimumZoomScale != scale) return;
    [self setZoomScale:self.minimumZoomScale animated:YES];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


#pragma mark - lazyload
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView  = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor redColor];
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (XDPhotoBrowserLoading *)loadingView
{
    if (!_loadingView)
    {
        _loadingView = [[XDPhotoBrowserLoading alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _loadingView.center = self.center;
    }
    return _loadingView;
}

@end
