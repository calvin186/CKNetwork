//
//  CKOperationQueue.h
//  Start
//
//  Created by calvin on 16/7/7.
//  Copyright © 2016年 DingSNS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRequest.h"
#import "CKResponse.h"

typedef void (^OperationFinished)(CKRequest *request, CKResponse *response, NSError *error);
typedef void (^OperationQueueFinished)(void);

@interface CKOperationQueue : NSObject

/**
 *  最大请求开始数，默认为0，并发请求
 */
@property (nonatomic, assign) NSInteger maxConcurrentOperation;
@property (nonatomic, readonly) NSUInteger currentOperationCount;

- (void)addOperation:(CKRequest *)operation;
- (void)startOperationsWithOperationFinished:(OperationFinished)operationFinished queueFinished:(OperationQueueFinished)queueFinished;
- (void)cancelAllOperations;

@end
