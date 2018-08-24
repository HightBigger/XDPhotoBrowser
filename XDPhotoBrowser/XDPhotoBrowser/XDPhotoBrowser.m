//
//  XDPhotoBrowser.m
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/8.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import "XDPhotoBrowser.h"
#import "XDPhotoBrowserCollectionCell.h"
#import "XDPhotoBrowserModel.h"
#import "UIView+XDExtension.h"
#import "OTScreenshotHelper.h"
#import <SDWebImage/NSData+ImageContentType.h>

@interface XDPhotoBrowser ()<UICollectionViewDelegate,UICollectionViewDataSource>

//用来放上一个界面的截图
@property (nonatomic,strong) UIImageView *backImageView;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) UIButton *moreImagesBtn;

@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,assign) CGPoint startPoint;

@property (nonatomic,assign) CGFloat zoomScale;

@property (nonatomic,assign) CGPoint startCenter;
//进入页面的弹出动画
@property (nonatomic,assign) BOOL showAnimation;

@property (nonatomic,assign) XDPhotoBrowserShowType showType;

@end

@implementation XDPhotoBrowser

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showAnimation = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.backImageView];
    
    if (self.showType == PhotoBrowserShowTypeScale)
    {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [self.view addGestureRecognizer:pan];
    }
    
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongTap:)];
    [self.view addGestureRecognizer:longTap];
    
    [self.view addSubview:self.collectionView];
    
    if (self.totalCount > 1 && !self.hidePageControl)
        [self.view addSubview:self.pageControl];
    
    if (self.showMore)
        [self.view addSubview:self.moreImagesBtn];    
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configStatusBarHide:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self configStatusBarHide:NO];
}

- (void)showFromViewController:(UIViewController *)vc withShowType:(XDPhotoBrowserShowType)showType
{
    self.showType = showType;
    
    BOOL animated = showType == PhotoBrowserShowTypeNormal;
    
    [vc presentViewController:self animated:animated completion:nil];
}

- (void)configStatusBarHide:(BOOL)hide {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.alpha = !hide;
}

#pragma mark - action
- (void)didPan:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:self.view];
    CGPoint point = [pan translationInView:self.view];
    
    XDPhotoBrowserCollectionCell *cell = (XDPhotoBrowserCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            _startPoint = location;
            _zoomScale = cell.container.zoomScale;
            _startCenter = cell.container.imageView.center;
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //向下滑动有效
            if (location.y - _startPoint.y < 0 )  return;
            
            cell.container.imageViewIsMoving = YES;
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;// 移动距离 / 整个屏幕
            double scalePercent = MAX(percent, 0.3);
            if (location.y - _startPoint.y < 0) {
                scalePercent = 1.0 * _zoomScale;
            }else {
                scalePercent = _zoomScale * scalePercent;
            }
            CGAffineTransform scale = CGAffineTransformMakeScale(scalePercent, scalePercent);
            cell.container.imageView.transform = scale;
            cell.container.imageView.center = CGPointMake(self.startCenter.x + point.x, self.startCenter.y + point.y);
            self.collectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:scalePercent / _zoomScale];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            if (point.y > 100 ) {
                [self disMissFromCell:cell];
            }else {
                [self cancelFromCell:cell];
            }
        }
            break;
        default:
            break;
    
    }
}

- (void)didLongTap:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        if (self.longPressGesture)
        {
            XDPhotoBrowserCollectionCell *cell = (XDPhotoBrowserCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]];
            self.longPressGesture(self.pageControl.currentPage, cell.model.image);
        }
    }
}

- (void)disMissFromCell:(XDPhotoBrowserCollectionCell *)cell
{
    self.pageControl.hidden = YES;
    __weak typeof(self) weakSelf = self;
    [cell.container dismissAnimationWithCompletionBlock:^{
        BOOL animated = weakSelf.showType == PhotoBrowserShowTypeNormal;
        [weakSelf dismissViewControllerAnimated:animated completion:^{
            if (weakSelf.photoBrowserDidDisMiss)
                weakSelf.photoBrowserDidDisMiss();
        }];
    }];
}

- (void)cancelFromCell:(XDPhotoBrowserCollectionCell *)cell {
    __weak typeof(self) weakSelf = self;
    CGAffineTransform scale = CGAffineTransformMakeScale(_zoomScale , _zoomScale);
    [UIView animateWithDuration:0.25 animations:^{
        cell.container.imageView.transform = scale;
        weakSelf.collectionView.backgroundColor = [UIColor blackColor];
        cell.container.imageView.center = weakSelf.startCenter;
    }completion:^(BOOL finished) {
        cell.container.imageViewIsMoving = NO;
        [cell.container layoutSubviews];
    }];
}

- (void)didClickMoreImagesBtn:(UIButton*)moreBtn
{
    if (self.clickMoreImageBtn)
        self.clickMoreImageBtn();
}

//显示actionSheet，有需求的这里可以自定义事件
- (void)showActionSheet:(NSString *)title
           buttonTitles:(NSArray *)btnArray
                  block:(void(^)(UIAlertController *actionSheet,NSInteger buttonIndex))block
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:title
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak UIAlertController *weakSheet = actionSheet;
    
    for (int i = 0; i<btnArray.count; i++)
    {
        NSString *title = btnArray[i];
        [actionSheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            block(weakSheet,i);
        }]];
    }

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.totalCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    
    XDPhotoBrowserCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XDPhotoBrowserCollectionCell" forIndexPath:indexPath];
    
    UIImage *thumbnailImage = [UIImage imageNamed:@"xd_photobrowser_placehoder"];
    if ([self.loadDelegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)])
    {
        thumbnailImage = [self.loadDelegate photoBrowser:self placeholderImageForIndex:indexPath.row];
    }
    
    XDPhotoBrowserModel *model = [[XDPhotoBrowserModel alloc] init];
    
    model.showType = self.showType;
    
    if ([self.loadDelegate respondsToSelector:@selector(photoBrowser:oldFrameOfIndex:)])
    {
        model.oldFrame = [self.loadDelegate photoBrowser:self oldFrameOfIndex:indexPath.row];
    }
    
    model.thumbnailImage = thumbnailImage;
    
    if ([self.loadDelegate respondsToSelector:@selector(photoBrowser:highQualityImageForIndex:)])
    {
        model.image = [self.loadDelegate photoBrowser:self highQualityImageForIndex:indexPath.row];
    }
    
    model.showEnterAnimation = self.currentIndex == indexPath.row;
    
    cell.model = model;
    
    __weak XDPhotoBrowserCollectionCell *wCell = cell;
    
    [cell setSingleTap:^{
        [weakSelf disMissFromCell:wCell];
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(XDScreenWidth + BrowserSpace, XDScreenHeight);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    XDPhotoBrowserCollectionCell *collectionCell = (XDPhotoBrowserCollectionCell*)cell;
    
    __weak typeof(self) weakSelf = self;
    XDPhotoBrowserModel *model = collectionCell.model;
    if (model.showEnterAnimation && _showAnimation && self.showType == PhotoBrowserShowTypeScale)
    {
        [collectionCell.container showEnterAnimationWithCompletionBlock:^{
            weakSelf.showAnimation = NO;
            model.showEnterAnimation = NO;
            [weakSelf collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
        }];
    }
    else
    {
        //没有图片，没有正在加载
        if (!model.image && !model.isLoading)
        {
            if ([self.loadDelegate respondsToSelector:@selector(photoBrowser:willLoadImage:loadImageCompleted:)])
            {
                model.isLoading = YES;
                [self.loadDelegate photoBrowser:self willLoadImage:indexPath.row loadImageCompleted:^(UIImage *image, NSData *data)
                 {
                     [model configModelWithData:data andImage:image];
                     model.isLoading = NO;
                 }];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.collectionView.width;
    int page = floor((self.collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentIndex = page;
    self.pageControl.currentPage = page;
}

#pragma mark - lazyLoad
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        // there page sapce is equal to 20
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-BrowserSpace / 2.0, 0, XDScreenWidth + BrowserSpace, XDScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor blackColor];
        [_collectionView registerClass:[XDPhotoBrowserCollectionCell class] forCellWithReuseIdentifier:@"XDPhotoBrowserCollectionCell"];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, XDScreenHeight - 30 - iPhone_X_Present, XDScreenWidth, 10)];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.numberOfPages = self.totalCount;
        _pageControl.currentPage = self.currentIndex;
    }
    return _pageControl;
}

- (UIButton *)moreImagesBtn
{
    if (!_moreImagesBtn)
    {
        _moreImagesBtn = [[UIButton alloc]initWithFrame:CGRectMake(XDScreenWidth - 20 - 28,XDStatusHeight + 20, 28, 28)];
        [_moreImagesBtn setImage:[UIImage imageNamed:@"xd_images_more"] forState:UIControlStateNormal];
        [_moreImagesBtn addTarget:self action:@selector(didClickMoreImagesBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreImagesBtn;
}

- (UIImageView *)backImageView
{
    if (!_backImageView)
    {
        _backImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        
        UIImage *image = [OTScreenshotHelper screenshot];
        
        _backImageView.image = image;
        
    }
    return _backImageView;
}

@end
