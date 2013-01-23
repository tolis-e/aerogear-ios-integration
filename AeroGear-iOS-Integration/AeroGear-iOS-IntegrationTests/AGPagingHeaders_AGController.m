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

#import "AGAbstractBaseTestClass.h"

@interface AGPagingHeaders_AGController : AGAbstractBaseTestClass
@end

@implementation AGPagingHeaders_AGController {
    id<AGPipe> _cars;
}

-(void)setUp {
    [super setUp];
    
    // setting up the pipeline for the AeroGear Controller pipe
    NSURL* baseURL = [NSURL URLWithString:@"http://controllerdemo-danbev.rhcloud.com/aerogear-controller-demo"];
    AGPipeline* agPipeline = [AGPipeline pipelineWithBaseURL:baseURL];
    
    _cars = [agPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"cars-custom"];
        [config setNextIdentifier:@"AG-Links-Next"];
        [config setPreviousIdentifier:@"AG-Links-Previous"];
        [config setMetadataLocation:@"header"];
    }];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testNext {
    __block NSMutableArray *pagedResultSet;
    
    // fetch the first page
    [_cars readWithParams:@{@"color" : @"black", @"offset" : @"0", @"limit" : [NSNumber numberWithInt:1]} success:^(id responseObject) {
        pagedResultSet = responseObject;  // page 1
        
        // hold the "car id" from the first page, so that
        // we can match with the result when we move
        // to the next page down in the test.
        NSString *car_id = [self extractCarId:responseObject];
        
        // move to the next page
        [pagedResultSet next:^(id responseObject) {
            
            STAssertFalse([car_id isEqualToString:[self extractCarId:responseObject]], @"id's should not match.");
            
            [self setFinishRunLoop:YES];
            
        } failure:^(NSError *error) {
            [self setFinishRunLoop:YES];
            STFail(@"%@", error);
        }];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testPreviousFromFirstPage {
    __block NSMutableArray *pagedResultSet;
    
    // fetch the first page
    [_cars readWithParams:@{@"color" : @"black", @"offset" : @"0", @"limit" : [NSNumber numberWithInt:1]} success:^(id responseObject) {
        pagedResultSet = responseObject;  // page 1
        
        // move back to an invalid page
        [pagedResultSet previous:^(id responseObject) {
            [self setFinishRunLoop:YES];
            
            STFail(@"should not have called");
            
        } failure:^(NSError *error) {
            [self setFinishRunLoop:YES];

            // Note: "failure block" was called here
            // because we were at the first page and we
            // requested to go previous, that is to a non
            // existing page ("AG-Links-Previous" indentifier
            // was missing from the headers response and we
            // got a 400 http error).
            //
            // Note that this is not always the case, cause some
            // remote apis can send back either an empty list or
            // list with results, instead of throwing an error(see GitHub testcase)
        }];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testMoveNextAndPrevious {
    __block NSMutableArray *pagedResultSet;
    
    // fetch the first page
    [_cars readWithParams:@{@"color" : @"black", @"offset" : @"0", @"limit" : [NSNumber numberWithInt:1]} success:^(id responseObject) {
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
                
                [self setFinishRunLoop:YES];
            } failure:^(NSError *error) {
                [self setFinishRunLoop:YES];
                STFail(@"%@", error);
            }];
        } failure:^(NSError *error) {
            [self setFinishRunLoop:YES];
            STFail(@"%@", error);
        }];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// helper method to extract the "car id" from the result set
-(NSString*)extractCarId:(NSArray*) responseObject {
    return [[[responseObject objectAtIndex:0] objectForKey:@"id"] stringValue];
}

@end
