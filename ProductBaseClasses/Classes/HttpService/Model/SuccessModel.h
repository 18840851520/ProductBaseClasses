//
//  SuccessModel.h
//  YY_yijia
//
//  Created by yiyou on 15/4/25.
//  Copyright (c) 2015年 com.yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuccessModel : NSObject
@property (nonatomic,strong)NSString *message;
@property (nonatomic,assign)NSString *code;
@property (nonatomic,assign)id result;
@property (nonatomic,strong)NSString* action;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
@end
