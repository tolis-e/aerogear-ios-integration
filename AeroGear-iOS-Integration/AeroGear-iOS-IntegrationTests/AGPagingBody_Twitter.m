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

@interface AGPagingBody_Twitter : AGAbstractBaseTestClass
@end

@implementation AGPagingBody_Twitter {
    id<AGPipe> _tweets;
}

-(void)setUp {
    [super setUp];
    
    // setting up the pipeline for the Twitter pipe
    NSURL* baseURL = [NSURL URLWithString:@"http://search.twitter.com/"];
    AGPipeline* twPipeline = [AGPipeline pipelineWithBaseURL:baseURL];
    
    _tweets = [twPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"search.json"];

        [config setNextIdentifier:@"next_page"];
        [config setPreviousIdentifier:@"previous_page"];

        [config setMetadataLocation:@"body"];
    }];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testNext {
    __block NSMutableArray *pagedResultSet;
    
    // fetch the first page
    [_tweets readWithParams:@{@"q" : @"aerogear", @"page" : @"1", @"rpp" : @"1"} success:^(id responseObject) {
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
    [_tweets readWithParams:@{@"q" : @"aerogear", @"page" : @"1", @"rpp" : @"1"} success:^(id responseObject) {
        pagedResultSet = responseObject;  // page 1
        
        // move back to an invalid page
        [pagedResultSet previous:^(id responseObject) {
            pagedResultSet = responseObject;  // invalid page
            [self setFinishRunLoop:YES];
            
            STFail(@"should not have called");
            
        } failure:^(NSError *error) {
            [self setFinishRunLoop:YES];
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
    [_tweets readWithParams:@{@"q" : @"aerogear", @"page" : @"1", @"rpp" : @"1"} success:^(id responseObject) {
        pagedResultSet = responseObject;  // page 1
       
        // use to hold the first page results so
        // that can be tested against when we
        // move backwards down in the test
        NSArray* page1 = [self removeAndWrapResult:[pagedResultSet objectAtIndex:0]];
        
        // move to the second page
        [pagedResultSet next:^(id responseObject) {
            pagedResultSet = responseObject;  // page 2
            
            // move backwards (aka. page 1)
            [pagedResultSet previous:^(id responseObject) {
                pagedResultSet = responseObject;  // page 1
                
                NSArray* page1_ret = [self removeAndWrapResult:[pagedResultSet objectAtIndex:0]];
                STAssertEqualObjects(page1, page1_ret, @"results must match.");
                
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

// helper to remove the changing at each request value "completed_in"
// from the result set
-(NSArray*)removeAndWrapResult:(NSDictionary*) result {
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:result];
    [results removeObjectForKey:@"completed_in"];
    
    return [NSArray arrayWithObjects:results, nil];
}

@end