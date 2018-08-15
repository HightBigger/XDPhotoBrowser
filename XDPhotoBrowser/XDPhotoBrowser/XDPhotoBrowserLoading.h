//
//  XDPhotoBrowserLoading.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/9.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDPhotoBrowserLoading : UIView

+ (UILabel *)showText:(NSString *)text toView:(UIView *)superView dismissAfterSecond:(NSTimeInterval)second;

@end
