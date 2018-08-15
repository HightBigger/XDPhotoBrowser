//
//  ViewController.m
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/14.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import "ViewController.h"
#import "XDPhotoBrowserDefinition.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+GIF.h>
#import "XDPhotoBrowserManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *lagerURLStrings;
@property (nonatomic, strong) NSArray *thumbnailURLStrings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lagerURLStrings = @[
                             //大图
                             @"http://p7.pstatp.com/large/w960/5322000131e01b7a477d.gif",
                             @"http://p7.pstatp.com/large/w960/5321000135125ebb938a.gif",
                             @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                             @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                             @"http://p2.pstatp.com/large/w960/4ecc00055b3ffcc909a9",
                             @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                             @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                             @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                             @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                             @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"
                             ];
    self.thumbnailURLStrings = @[
                                 //小图
                                 @"http://p7.pstatp.com/list/s200/5322000131e01b7a477d.gif",
                                 @"http://p7.pstatp.com/list/s200/5321000135125ebb938a.gif",
                                 @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                                 @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                                 @"http://p2.pstatp.com/list/s200/4ecc00055b3ffcc909a9",
                                 @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                                 @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                                 @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                                 @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                                 @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"
                                 ];
    
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnailURLStrings.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UIImageView *imgView = [cell.contentView viewWithTag:tagOfImageOfCell];
    UILabel *label = [cell.contentView viewWithTag:tagOfLabelOfCell];
    if (!imgView) {
        CGFloat height = cell.contentView.bounds.size.height, width = cell.contentView.bounds.size.width;
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds = YES;
        imgView.tag = tagOfImageOfCell;
        [cell.contentView addSubview:imgView];
        CGFloat labelWidth = 34, labelHeight = 25;
        label = [[UILabel alloc] initWithFrame:CGRectMake(width-labelWidth, height-labelHeight, labelWidth, labelHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 5;
        label.tag = tagOfLabelOfCell;
        [cell.contentView addSubview:label];
    }
    label.hidden = YES;
    //长图也可以在这里判断
    NSString *urlStr = self.thumbnailURLStrings[indexPath.row];
    if ([urlStr hasSuffix:@".gif"]) {
        label.hidden = NO;
        label.text = @"gif";
    }
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableViewHeader" forIndexPath:indexPath];
        UILabel *label = [view viewWithTag:tagOfLabelOfHeader];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.bounds.size.width - 40, view.bounds.size.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor orangeColor];
            label.font = [UIFont boldSystemFontOfSize:17];
            label.tag = tagOfLabelOfHeader;
            [view addSubview:label];
        }
        label.text = @"网络图片";
        return view;
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(XDScreenWidth, 44);
}

// UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[XDPhotoBrowserManager shareIntance] showImageWithWebImageCodes:self.lagerURLStrings
                                                       selectedIndex:indexPath.row
                                                           superView:collectionView
                                                   fromViewContoller:self
                                                            showType:PhotoBrowserShowTypeScale
                                                     titleClickBlock:^(NSInteger titleIndex, NSInteger imageIndex, UIImage *image) {
                                                         
                                                     }];
}

#pragma mark - lazyload
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CELLSIZE;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, XDScreenWidth, XDScreenHeight - 40) collectionViewLayout:layout];
        [_collectionView registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableViewHeader"];
        [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"UICollectionViewCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}
@end
