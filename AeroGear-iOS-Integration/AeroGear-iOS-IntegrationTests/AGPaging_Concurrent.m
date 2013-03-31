/*
 * JBoss, Home of Professional Open Source
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <libkern/OSAtomic.h>
#import "AGAbstractBaseTestClass.h"


@interface AGPaging_Concurrent : AGAbstractBaseTestClass
@end

@implementation AGPaging_Concurrent {
    AGPipeline* _agPipeline;
    id<AGPipe> _cars;
}

-(void)setUp {
    [super setUp];
    
    // setting up the pipeline for the AeroGear Controller pipe
    NSURL* baseURL = [NSURL URLWithString:@"https://controller-aerogear.rhcloud.com/aerogear-controller-demo"];
    _agPipeline = [AGPipeline pipelineWithBaseURL:baseURL];
    
    _cars = [_agPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"cars-custom"];
        [config setNextIdentifier:@"AG-Links-Next"];
        [config setPreviousIdentifier:@"AG-Links-Previous"];
        [config setMetadataLocation:@"header"];
    }];
}

-(void)tearDown {
    [super tearDown];
}


-(void)testConcurrentMoveNextAndPrevious {
    // get the concurrent dispatch queue
    // to schedule concurrent paging requests
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // the number of pending executing blocks
    // decrement when each block finishes
    // each block once finishes decrements the variable
    // once reached to 0 we finish the test case
    __block int32_t count = 2;
    
    dispatch_async(queue, ^{
        __block NSMutableArray *pagedResultSet;
        
        // fetch the first page
        [_cars readWithParams:@{@"color" : @"black", @"offset" : @"0", @"limit" : @1} success:^(id responseObject) {
            pagedResultSet = responseObject;  // page 1
            
            // hold the "car id" from the first page, so that
            // we can match with the result when we move
            // to the next page down in the test.
            NSString *car_id = [self extractCarId:responseObject];

            // move to the second page
            [pagedResultSet next:^(id responseObject) {
                
                // move backwards (aka. page 1)
                [pagedResultSet previous:^(id responseObject) {
                    
                    STAssertEqualObjects(car_id, [self extractCarId:responseObject], @"id's must match.");

                    OSAtomicDecrement32(&count);
                    
                } failure:^(NSError *error) {
                    STFail(@"%@", error);
                    OSAtomicDecrement32(&count);
                }];
            } failure:^(NSError *error) {
                STFail(@"%@", error);
                OSAtomicDecrement32(&count);
            }];
        } failure:^(NSError *error) {
            STFail(@"%@", error);
            OSAtomicDecrement32(&count);
        }];
    });
        
    dispatch_async(queue, ^{
        __block NSMutableArray *pagedResultSet;
        
        // fetch the second page
        [_cars readWithParams:@{@"color" : @"black", @"offset" : @"1", @"limit" : @1} success:^(id responseObject) {
            pagedResultSet = responseObject;  // page 1
            
            // hold the "car id" from the second page, so that
            // we can match with the result when we return
            // to the second page down in the test.
            NSString *car_id = [self extractCarId:responseObject];

            // move to the first page
            [pagedResultSet previous:^(id responseObject) {
                
                // move again to the second page
                [pagedResultSet next:^(id responseObject) {
                    
                    STAssertEqualObjects(car_id, [self extractCarId:responseObject], @"id's must match.");
                    OSAtomicDecrement32(&count);
                    
                } failure:^(NSError *error) {
                    STFail(@"%@", error);
                    OSAtomicDecrement32(&count);
                }];
            } failure:^(NSError *error) {
                STFail(@"%@", error);
                OSAtomicDecrement32(&count);
            }];
        } failure:^(NSError *error) {
            STFail(@"%@", error);
            OSAtomicDecrement32(&count);
        }];
    });

    // keep the run loop going
    // while pending blocks are executing
    while(count != 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// helper method to extract the "car id" from the result set
-(NSString*)extractCarId:(NSArray*) responseObject {
    return [[[responseObject objectAtIndex:0] objectForKey:@"id"] stringValue];
}

@end
