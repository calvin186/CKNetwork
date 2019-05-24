//
// Created by William Zhao on 13-7-9.
// Copyright (c) 2013 Vipshop Holdings Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class CKRequest;
@class CKResponse;

/*!
 *  网络请求委托
 */
@protocol CKRequestDelegate <NSObject>
@required
/*!
 *  网络请求完成
 *
 *  @param request  CKRequest
 *  @param response CKResponse
 */
- (void)requestCompleted:(CKRequest *)request response:(CKResponse *)response;

/*!
 *  网络请求出错
 *
 *  @param request CKRequest
 *  @param error   NSError
 */
- (void)requestError:(CKRequest *)request error:(NSError *)error;
@end

typedef void (^CKRequestCompletedCallback)(CKRequest *request, CKResponse *response);

typedef void (^CKRequestErrorCallback)(CKRequest *request, NSError *error);
