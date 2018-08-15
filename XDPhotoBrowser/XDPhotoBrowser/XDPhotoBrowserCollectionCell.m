//
//  XDPhotoBrowserCollectionCell.m
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/8.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import "XDPhotoBrowserCollectionCell.h"
#import "XDPhotoBrowserDefinition.h"

@interface XDPhotoBrowserCollectionCell ()
@end

@implementation XDPhotoBrowserCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        _container = [[XDPhotoBrowserImageContainer alloc]initWithFrame:CGRectMake(BrowserSpace/2, 0, XDScreenWidth, XDScreenHeight)];
        [self.contentView addSubview:_container];
    }
    return self;
}

- (void)setModel:(XDPhotoBrowserModel *)model
{
    _model = model;
    self.container.model = model;
}

- (void)setSingleTap:(void (^)(void))singleTap
{
    _singleTap = singleTap;
    _container.singleTap = _singleTap;
}

@end
