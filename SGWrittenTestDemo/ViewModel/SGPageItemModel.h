//
//  SGPageItemModel.h
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGPageItemModel : NSObject

@property (nonatomic, copy) NSString *cellId;
/// 图片宽度
@property (nonatomic, assign) CGFloat width;
/// 图片高度
@property (nonatomic, assign) CGFloat height;
/// 高清图片链接
@property (nonatomic, strong) NSURL *regularUrl;
@property (nonatomic, strong) NSURL *fullUrl;
/// 小图链接
@property (nonatomic, strong) NSURL *smallUrl;
/// 缩略图链接
@property (nonatomic, strong) NSURL *thumbUrl;
/// 原始图片链接
@property (nonatomic, strong) NSURL *rawUrl;
/// 图片介绍
@property (nonatomic, copy) NSString *title;
@end

NS_ASSUME_NONNULL_END
