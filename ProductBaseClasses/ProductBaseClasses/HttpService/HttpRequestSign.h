//
//  HttpRequestSign.h
//  DoctorApp
//
//  Created by 郭强 on 16/7/25.
//  Copyright © 2016年 郭强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestSign : NSObject


/**
 *  创建 网络签名
 *
 *  @param
 *  @param
 *  @return
 */

+ (NSString *)md5:(NSString *)str;

- (NSString*)createRequestSing:(NSDictionary*)paramDict orArray:(NSMutableArray*)array orTime:(NSString*)timeStamp;

- (NSString*)createRequestSing:(NSDictionary*)paramDict orTimestamp:(NSString*)timeStamp;

@end
