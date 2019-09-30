//
//  SGPageItemModel.m
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import "SGPageItemModel.h"

@implementation SGPageItemModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper
{
    return @{@"cellId" : @"id",
             @"title" : @"description",
             @"regularUrl" : @"urls.regular",
             @"smallUrl" : @"urls.small",
             @"fullUrl" : @"urls.full",
             @"rawUrl" : @"urls.raw",
             @"thumbUrl" : @"urls.thumb"
             };
}

- (NSString *)title
{
    if (_title.length==0) {
        return @"编辑推荐";
    }
    return _title;
}
@end
