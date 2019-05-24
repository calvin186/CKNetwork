//
// 名称：CKResponse
// 注释：接口应答基类
//      提供所有网络应答的基类
// 作者：william zhao
// 日期：2013-09-30
//

#import <Foundation/Foundation.h>
/*!
 *  网络应答抽象类
 */
@interface CKResponse : NSObject

/**
 *  返回错误状态码
 */
@property (nonatomic, assign) NSInteger errorCode;
/**
 *  返回错误信息
 */
@property (nonatomic, strong) NSString *errorMsg;
/**
 *  接口返回状态
 */
@property (nonatomic, assign) BOOL success;

@end
