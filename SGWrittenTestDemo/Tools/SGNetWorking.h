//
//  SGNetworking.h
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(id responseObject);
typedef void (^FailureBlock)(NSString *error);

/**
 网络请求工具
 */
@interface SGNetworking : NSObject


/**
 get网络请求接口

 @param url url字符串
 @param params 请求参数
 @param returnClass 返回数据解析模型类
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getWithURL:(NSString *)url params:(NSDictionary *)params returnClass:(Class)returnClass success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
