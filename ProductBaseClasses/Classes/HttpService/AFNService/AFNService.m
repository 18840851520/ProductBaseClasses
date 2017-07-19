//  Created by 郭强 on 16/7/28.
//  Copyright © 2016年 郭强. All rights reserved.

#import "AFNService.h"
#import "HttpRequestSign.h"

@implementation AFNService

static AFNService * _instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

static int requestCount = 0;
- (void)judgeQiNiuToken{
    if ([NSString isBlankString:self.qiToken]) {
        requestCount = 0;
        [self requestData];
    }
}
#pragma mark RequestData 最多请求3次
- (void)requestData{
    if (requestCount >= 3) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //数据请求
    [[AFNService shareInstance] postValueWithMethod:@"public/qiniu/getToken" andBody:dict successBlock:^(SuccessModel *successModel) {
        //数据请求成功
        if ([successModel.code integerValue] == 1) {
            self.qiToken = EncodeStringFromDic(successModel.result, @"token");
            self.qiUrl = EncodeStringFromDic(successModel.result, @"url");
            requestCount = 0;
        }else{
            requestCount ++;
            [self requestData];
        }
    } failBlock:^(NSString *errorMessage) {
        //数据请求失败
        requestCount ++;
        [self requestData];
    }];
}
- (void)requestData:(NSData *)data successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock{
    if (requestCount >= 3) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //数据请求
    [[AFNService shareInstance] postValueWithMethod:@"public/qiniu/getToken" andBody:dict successBlock:^(SuccessModel *successModel) {
        //数据请求成功
        if ([successModel.code integerValue] == 1) {
            self.qiToken = EncodeStringFromDic(successModel.result, @"token");
            self.qiUrl = EncodeStringFromDic(successModel.result, @"url");
            requestCount = 0;
            [self postUpLoadDataFile:data successBlock:successBlock failBlock:failBlock];
        }else{
            requestCount ++;
            [self requestData];
        }
    } failBlock:^(NSString *errorMessage) {
        //数据请求失败
        requestCount ++;
        [self requestData];
    }];
}
#pragma mark 请求数据
- (AFHTTPSessionManager*)postValueWithMethod:(NSString *)method andBody:(NSDictionary *)body successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock
{
    
    HttpRequestSign* httpRequestSing = [[HttpRequestSign alloc] init];
    
    NSString* timestamp = GetTimestamp();

    
    if(![NSString isBlankString:APPDelegate.token]){
        [body setValue:APPDelegate.token forKey:@"token"];
    }
    
    if ([APPDelegate.language isEqualToString:@"en"]) {
        [body setValue:@"1" forKey:@"lang"];
    }
    
    //生成 签名
    NSString* sing = [httpRequestSing createRequestSing:body.mutableCopy orTimestamp:timestamp];
    
   [body setValue:sing forKey:@"sign"];
   [body setValue:timestamp forKey:@"timestamp"];
    
    NSString * postUrl = [NSString stringWithFormat:@"%@",BASE_URL];
    
    postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    

    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:postUrl]];
    
    NSMutableSet *acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes mutableCopy];
    [acceptableContentTypes addObject:@"text/html"];
    sessionManager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    
    [sessionManager.securityPolicy setAllowInvalidCertificates:YES];
    
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString* requestUrl=[NSString stringWithFormat:@"%@%@?%@",BASE_URL,method,[body JSONFragment]];
    
    NSLog(@"%@",requestUrl);

    [sessionManager POST:method parameters:body progress:^(NSProgress * _Nonnull uploadProgress) {
     
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *responseData = responseObject;
        
        NSString * response =  [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary* dict = [response JSONValue];
        if(!dict){
            NSLog(@"request出错-------：%@",response);
        }
        
        SuccessModel *model=[[SuccessModel alloc] initWithDictionary:dict];
        
        if([model.code integerValue]!=1){
        
            NSLog(@"request出错-------：%@",response);

        }
        if (successBlock!=nil) {
            
            if([model.code isEqualToString:@"-101"]||[model.code isEqualToString:@"-102"]||[model.code isEqualToString:@"-103"]||[model.code isEqualToString:@"-1001"]){
                APPDelegate.uid = @"";
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PopLoginViewController object:self userInfo:nil];
                [JPUSHService setTags:nil alias:@"zzz" fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias){
                    
                    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags, iAlias);
                }];
            }
            successBlock(model);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        
        NSDictionary * userInfo = error.userInfo;
        NSString* description = userInfo[@"NSLocalizedDescription"];

        if (failBlock!=nil) {
            failBlock(description);
        }
    }];
    return sessionManager;
}

-(AFHTTPSessionManager *)postValueWithMethod:(NSString *)method andBaseUrl:(NSString*)url andBody:(NSDictionary *)body successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock{
    HttpRequestSign* httpRequestSing = [[HttpRequestSign alloc] init];
    
    NSString* timestamp = GetTimestamp();
    
    //生成 签名
    NSString* sing = [httpRequestSing createRequestSing:body.mutableCopy orTimestamp:timestamp];
    
    [body setValue:sing forKey:@"sign"];
    [body setValue:timestamp forKey:@"timestamp"];
    
    NSString * postUrl = [NSString stringWithFormat:@"%@",BASE_URL];
    
    postUrl = [postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:postUrl]];
    
    NSMutableSet *acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes mutableCopy];
    [acceptableContentTypes addObject:@"text/html"];
    sessionManager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    
    [sessionManager.securityPolicy setAllowInvalidCertificates:YES];
    
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString* requestUrl=[NSString stringWithFormat:@"%@",postUrl];
    
    NSLog(@"%@",requestUrl);
    
    [sessionManager POST:method parameters:body progress:^(NSProgress * _Nonnull uploadProgress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *responseData = responseObject;
        
        NSString * response =  [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary* dict = [response JSONValue];
        if(!dict){
            NSLog(@"request出错-------：%@",response);
        }
        
        
        SuccessModel *model=[[SuccessModel alloc] initWithDictionary:dict];
        
        if([model.code integerValue]!=1){
            
            NSLog(@"request出错-------：%@",response);
            
        }
        if (successBlock!=nil) {
            
            if([model.code isEqualToString:@"-101"]||[model.code isEqualToString:@"-102"]||[model.code isEqualToString:@"-103"]||[model.code isEqualToString:@"-1001"]){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PopLoginViewController object:self userInfo:nil];
            }
            successBlock(model);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        
        NSDictionary * userInfo = error.userInfo;
        NSString* description = userInfo[@"NSLocalizedDescription"];
        
        if (failBlock!=nil) {
            failBlock(description);
        }
    }];
    return sessionManager;
}

#pragma marck 上传文件
-(AFHTTPSessionManager *)postUpLoadFileWithMethod:(NSString*)method andFile:(NSData*)data isImageType:(NSString*)imageType successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock
{
    HttpRequestSign* httpRequestSing = [[HttpRequestSign alloc] init];
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    NSString* timestamp = GetTimestamp();
    
    [body setValue:imageType forKey:@"type"];

    if(![NSString isBlankString:APPDelegate.token]){
        [body setValue:APPDelegate.token forKey:@"token"];
    }
    //生成 签名
    NSString* sing = [httpRequestSing createRequestSing:body.mutableCopy orTimestamp:timestamp];
    
    [body setValue:sing forKey:@"sign"];
    [body setValue:timestamp forKey:@"timestamp"];
    
    
    NSString* requestUrl=[NSString stringWithFormat:@"%@%@?%@",BASE_URL,method,[body JSONFragment]];
    
    NSLog(@"%@",requestUrl);

    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    NSMutableSet *acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes mutableCopy];
    [acceptableContentTypes addObject:@"text/html"];
    
    sessionManager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [sessionManager POST:method parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data name:@"filedata" fileName:@"*.jpg" mimeType:@"application/octet-stream"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *responseData = responseObject;
        NSString * response =  [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary* dict = [response JSONValue];
        SuccessModel *model=[[SuccessModel alloc] initWithDictionary:dict];
        if (successBlock!=nil) {
            successBlock(model);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error.userInfo);
        NSDictionary * userInfo = error.userInfo;
        NSString* description = userInfo[@"NSLocalizedDescription"];
        if (failBlock!=nil) {
            failBlock(description);
        }
    }];

    return sessionManager;
}

- (void)postUpLoadDataFile:(NSData *)data successBlock:(successBlock)successBlock failBlock:(failBlock)failBlock{
    //检测是否已经有七牛token
    [self judgeQiNiuToken];
    NSString *token = self.qiToken;
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putData:data key:nil token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  
                  if (!info.broken) {
                      SuccessModel *model = [[SuccessModel alloc] init];
                      if (info.statusCode == 200) {
                          model.code = @"1";
                          model.message = info.error.domain;
                          model.result = resp;
                          if (successBlock) {
                              successBlock(model);
                          }
                      }else if(info.statusCode == -3 || info.statusCode == 401){//七牛token=nil或失效
                          [self requestData:data successBlock:successBlock failBlock:failBlock];
                      }else{
                          model.code = [NSString stringWithFormat:@"%d",info.statusCode];
                          model.message = info.error.domain;
                          model.result = resp;
                          if (successBlock) {
                              successBlock(model);
                          }
                      }
                  }else{
                      if (failBlock) {
                          failBlock(info.error.domain);
                      }
                  }
              } option:nil];
}
- (void)postUpLoadFile:(NSData *)data successBlock:(void(^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))successblock failBlock:(failBlock)failBlock{
    
    [self judgeQiNiuToken];
    
    NSString *token = self.qiToken;
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putData:data key:nil token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  if (!info.broken) {
                      if (successblock) {
                          successblock(info, key, resp);
                      }
                  }else{
                      if (failBlock) {
                          failBlock(info.error.domain);
                      }
                  }
    } option:nil];
}





@end
