//
//  SGNetworking.m
//  SGWrittenTestDemo
//
//  Created by Mac on 2019/9/29.
//  Copyright © 2019 QinPeng. All rights reserved.
//

#import "SGNetWorking.h"
#import <YYModel.h>
#import "Reachability.h"

// block self
#define XT_WeakSelf  __weak typeof (self)weakSelf = self;
#define XT_StrongSelf typeof(weakSelf) __strong strongSelf = weakSelf;
NSString *const ResponseErrorKey = @"com.alamofire.serialization.response.error.response";
// 超时时间
NSInteger const Interval = 20;

@interface SGNetworking ()<NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@end

@implementation SGNetworking

/**
 get网络请求接口
 
 @param url url字符串
 @param params 请求参数
 @param returnClass 返回数据解析模型类
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getWithURL:(NSString *)url params:(NSDictionary *)params returnClass:(Class)returnClass success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSURLRequest *request = [self getRequestFor:url params:params];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            
            //利用iOS自带原生JSON解析data数据
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
#ifdef DEBUG
            NSLog(@"ww_httpResponse:%@", responseObject);
#endif
            //缓存
            [self cacheResponse:response forRequest:request jsonData:responseObject];
            //解析回调数据
            NSString *errorMsg = [[NSString alloc] init];
            id data = [self dataParse:responseObject parseClass:returnClass error:&errorMsg];
            if (errorMsg.length>0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(errorMsg);
                });
            }else{
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(data);
                    });
                }
            }
            
        } else {
            //请求错误
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error.localizedDescription);
                });
            }
        }
    }];
    
    [task resume];
}

/**
 创建网络请求

 @param url url字符串
 @param params 请求参数
 @return 网络请求
 */
+ (NSURLRequest *)getRequestFor:(NSString *)url params:(NSDictionary *)params
{

    //拼接get请求串
    url = [NSString stringWithFormat:@"%@%@",kBaseUrl,url];
    //完整URL
    NSString *urlString = [NSString string];
    if (params.count>0) {
        //参数拼接url
        NSString *paramStr = [self dealWithParam:params];
        urlString = [NSString stringWithFormat:@"%@?%@",url,paramStr];
        
    }else{
        urlString = url;
    }
    //对URL中的中文进行转码
    NSString *pathStr = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pathStr]];
    //HTTPHeader
    [request setValue:[NSString stringWithFormat:@"Client-ID %@", kToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"v1" forHTTPHeaderField:@"Accept-Version"];
    
    request.timeoutInterval = Interval;
    
    //在无网络情况下强制读取离线缓存
    if ([self internetStatus] == NotReachable) {
        //在无网络的情况下加载缓存
        request.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    } else {
        request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    
    return request;
}

/**
 获取当前网络状态

 @return 网络状态
 */
+ (NetworkStatus)internetStatus {
    
    Reachability *reachability   = [Reachability reachabilityWithHostName:kBaseUrl];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    return internetStatus;
}

/**
 拼接请求参数

 @param param 请求参数
 @return 拼接后的请求参数字符串
 */
+ (NSString *)dealWithParam:(NSDictionary *)param
{
    NSArray *allkeys = [param allKeys];
    NSMutableString *result = [NSMutableString string];
    int pos =0;
    for (NSString *key in allkeys) {
        // 拼接字符串
        [result appendFormat:@"%@=%@", key, param[key]];
        if(pos<allkeys.count-1){
            [result appendString:@"&"];
        }
        pos++;
    }
    return result;
}

/**
 缓存数据

 @param response 网络响应类
 @param request 网络请求
 @param jsonData 数据
 */
+ (void)cacheResponse:(NSURLResponse *)response forRequest:(NSURLRequest *)request jsonData:(id)jsonData
{
    //这里不校验缓存时效性，简易实现
    NSData *dataFromJson = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
    if (dataFromJson) {
        NSCachedURLResponse *cacheResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:dataFromJson];
        [[NSURLCache sharedURLCache] storeCachedResponse:cacheResponse forRequest:request];
    }
}

/**
 解析数据为对应的模型

 @param responseObject 返回的数据
 @param parseClass 模型类
 @param error 错误信息
 @return 模型
 */
+ (id)dataParse:(id)responseObject parseClass:(Class)parseClass error:(NSString **)error
{
    if (parseClass) {
        //需要模型映射解析
        id parseData = nil;
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            //返回数据是一个数组
            parseData = [NSArray yy_modelArrayWithClass:parseClass json:responseObject];
        } else {
            //返回其他数据结构
            if ([parseClass respondsToSelector:@selector(yy_modelWithJSON:)]) {
                parseData = [parseClass yy_modelWithJSON:responseObject];
            }
        }
        
        if (parseData) {
            //解析成功
            *error = nil;
            return parseData;
        } else {
            //解析失败
            *error = [NSString stringWithFormat:@"数据解析失败:%@", NSStringFromClass(parseClass)];
            return nil;
        }
    } else {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            //If an error occurs, whether on the server or client side, the error message(s) will be returned in an errors array.
            NSArray *errorArray = [(NSDictionary *)responseObject valueForKey:@"errors"];
            if (errorArray) {
                //返回数据存在错误
                NSMutableString *erreStr = [[NSMutableString alloc] init];
                for (NSString *str in errorArray) {
                    [erreStr appendString:[NSString stringWithFormat:@"%@\n", str]];
                }
                *error = erreStr;
                return nil;
            }
        }
        
        //数据正常
        *error = nil;
        return responseObject;
    }
}

@end
