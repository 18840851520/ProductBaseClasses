//
//  SuccessModel.m
//  FunnyApp
//
//  Created by yiyou on 15/4/25.
//  Copyright (c) 2016年 com.yiyou. All rights reserved.
//
#import "SuccessModel.h"

@implementation SuccessModel

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self=[super init];
    if (self) {
        
        self.code = EncodeStringFromDic(dict,@"code");
        self.message = EncodeStringFromDic(dict,@"msg");
        self.result = EncodeDicFromDic(dict,@"data");
        if(!self.result){
            self.result = EncodeArrayFromDic(dict,@"data");
        }
        
        self.action = EncodeStringFromDic(dict,@"action");
//        NSDictionary* result=dict[@"result"];
//        self.message=result[@"status_reason"];
//        self.code=[NSString stringWithFormat:@"%@",result[@"status_code"]];
//        self.result=result[@"data"];
    }
    return self;
}
@end
