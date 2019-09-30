//
//  SGMainViewModel.m
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import "SGMainViewModel.h"
#import "SGPageItemModel.h"

@implementation SGMainViewModel
/**
 获取照片列表
 
 @param page 要检索的页码。（可选；默认值：1）
 @param perPage 每页的项目数。（可选；默认值：10）
 @param orderBy 如何对照片进行排序。可选的。（有效值：latest，oldest，popular;默认：latest）
 @param successBlock 成功回调
 @param failBlock 失败回调
 */
- (void)getPhotosListWithPage:(NSInteger)page perPage:(NSInteger)perPage orderBy:(SGPhotosListOrderBy)orderBy successBlock:(SuccessBlock)successBlock failBlock:(FailBlock)failBlock
{
    if (page<=1) {
        page = 1;
    }
    NSString *orderByStr = @"latest";
    switch (orderBy) {
        case SGPhotosListOrderByLatest:
            orderByStr = @"latest";
            break;
        case SGPhotosListOrderByOldest:
            orderByStr = @"oldest";
            break;
        case SGPhotosListOrderByPopular:
            orderByStr = @"popular";
            break;
    }
    WeakSelf;
    [SGNetworking getWithURL:@"photos" params:@{@"page":@(page), @"per_page":@(perPage), @"order_by":orderByStr} returnClass:[SGPageItemModel class] success:^(id responseObject) {
        if (responseObject) {
            NSArray *dataArray = (NSArray *)responseObject;
            if (page==1) {
                weakSelf.dataAry = [[NSMutableArray alloc]initWithArray:dataArray];
            }else{
                [weakSelf.dataAry addObjectsFromArray:dataArray];
            }
            successBlock(dataArray);
        }
    } failure:^(NSString *error) {
        failBlock(error);
    }];
}
@end
