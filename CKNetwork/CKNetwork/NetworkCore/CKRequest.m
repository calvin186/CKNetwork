//
// Created by William Zhao on 13-6-26.
// Copyright (c) 2013 Vipshop Holdings Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "CKRequest.h"

@interface CKRequest ()

@property (nonatomic, copy) CKRequestCompletedCallback completedCallback;
@property (nonatomic, copy) CKRequestErrorCallback errorCallback;

- (void)requestCompleted:(CKResponse *)response;
- (void)requestError:(NSError *)error;

@end

@implementation CKRequest

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    [self cancel];
}

- (void)cancelRequest {
    _delegate = nil;
    [super cancel];
}

- (void)buildAppendParameters:(CKMutableParameters*)parameters {
    NSDictionary *getParameters = [self getParameters].dictionary;
    [getParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [parameters addParameter:obj forKey:key];
    }];
}

- (void)buildGetParameters:(CKMutableParameters*)parameters {
    [super buildGetParameters:parameters];
}

- (void)buildPostParameters:(CKMutableParameters *)parameters {
    [super buildPostParameters:parameters];
}

- (void)buildHeaders:(CKMutableParameters *)headers {
    [super buildHeaders:headers];
}

- (void)send:(CKRequestCompletedCallback)completedCallback {
    [self send:completedCallback errorCallback:nil];
}

- (void)send:(CKRequestCompletedCallback)completedCallback errorCallback:(CKRequestErrorCallback)errorCallback {
    self.completedCallback = completedCallback;
    self.errorCallback = errorCallback;
    [self send];
}

- (BOOL)networkStart {
    return YES;
}

- (void)networkCompleted:(NSData *)responseData; {
    Class responseClass = [self responseClass];
    if(![responseClass isSubclassOfClass:[CKResponse class]]){
        @throw [NSException exceptionWithName:@"类型错误" reason:@"responseClass必须为CKResponse的子类" userInfo:nil];
    }
    //NSError *error = nil;
    //NSLog(@">>>%@:%@",NSStringFromClass(responseClass),[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    CKResponse *response = [responseClass mj_objectWithKeyValues:responseData];
    if ([NSThread isMainThread]) {
        [self requestCompleted:response];
    }
    else {
        [self performSelectorOnMainThread:@selector(requestCompleted:) withObject:response waitUntilDone:NO];
    }
}

- (void)networkError:(NSError *)error {
    //NSLog(@"--NetworkError:%@",error);
    if ([NSThread isMainThread]) {
        [self requestError:error];
    }
    else {
        [self performSelectorOnMainThread:@selector(requestError:) withObject:error waitUntilDone:NO];
    }
}

- (void)requestCompleted:(CKResponse *)response {
    if (_completedCallback) {
        _completedCallback(self, response);
    }

    if (_delegate && [_delegate respondsToSelector:@selector(requestCompleted:response:)]) {
        [_delegate performSelector:@selector(requestCompleted:response:) withObject:self withObject:response];
    }
}

- (void)requestError:(NSError *)error {
    if (_errorCallback) {
        _errorCallback(self, error);
    }

    if (_delegate && [_delegate respondsToSelector:@selector(requestError:error:)]) {
        [_delegate performSelector:@selector(requestError:error:) withObject:self withObject:error];
    }
}

- (NSString *)buildRequestURLString {
    NSString *serverURL = [NSString stringWithString:[self serverURL]];
    //业务
    NSString *pathComponent = @"";
    NSString *busiDomain = [self businessDomain];
    if (busiDomain) {
        pathComponent = [pathComponent stringByAppendingPathComponent:busiDomain];
    }
    //功能
    NSString *service = [self serviceName];
    if (service) {
       pathComponent = [pathComponent stringByAppendingPathComponent:service];
    }
    serverURL = [serverURL stringByAppendingString:pathComponent];
    return serverURL;
}

- (NSString *)serverURL {
    return nil;
}

- (NSString *)businessDomain {
    return nil;
}

- (Class)responseClass {
    @throw [NSException exceptionWithName:@"方法错误" reason:@"必须实现抽象方法" userInfo:nil];
}

@end
