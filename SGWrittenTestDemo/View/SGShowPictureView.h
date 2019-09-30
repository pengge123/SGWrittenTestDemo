//
//  SGShowPictureView.h
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPageItemModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 查看大图View
 */
@interface SGShowPictureView : UIView
/// cell数据模型
@property(nonatomic,strong)SGPageItemModel *model;

/**
 显示视图
 */
- (void)show;

/**
 初始化

 @param frame frame
 @param image 占位图
 @return 对象本身
 */
-(instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
