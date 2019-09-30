//
//  SGMainViewModel.h
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGNetWorking.h"
#import "SGPageItemModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^SuccessBlock)(id data);
typedef void(^FailBlock)(NSString *errorMsg);

@interface SGMainViewModel : NSObject

@property(nonatomic,strong)NSMutableArray<SGPageItemModel *>*dataAry;

/**
 获取照片列表

 @param page 要检索的页码。（可选；默认值：1）
 @param perPage 每页的项目数。（可选；默认值：10）
 @param orderBy 如何对照片进行排序。可选的。（有效值：latest，oldest，popular;默认：latest）
 @param successBlock 成功回调
 @param failBlock 失败回调
 */
- (void)getPhotosListWithPage:(NSInteger)page perPage:(NSInteger)perPage orderBy:(SGPhotosListOrderBy)orderBy successBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock;
@end

NS_ASSUME_NONNULL_END
