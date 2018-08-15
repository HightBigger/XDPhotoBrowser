//
//  UIView+XDExtension.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/9.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XDExtension)

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

@end
