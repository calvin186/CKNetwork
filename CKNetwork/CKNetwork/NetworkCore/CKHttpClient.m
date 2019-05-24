//
// Created by William Zhao on 13-6-28.
// Copyright (c) 2013 Vipshop Holdings Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "CKHttpClient.h"
#import <AFNetworking/AFNetworking.h>

@interface CKHttpClient()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@end

@implementation CKHttpClient {
    PCMutableParameters *_parameters;
    PCMutableParameters *_postParameters;
    PCMutableParameters *_fileParameters;
    PCMutableParameters *_headers;
}

- (id)init {
    self = [super init];
    if (self) {
        _method = PCHttpMethodGet;
        _parameters = [[PCMutableParameters alloc] init];
        _postParameters = [[PCMutableParameters alloc] init];
        _fileParameters = [[PCMutableParameters alloc] init];
        _headers = [[PCMutableParameters alloc] init];
        _timeOut = 15;
        _taskType = PCTaskData;
        _httpSessionManager = [AFHTTPSessionManager manager];
        _httpSessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _httpSessionManager.requestSerializer=[AFJSONRequestSerializer serializer];
        [_httpSessionManager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        _httpSessionManager.requestSerializer.timeoutInterval = _timeOut;
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _httpSessionManager.securityPolicy = securityPolicy;
        _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

- (CKParameters *)parameters {
    [_parameters clearAllParameter];
    [self buildParameters:_parameters];
    return _parameters;
}

- (CKParameters *)postParameters {
    [_postParameters clearAllParameter];
    [self buildPostParameters:_postParameters];
    return _postParameters;
}

- (CKParameters *)postNoKeyParameters {
    [_postParameters clearAllParameter];
    [self buildPostNoKeyParameters:_postParameters];
    return _postParameters;
}

- (CKParameters *)fileParameters {
    [_fileParameters clearAllParameter];
    [self buildFileParameters:_fileParameters];
    return _fileParameters;
}

- (CKParameters *)headers {
    [_headers clearAllParameter];
    [self buildHeaders:_headers];
    return _headers;
}

- (BOOL)send {
    _httpSessionManager.requestSerializer.timeoutInterval = _timeOut;
    NSDictionary *businessHeaders = nil;
//    if (self.method == PCHttpMethodGet) {
//        businessHeaders = [apiSign buildCommenSignWithParameters:[self parameters].dictionary];
//    }else{
//        if (self.parameterType == PCPostParameterFormData) {
//            businessHeaders = [apiSign buildCommenSignWithParameters:[self parameters].dictionary];
//        }else if (self.parameterType == PCPostParameterJson) {
//            businessHeaders = [apiSign buildJSONSignWithParameters:[self postParameters].dictionary];
//        }else {
//            businessHeaders = [apiSign buildJSONSignWithParameters:[self postNoKeyParameters].parameterValue];
//        }
//    }
    //处理普通header
    CKParameters *headers = [self headers];
    NSDictionary *headersDictionary = [headers dictionary];
    AFHTTPRequestSerializer *requestSerializer = _httpSessionManager.requestSerializer;
    for (NSString *key in headersDictionary.allKeys) {
        [requestSerializer setValue:headersDictionary[key] forHTTPHeaderField:key];
    }
    //处理签名header
    for (NSString *key in businessHeaders.allKeys) {
        [requestSerializer setValue:businessHeaders[key] forHTTPHeaderField:key];
    }
    
    NSURL* requestURL = [self buildRequestURL];
    //PCLog(@"url:%@",requestURL.absoluteString);
    __weak CKHttpClient *weakself = self;
    if(_method == PCHttpMethodPost){
        //处理参数
        if (self.parameterType == PCPostParameterFormData) {
            [_httpSessionManager POST:requestURL.absoluteString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [[weakself.postParameters dictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSString class]]) {
                        [formData appendPartWithFormData:[obj dataUsingEncoding:NSUTF8StringEncoding] name:key];
                    }else if ([obj isKindOfClass:[NSData class]]) {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        // 设置时间格式
                        [formatter setDateFormat:@"yyyyMMddHHmmss"];
                        NSString *dateString = [formatter stringFromDate:[NSDate date]];
                        NSString *fileName = [NSString  stringWithFormat:@"%@.jpg", dateString];
                        [formData appendPartWithFileData:obj name:key fileName:fileName mimeType:@"image/jpeg"];
                    }
                }];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakself networkCompleted:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [weakself networkError:error];
            }];
        }else if (self.parameterType == PCPostParameterJson) {
            [_httpSessionManager POST:requestURL.absoluteString parameters:_postParameters.dictionary progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakself networkCompleted:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [weakself networkError:error];
            }];
        }else {
            [_httpSessionManager POST:requestURL.absoluteString parameters:_postParameters.parameterValue progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [weakself networkCompleted:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [weakself networkError:error];
            }];
        }
    }else if(_method==PCHttpMethodGet){
        [_httpSessionManager GET:requestURL.absoluteString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakself networkCompleted:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakself networkError:error];
        }];
    }
    return YES;
}

- (NSString *)serverURL {
    return @"";
}

- (NSString* )methodString {
    switch (self.method) {
        case PCHttpMethodPost:
            return @"POST";
        case PCHttpMethodGet:
            return @"GET";
        default:
            @throw [NSException exceptionWithName:@"参数不正确" reason:@"HTTP方法不能为空" userInfo:nil];
    }
}

- (void)cancel {
    if(_httpSessionManager){
        [_httpSessionManager.operationQueue cancelAllOperations];
    }
}

- (NSString *)description {
    NSURL* requestURL = [self buildRequestURL];
    return [requestURL absoluteString];
}

- (void)resetParameters {
    [_parameters clearAllParameter];
    [self buildParameters:_parameters];
}

- (NSURL*)buildRequestURL {
    NSMutableString *serverURL = [NSMutableString stringWithString:[self buildRequestURLString]];
    NSString *parameters = [_parameters buildParameters];
    NSString *suffixStr = [serverURL substringFromIndex:[serverURL length] - 1];
    NSString *formatStr;
    if ([suffixStr isEqualToString:@"?"] || [suffixStr isEqualToString:@"&"])
        formatStr = @"%@%@";
    else
        formatStr = @"%@?%@";
    serverURL = [NSMutableString stringWithFormat:formatStr, serverURL, parameters];
    
    return [NSURL URLWithString:serverURL];
}

- (NSString *)buildRequestURLString {
    return nil;
}

- (void)buildAppendParameters:(PCMutableParameters*)parameters {
    
}

- (void)buildParameters:(PCMutableParameters *)parameters {
    
}

- (void)buildPostParameters:(PCMutableParameters *)parameters {
    
}

- (void)buildPostNoKeyParameters:(PCMutableParameters *)parameters {
    
}

- (void)buildFileParameters:(PCMutableParameters *)parameters {
    
}

- (void)buildHeaders:(PCMutableParameters *)headers {
    
}

- (BOOL)networkStart {
    return NO;
}

- (NSString *)postFileType {
    return @"image/png";
}

- (void)networkCompleted:(NSData *)responseData {
}

- (void)networkError:(NSError *)error {
}

@end
