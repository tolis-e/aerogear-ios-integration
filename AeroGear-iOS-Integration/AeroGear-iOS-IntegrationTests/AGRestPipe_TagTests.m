/*
 * JBoss, Home of Professional Open Source
 * Copyright 2012, Red Hat, Inc., and individual contributors
 * by the @authors tag. See the copyright.txt in the distribution for a
 * full listing of individual contributors.
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

#import "AGRestPipe_TagTests.h"

@implementation AGRestPipe_TagTests {
    id<AGPipe> tags;
}

//hack:
NSString* __createId;

- (id)init
{
    self = [super init];
    if (self) {
        // base inits:
    }
    return self;
}


-(void)setUp {
    [super setUp];
    
    // setting up the pipeline and the pipe for the Tags:
    // basic setup, for every test:
    // create the 'todo' pipeline;
    
    NSString* base = @"http://localhost:8080/todo-server/";
    NSString* urlWithEndpoint = [base stringByAppendingString:@"tags/"];
    
    NSURL* projectsURL = [NSURL URLWithString:urlWithEndpoint];
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"tags" url:projectsURL type:@"REST"];
    
    // get access to the projects pipe
    tags = [todo get:@"tags"];
    
    
}

-(void)tearDown {
    [super tearDown];
}

// CREATE
-(void)testCreateTag {
    
    // a new tag object, structure looks like:
    NSMutableDictionary* tag = [NSMutableDictionary dictionary];
    [tag setValue:@"itest tag" forKey:@"title"];
    
    [tags save:tag success:^(id responseObject) {
        STAssertEqualObjects(@"itest tag", [responseObject valueForKey:@"title"], @"did create tag");

        __createId = [[responseObject valueForKey:@"id"] stringValue];

        [self setFinishRunLoop:YES];
        
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


// READ
-(void)testReadTags {
    [tags read:^(id responseObject) {
        NSLog(@"%@", responseObject);
        STAssertTrue(0 < [responseObject count], @"should NOT be empty...");

        [self setFinishRunLoop:YES];
        
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];

    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}

// UPDATE
-(void)testUpdateTag {
    NSMutableDictionary* updateTag = [NSMutableDictionary dictionary];
    [updateTag setValue:@"updated by a test-case" forKey:@"title"];
    [updateTag setValue:__createId forKey:@"id"];
    
    
    [tags save:updateTag success:^(id responseObject) {
        STAssertEqualObjects(__createId, [[responseObject valueForKey:@"id"] stringValue], @"did create tag");
        
        
        __createId = [[responseObject valueForKey:@"id"] stringValue];
        
        [self setFinishRunLoop:YES];
        
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// DELETE:
// awful name... but this needs to run after UPDATE...
-(void)test_DeleteTag {
    [tags remove:__createId success:^(id responseObject) {
        
        // see if the read is empty now.....
        [tags read:^(id responseObject) {
            STAssertTrue(0 == [responseObject count], @"should be empty...");
            
            [self setFinishRunLoop:YES];
            
        } failure:^(NSError *error) {
            STFail(@"%@", error);
        }];
        
        
        
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


@end
