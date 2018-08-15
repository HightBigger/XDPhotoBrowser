# XDPhotoBrowser

```
可定制的图片浏览器，可以自己控制图片的下载方式，支持动图（SDWebImage方式），两种出场方式，scale方式和普通present方式   
```
##### 控件基本结构：
    
```
        |------XDPhotoBrowserImageContainer------|
        |------XDPhotoBrowserCollectionCell------|
        |------------UICollectionView------------|
        |-------------XDPhotoBrowser-------------|
```
##### 自定义下载方式：

```
/**
 图片浏览器将要加载到某一需要下载的图片的时候调用，图片在下载中，下载成功，下载失败，都不会再走该回调

 @param browser 当前的图片浏览器
 @param index 当前图片的索引
 @param completionHandler 下载完成回调
 */
- (void)photoBrowser:(XDPhotoBrowser *)browser
       willLoadImage:(NSInteger)index
  loadImageCompleted:(void (^)(UIImage *image, NSData *data))completionHandle;
```
##### XDPhotoBrowserManager：
重写该类可以实现高度定制


