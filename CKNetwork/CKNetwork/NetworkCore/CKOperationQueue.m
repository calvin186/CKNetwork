//
//  CKOperationQueue.m
//  Start
//
//  Created by calvin on 16/7/7.
//  Copyright © 2016年 DingSNS. All rights reserved.
//

#import "CKOperationQueue.h"

@interface CKOperationQueue ()

@property (nonatomic, strong) NSMutableArray *operationQueue;
@property (nonatomic, strong) NSMutableArray *activeQueue;
@property (nonatomic, assign) BOOL isOperationDoing;
@property (nonatomic, copy) OperationQueueFinished queueFinished;
@property (nonatomic, copy) OperationFinished operationFinished;

@end

@implementation CKOperationQueue

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [NSMutableArray array];
        _activeQueue = [NSMutableArray array];
        _maxConcurrentOperation = 0;
    }
    return self;
}

- (NSUInteger)currentOperationCount {
    return [_operationQueue count];
}

- (void)startOperationsWithOperationFinished:(OperationFinished)operationFinished queueFinished:(OperationQueueFinished)queueFinished {
    self.operationFinished = operationFinished;
    self.queueFinished = queueFinished;
    [self doOperations];
}

- (void)doOperations {
    NSInteger leftCount = _operationQueue.count;
    NSInteger activeCount = _activeQueue.count;
    NSInteger canOperationCount = _maxConcurrentOperation == 0 ? leftCount : MIN(_maxConcurrentOperation - [_activeQueue count], leftCount);
    if ((leftCount + activeCount) == 0) {
        if (self.queueFinished) {
            self.queueFinished();
        }
    }else{
        __weak CKOperationQueue *weakself = self;
        NSArray *tempOperationQueue = [NSArray arrayWithArray:_operationQueue];
        for (NSInteger i = 0; i < canOperationCount; i ++) {
            CKRequest *request = tempOperationQueue[i];
            [_activeQueue addObject:request];
            [_operationQueue removeObject:request];
            [request send:^(CKRequest *request, CKResponse *response) {
                if (weakself.operationFinished) {
                    weakself.operationFinished(request,response,nil);
                }
                [weakself.activeQueue removeObject:request];
                [weakself doOperations];
            } errorCallback:^(CKRequest *request, NSError *error) {
                if (weakself.operationFinished) {
                    weakself.operationFinished(request,nil,error);
                }
                [weakself.activeQueue removeObject:request];
                [weakself doOperations];
            }];
        }
    }
}

- (void)addOperation:(CKRequest *)operation {
    if (!_isOperationDoing) {
        if ([operation isKindOfClass:[CKRequest class]]) {
            [_operationQueue addObject:operation];
        }
    }
}

- (void)cancelAllOperations {
    for (CKRequest *request in _operationQueue) {
        [request cancelRequest];
        [_operationQueue removeObject:request];
    }
    [_activeQueue removeAllObjects];
    _isOperationDoing = NO;
}

- (void)dealloc {
    
}

@end
