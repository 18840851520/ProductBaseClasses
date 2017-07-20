//
//  HttpRequestSign.m
//  DoctorApp
//
//  Created by 郭强 on 16/7/25.
//  Copyright © 2016年 郭强. All rights reserved.
//

#import "HttpRequestSign.h"
#import <CommonCrypto/CommonDigest.h>


@interface HttpRequestSign()

@property(nonatomic,strong)NSString* appKey;
@property(nonatomic,strong)NSString* appKeyValue;
@property(nonatomic,strong)NSString* appUuid;
@property(nonatomic,strong)NSString* appUuidValue;


@end

@implementation HttpRequestSign


- (NSString*)createRequestSing:(NSDictionary*)paramDict orArray:(NSMutableArray*)array orTime:(NSString*)timeStamp{


    self.appKeyValue = AppKey;
    
    
    //时间戳的值
   timeStamp=[NSString stringWithFormat:@"timestamp=%@",timeStamp];
    
    NSString * paramStr = nil;
    
    if (IsObjectValid(array)) {
        //生成签名
        paramStr = [self sort:array];
    }
    
    if(![NSString isBlankString:paramStr]){
        paramStr = [NSString stringWithFormat:@"%@&%@&%@", paramStr,self.appKey,timeStamp];
    }else{
        paramStr = [NSString stringWithFormat:@"%@&%@", self.appKey, timeStamp];
    }
    
    NSString * sing = [self sign:paramStr];

    
//    if (IsNSStringNotEmpty(nssSortPara)) {
//        nssForSign = [NSString stringWithFormat:@"%@&%@&%@", nssSortPara, m_nssAppKey, nssStamp];
//    }
//    else
//    {
//        nssForSign = [NSString stringWithFormat:@"%@&%@", m_nssAppKey, nssStamp];
//    }

    

    return sing;
}



#pragma mark 创建签名
- (NSString*)createRequestSing:(NSDictionary*)paramDict orTimestamp:(NSString*)timeStamp{

    self.appKey = [NSString stringWithFormat:@"appkey=%@",AppKey];
    //时间戳的值
    timeStamp=[NSString stringWithFormat:@"timestamp=%@",timeStamp];
    
    NSString * paramStr = nil;
    if (IsObjectValid(paramDict)) {
        //生成签名
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for(NSString* key in paramDict){
            NSString* value = EncodeStringFromDic(paramDict,key);
            NSString* param = [NSString stringWithFormat:@"%@=%@",key,value];
           [array addObject:param];
        }
        paramStr = [self sort:array];
    }
    if(![NSString isBlankString:paramStr]){
        paramStr = [NSString stringWithFormat:@"%@&%@&%@", paramStr,self.appKey,timeStamp];
    }else{
        paramStr = [NSString stringWithFormat:@"%@&%@", self.appKey, timeStamp];
    }
    NSString * sing = [self sign:paramStr];
    
    return sing;
}


-(NSString *)sign:(NSString*)nssToSign
{
   // NSString * nssUrlEncode = [self encodeToPercentEscapeString:nssToSign];
    
    return [self md5:nssToSign];
}

- (NSString*)sort:(NSArray*)arrArguments
{
    NSArray * arrSorted = [arrArguments sortedArrayUsingSelector:@selector(compare:)];
    
    NSString * nssForSign = nil;
    
    NSUInteger iCount = [arrSorted count];
    for(int i =0; i < iCount; i++)
    {
        NSLog(@"%@\n", [arrSorted objectAtIndex:i]);
        
        if (!nssForSign) {
            nssForSign = [NSString stringWithFormat:@"%@", [arrSorted objectAtIndex:i]];
        }
        else {
            nssForSign = [nssForSign stringByAppendingFormat:@"&%@",[arrSorted objectAtIndex:i]];
        }
    }
    
    return nssForSign;
}

//获取时间戳
- (NSString *)getTimeStamp
{
    NSDate * localDate = [NSDate date];
    NSString * nsstimeStamp = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]];
    return nsstimeStamp;
}

#pragma mark 获取UUID
- (NSString*) uuid {
    
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    [[NSUserDefaults standardUserDefaults]setObject:result forKey:@"uuid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return result;
}

//url格式编码
- (NSString *)encodeToPercentEscapeString:(NSString *)input
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (CFStringRef)input,
                                                                     NULL,
                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]< >",
                                                                     kCFStringEncodingUTF8));
}

//md5加密
- (NSString *)md5:(NSString *)str
{
    const char * original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

//md5加密
+ (NSString *)md5:(NSString *)str
{
    const char * original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
