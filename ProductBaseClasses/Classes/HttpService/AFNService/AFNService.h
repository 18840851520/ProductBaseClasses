//  Created by 郭强 on 16/7/28.
//  Copyright © 2016年 郭强. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SuccessModel.h"
#import <QiniuSDK.h>
#import <AFNetworking.h>

typedef void (^successBlock)(SuccessModel *successModel);
typedef void (^failBlock)(NSString *errorMessage);

@interface AFNService : NSObject

@property (nonatomic, strong) NSString *qiToken;//七牛token

@property (nonatomic, strong) NSString *qiUrl;//七牛Url


+(instancetype) shareInstance;

- (void)judgeQiNiuToken;//检验是否有七牛Token
/**
 * 请求服务端数据
 */
-(AFHTTPSessionManager *)postValueWithMethod:(NSString *)method andBody:(NSDictionary *)body successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;


/**
 * 请求服务端数据
 */
-(AFHTTPSessionManager *)postValueWithMethod:(NSString *)method andBaseUrl:(NSString*)url andBody:(NSDictionary *)body successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;

/**
 * 上传文件 如图片
 */
- (AFHTTPSessionManager *)postUpLoadFileWithMethod:(NSString*)method andFile:(NSData*)data isImageType:(NSString*)imageType successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;

- (void)postUpLoadDataFile:(NSData *)data successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock;

- (void)postUpLoadFile:(NSData *)data successBlock:(void(^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))successblock failBlock:(failBlock)failBlock;



@end
