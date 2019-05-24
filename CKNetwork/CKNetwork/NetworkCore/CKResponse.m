//
// Created by William Zhao on 13-6-26.
// Copyright (c) 2013 Vipshop Holdings Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CKResponse.h"

@interface CKResponse ()

@property (nonatomic, strong) NSString *jsonString;

@end

@implementation CKResponse

- (NSString *)description {
    return _jsonString;
}

@end
