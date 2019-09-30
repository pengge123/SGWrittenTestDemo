//
//  SGShowPictureView.m
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import "SGShowPictureView.h"
#import <Photos/Photos.h>

@interface SGShowPictureView()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
/// 图片视图
@property(nonatomic,strong) UIImageView *imageView;
/// 保存按钮
@property(nonatomic,strong) UIButton *saveBtn;

/// 滚动视图
@property(nonatomic,strong) UIScrollView *scrollView;
/// 占位缩略图
@property(nonatomic,strong) UIImage *image;

@end

@implementation SGShowPictureView

-(instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    if (self = [super initWithFrame:frame])
    {
        _image = image;
        [self addSubviews];
        [self addGesture];
        
    }
    return self;
}

/**
 添加子视图
 */
-(void)addSubviews
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
    [self addSubview:self.scrollView];
    [self addSubview:self.saveBtn];
    [self.scrollView addSubview:self.imageView];

}

/**
 添加手势
 */
- (void)addGesture
{
    // 单击的 Recognizer
    UITapGestureRecognizer * oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    oneTap.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:oneTap];
    [self.scrollView addGestureRecognizer:oneTap];
    
    UITapGestureRecognizer * twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makePicBigger:)];
    twoTap.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:twoTap];
    // 关键在这一行，双击手势确定监测失败才会触发单击手势的相应操作
    [oneTap requireGestureRecognizerToFail:twoTap];
}

/**
 双击图片放大

 @param tap 双击手势
 */
- (void)makePicBigger:(UITapGestureRecognizer *)tap{;
    CGFloat zoomScale = self.scrollView.zoomScale;
    zoomScale = (zoomScale ==  1.0) ? 2.0 : 1.0;
    CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:[tap locationInView:tap.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
    
}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height  / scale;
    zoomRect.size.width  =self.frame.size.width   / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width   /2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height  /2.0);
    return zoomRect;
    
}

/**
 当scrollView正在缩放时

 @param scrollView scrollView
 */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frameToCenter = self.imageView.frame;
    // Horizontally
    if (CGRectGetWidth(frameToCenter) < CGRectGetWidth(self.bounds)) {
        frameToCenter.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frameToCenter)) / 2.0;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < CGRectGetHeight(self.bounds)) {
        frameToCenter.origin.y = (CGRectGetHeight(self.bounds) - frameToCenter.size.height) / 2.0;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter))
        self.imageView.frame = frameToCenter;
}
//告诉scrollview要缩放的是哪个子控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
/**
 关闭视图
 */
- (void)dismiss {
    
    [self.imageView sd_cancelCurrentImageLoad];
    [SVProgressHUD dismiss];
    [UIView animateWithDuration:0.3 animations:^{
        // CGAffineTransformMakeScale(1.2, 1.2) 缩放的比例 缩放为原来的1.2倍
        self.imageView.transform = CGAffineTransformMakeScale(300/SGScreenW, 300/SGScreenW);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/**
 保存图片
 */
- (void)savePhoto {
    [SVProgressHUD showWithStatus:@"正在保存中..."];
    if (self.imageView.image == nil) {
        [SVProgressHUD showErrorWithStatus:@"图片没有下载完毕！"];
        return;
    }
    UIImage *image = self.imageView.image;
    //获取相册权限
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [SVProgressHUD showSuccessWithStatus:@"保存图片成功！"];
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"保存图片失败！"];
                    }
                    
                });
            }];
        } else if (status == PHAuthorizationStatusDenied) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"请开启APP相册权限"];
            });
        }
    }];

}

/**
 根据模型加载大图

 @param model 模型
 */
- (void)setModel:(SGPageItemModel *)model
{
    _model = model;

    if (_image) {
        
        // 图片尺寸
        CGFloat pictureW = SGScreenW;
        CGFloat pictureH = pictureW * _image.size.height / _image.size.width;
        if (pictureH > SGScreenH) { // 图片显示高度超过一个屏幕, 需要滚动查看
            self.imageView.frame = CGRectMake(0, 0, pictureW, pictureH);
            self.scrollView.contentSize = CGSizeMake(0, pictureH);
        } else {
            self.imageView.size = CGSizeMake(pictureW, pictureH);
            self.imageView.centerY = SGScreenH * 0.5;
        }
        self.scrollView.maximumZoomScale = MAX(_image.size.width / SGScreenW * 2, 2);
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.zoomScale = 1;
    }
    NSLog(@"大图：%@",model.regularUrl.absoluteString);
    // 下载大图片
    [self.imageView sd_setImageWithURL:model.regularUrl placeholderImage:_image options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        [SVProgressHUD showProgress:1.0 * receivedSize / expectedSize status:@"正在下载高清图"];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [SVProgressHUD dismiss];
    }];
}
/**
 显示视图
 */
- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    self.imageView.transform = CGAffineTransformMakeScale(300/SGScreenW, 300/SGScreenW);
    self.alpha = 0;
    // 0.2 表示动画时长为0.2秒
    [UIView animateWithDuration:0.3 animations:^{
        // CGAffineTransformMakeScale(1.2, 1.2) 缩放的比例 缩放为原来的1.2倍
        self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];

}

- (UIImageView *)imageView
{
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        
    }
    return _imageView;
}
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 1.0;
        
    }
    return _scrollView;
}


- (UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.height - 100, 100, 50)];
        _saveBtn.centerX = self.centerX;
        [_saveBtn setTitle:@"保存图片" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_saveBtn addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

@end
