//
//  SGCardCollectionViewCell.h
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGPageItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SGCardCollectionViewCell : UICollectionViewCell
/// cell数据模型
@property(nonatomic,strong)SGPageItemModel *model;

@end

NS_ASSUME_NONNULL_END
