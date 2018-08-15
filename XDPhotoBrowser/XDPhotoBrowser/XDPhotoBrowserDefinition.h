//
//  XDPhotoBrowserDefinition.h
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/14.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#ifndef XDPhotoBrowserDefinition_h
#define XDPhotoBrowserDefinition_h

//图片间隙
#define BrowserSpace 20

//图片最小缩放倍数
#define ScrollViewMinZoomScale 1.0
//图片最大缩放倍数
#define ScrollViewMaxZoomScale 3.0

#define XDScreenWidth [UIScreen mainScreen].bounds.size.width
#define XDScreenHeight [UIScreen mainScreen].bounds.size.height
#define XDStatusHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#define ISIPHONEX ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.width == 812)
#define iPhone_X_Present   (ISIPHONEX ? 34:0)

#define CELLSIZE CGSizeMake(XDScreenWidth/3, (XDScreenWidth/3))

static int tagOfImageOfCell = 1000;
static int tagOfLabelOfCell = 1001;
static int tagOfLabelOfHeader = 2000;


typedef enum : NSUInteger {
    PhotoBrowserShowTypeNormal, //普通present
    PhotoBrowserShowTypeScale   //缩放动画
} XDPhotoBrowserShowType;


#endif /* XDPhotoBrowserDefinition_h */
