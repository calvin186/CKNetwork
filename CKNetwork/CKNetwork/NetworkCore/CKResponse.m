//
// Created by William Zhao on 13-6-26.
// Copyright (c) 2013 Vipshop Holdings Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CKResponse.h"

@implementation CKResponse
+ (instancetype)mj_objectWithKeyValues:(id)keyValues {
    CKResponse *response = [self mj_objectWithKeyValues:keyValues];
    return response;
}

- (NSString *)description {
    return [[NSString alloc] initWithData:self.mj_JSONData encoding:NSUTF8StringEncoding];
}

@end
