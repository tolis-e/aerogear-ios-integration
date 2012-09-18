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

#import "AGAbstractBaseTestClass.h"


@interface AGRestPipe_ProjectTests : AGAbstractBaseTestClass
@end

@implementation AGRestPipe_ProjectTests {
    id<AGPipe> projects;
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
    
    // setting up the pipeline and the pipe for the projects:
    // basic setup, for every test:
    // create the 'todo' pipeline;

    NSURL* projectsURL = [NSURL URLWithString:@"http://localhost:8080/todo-server/"];
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"projects" baseURL:projectsURL type:@"REST"];
    
    // get access to the projects pipe
    projects = [todo get:@"projects"];
    
    
}

-(void)tearDown {
    [super tearDown];
}

// CREATE
-(void)testCreateProject {
    
    // a new project object, structure looks like:
    NSMutableDictionary* project = [NSMutableDictionary dictionary];
    [project setValue:@"itest project" forKey:@"title"];
    
    [projects save:project success:^(id responseObject) {
        STAssertEqualObjects(@"itest project", [responseObject valueForKey:@"title"], @"did create project");
        
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
-(void)testReadProjects {
    [projects read:^(id responseObject) {
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
-(void)testUpdateProject {
    NSMutableDictionary* updateproject = [NSMutableDictionary dictionary];
    [updateproject setValue:@"updated by a test-case" forKey:@"title"];
    [updateproject setValue:__createId forKey:@"id"];
    
    
    [projects save:updateproject success:^(id responseObject) {
        STAssertEqualObjects(__createId, [[responseObject valueForKey:@"id"] stringValue], @"did create project");
        
        
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
-(void)test_DeleteProject {
    [projects remove:__createId success:^(id responseObject) {
        
        // see if the read is empty now.....
        [projects read:^(id responseObject) {
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
