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

@interface AGPagingWebLinking_GitHub : AGAbstractBaseTestClass
@end

@implementation AGPagingWebLinking_GitHub {
    id<AGPipe> _gists;
}

-(void)setUp {
    [super setUp];
    
    // setting up the pipeline for the GitHub pipe
    NSURL* baseURL = [NSURL URLWithString:@"https://api.github.com/users/matzew/"];
    AGPipeline* ghPipeline = [AGPipeline pipelineWithBaseURL:baseURL];
    
    _gists = [ghPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"gists"];
        [config setPreviousIdentifier:@"prev"];        
    }];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testNext {
    __block NSMutableArray *pagedResultSet;
    
    // fetch the first page
    [_gists readWithParams:@{@"page" : @"0", @"per_page" : @"1"} success:^(id responseObject) {
        pagedResultSet = responseObject;  // page 1
        
        NSMutableArray *page1 = [pagedResultSet copy];
        
        // move to the next page
        [pagedResultSet next:^(id responseObject) {
            pagedResultSet = responseObject;
            
            STAssertFalse([page1 isEqualToArray:pagedResultSet], @"results should not match.");
            
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
    [_gists readWithParams:@{@"page" : @"0", @"per_page" : @"1"} success:^(id responseObject) {
        pagedResultSet = responseObject;  // page 1
        
        // move back from the first page
        [pagedResultSet previous:^(id responseObject) {
            pagedResultSet = responseObject;  // page 2
            
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

-(void)testMoveNextAndPrevious {
    __block NSMutableArray *pagedResultSet;

    // fetch the first page
    [_gists readWithParams:@{@"page" : @"2", @"per_page" : @"1"} success:^(id responseObject) {
        pagedResultSet = responseObject;  // page 1
        
        // use to hold this paged results so
        // that can be tested against when we
        // move backwards down in the test
        NSMutableArray *page1 = [pagedResultSet copy];
        
        // move to the second page
        [pagedResultSet next:^(id responseObject) {
            pagedResultSet = responseObject;  // page 2
            
            // move backwards (aka. page 1)
            [pagedResultSet previous:^(id responseObject) {
                pagedResultSet = responseObject;  // page 1
                
                STAssertEqualObjects(page1, pagedResultSet, @"results must match.");
                
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

@end



