//
//  XDPhotoBrowserModel.m
//  XDPhotoBrowser
//
//  Created by xiaoda on 2018/8/9.
//  Copyright © 2018年 xiaoda.chen. All rights reserved.
//

#import "XDPhotoBrowserModel.h"
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDWebImage/UIImage+GIF.h>

@implementation XDPhotoBrowserModel

- (void)configModelWithData:(NSData *)data andImage:(UIImage *)image
{
    if (!data && !image) {
        _image = [UIImage imageNamed:@""];
    }
    else
    {
        if ([NSData sd_imageFormatForImageData:data] == SDImageFormatGIF)
        {
            _image = [UIImage sd_animatedGIFWithData:data];
        }
        else
        {
            _image = image;
        }
    }
    
    if (self.loadImageCompletedBlock)
        self.loadImageCompletedBlock(self);    
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    
    if (self.loadImageBegainLoadBlock && isLoading)
        self.loadImageBegainLoadBlock();
}

@end
