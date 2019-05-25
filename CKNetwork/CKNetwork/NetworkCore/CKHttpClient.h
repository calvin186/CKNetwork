//
// 名称：CKHttpClient
// 注释：HTTP客户端类
//      所有HTTP请求的基类，提供异步请求，自动重试，缓存等功能
// 作者：william zhao
// 日期：2013-09-30
//

#import "CKParameters.h"

/*!
 *  网络请求方法
 */
typedef NS_ENUM(NSInteger, CKHttpMethod) {
    CKHttpMethodNone = 0,
    CKHttpMethodPost,
    CKHttpMethodGet
};

typedef NS_ENUM(NSInteger, CKTaskType) {
    CKTaskData = 0,         //数据请求
    CKTaskDownload = 1,     //下载
    CKTaskUpload = 2        //上传
};
typedef NS_ENUM(NSInteger, CKPostParameterType) {
    CKPostParameterFormData,      //以from表单方式提交
    CKPostParameterJson,          //以JSON格式提交
    CKPostParameterWithNoKeyJson, //以无参数JSON格式提交，例如:直接提交一个数组JSON
};

/*!
 *  线程池优先级
 */
typedef NS_ENUM(NSInteger, CKThreadPoolPriority) {
    CKThreadPoolPriorityDefault = 0,
    CKThreadPoolPriorityHigh,
    CKThreadPoolPriorityLow
};

@interface CKHttpClient : NSObject

/*!
 *  网络请求的方法
 */
@property(nonatomic, assign) CKHttpMethod method;

/*!
 *  网络请求的方法
 */
@property(nonatomic, assign) CKPostParameterType parameterType;

/*!
 *  任务类型，默认为CKTaskData
 */
@property(nonatomic, assign) CKTaskType taskType;

/*!
 *  网络请求的服务器地址
 */
@property(weak, nonatomic, readonly) NSString *serverURL;

/*!
 *  网络请求的get参数
 */
@property(strong, nonatomic, readonly) CKParameters *getParameters;

/*!
 *  网络请求的post参数
 */
@property(strong, nonatomic, readonly) CKParameters *postParameters;

/*!
 *  网络请求的file参数(文件路径，参数名)，使用此参数集合，需要对应重写：- (NSString *)postFileType方法
 */
@property(strong, nonatomic, readonly) CKParameters *fileParameters;

/*!
 *  网络请求的header参数
 */
@property(strong, nonatomic, readonly) CKParameters *headers;

/*!
 *  网络请求超时时间，默认15秒
 */
@property(nonatomic, assign) NSTimeInterval timeOut;

/*!
 *  发送网络请求，调用send方法之后，在release该对象之前，必须先调用cancel方法
 *
 *  @return yes
 */
- (BOOL)send;

/*!
 *  取消网络请求
 */
- (void)cancel;

/*!
 *  构建url拼接参数
 *
 *  @param parameters 可变参数集合类
 */
- (void)buildAppendParameters:(CKMutableParameters*)parameters;

/*!
 *  构建get请求参数
 *
 *  @param parameters 可变参数集合类
 */
- (void)buildGetParameters:(CKMutableParameters*)parameters;

/**
 *  构建post请求参数
 *
 *  @param parameters 参数集合类
 */
- (void)buildPostParameters:(CKMutableParameters *)parameters;

/**
 *  构建上传文件参数
 *
 *  @param parameters 文件参数集合（参数名+文件路径）
 */
- (void)buildFileParameters:(CKMutableParameters *)parameters;

/*!
 *  构建请求header参数
 *
 *  @param headers 可变参数集合类
 */
- (void)buildHeaders:(CKMutableParameters *)headers;

/*!
 *  重置请求参数
 */
- (void)resetParameters;

/*!
 *  构建请求地址
 *
 *  @return NSURL
 */
- (NSURL*)buildRequestURL;

/**
 *  构建请求地址
 *
 *  @return 地址字符串
 */
- (NSString*)buildRequestURLString;

/*!
 *  网络请求开始
 *
 *  @return NO
 */
- (BOOL)networkStart;

/*!
 *  上传的文件类型，默认上传图片，类型为：image/png
 *
 *  @return nil
 */
- (NSString *)postFileType;

/*!
 *  网络请求完成
 *
 *  @param responseData 返回数据
 */
- (void)networkCompleted:(NSData *)responseData;

/*!
 *  网络请求失败
 *
 *  @param error NSError
 */
- (void)networkError:(NSError *)error;

@end
