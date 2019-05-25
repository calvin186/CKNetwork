//
// 名称：CKRequest
// 注释：接口请求基类
//      提供所有网络请求接口的基类
// 作者：william zhao
// 日期：2013-09-30
//

#import "CKHttpClient.h"
#import "CKResponse.h"
#import "CKRequestDelegate.h"
#import <UIKit/UIDevice.h>

typedef NS_ENUM(NSInteger,CKPlatform) {
    CKPlatformIOS = 1,  //IOS平台
    CKPlatformWeb = 2   //Web
};

/*!
 *  网络请求抽象类
 */
@interface CKRequest : CKHttpClient

/*!
 *  网络请求的服务名称
 */
@property(nonatomic, strong) NSString *serviceName;

/*!
 *  网络请求的回调委托
 */
@property(nonatomic, weak) id <CKRequestDelegate> delegate;

/*!
 *  网络请求的响应类
 */
- (Class)responseClass;

/*!
 *  使用Block方式发送网络请求
 *
 *  @param completedCallback CKRequestCompletedCallback
 */
- (void)send:(CKRequestCompletedCallback)completedCallback;

/*!
 *  使用Block方式发送网络请求
 *
 *  @param completedCallback CKRequestCompletedCallback
 *  @param errorCallback     CKRequestErrorCallback
 */
- (void)send:(CKRequestCompletedCallback)completedCallback errorCallback:(CKRequestErrorCallback)errorCallback;

/*!
 *  取消网络请求
 */
- (void)cancelRequest;

/**
 *  业务相关的拼接
 *
 *  @return 业务相关的拼接
 */
- (NSString *)businessDomain;

@end
