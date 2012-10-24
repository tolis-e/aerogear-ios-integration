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

@interface AGRestPipe_TaskTests : AGAbstractBaseTestClass
@end

@implementation AGRestPipe_TaskTests {
    id<AGAuthenticationModule> authModule;
    id<AGPipe> tasks;
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
    
    // setting up the pipeline and the pipe for the Tasks:
    // basic setup, for every test:
    // create the 'todo' pipeline;
    
    NSURL* projectsURL = [NSURL URLWithString:@"http://localhost:8080/todo-server/"];
    
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    authModule = [authenticator add:@"myModule" baseURL:projectsURL];
    
    AGPipeline* todo = [AGPipeline pipeline];
    [todo add:@"tasks" baseURL:projectsURL type:@"REST" authModule:authModule];
    
    // get access to the projects pipe
    tasks = [todo get:@"tasks"];
}

-(void)tearDown {
    [super tearDown];
}

// CREATE
-(void)testCreateTask {
    
    // a new task object, structure looks like:
    // {
    //     date = "2012-11-26";
    //     description = "Desk Task 1";
    //     id = 5;
    //     tags = (
    //     );
    //     title = "Task 1";
    // }
    // login....
    [authModule login:@"john" password:@"123" success:^(id object) {
    NSMutableDictionary* task = [NSMutableDictionary dictionary];
    [task setValue:@"2012-11-26" forKey:@"date"];
    [task setValue:@"created by a test-case" forKey:@"description"];
    [task setValue:@"itest task" forKey:@"title"];
    

    [tasks save:task success:^(id responseObject) {
        STAssertEqualObjects(@"itest task", [responseObject valueForKey:@"title"], @"did create task");

        __createId = [[responseObject valueForKey:@"id"] stringValue];
        
        [self setFinishRunLoop:YES];
        
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
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


// READ
-(void)testReadTasks {
    // login....
    [authModule login:@"john" password:@"123" success:^(id object) {
    [tasks read:^(id responseObject) {
        NSLog(@"%@", responseObject);
        STAssertTrue(0 < [responseObject count], @"should NOT be empty...");
        
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
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

// UPDATE
-(void)testUpdateTask {
    
    
    // a new task object, structure looks like:
    // {
    //     date = "2012-11-26";
    //     description = "Desk Task 1";
    //     id = 5;
    //     tags = (
    //     );
    //     title = "Task 1";
    // }
    // login....
    [authModule login:@"john" password:@"123" success:^(id object) {
    NSMutableDictionary* updateTask = [NSMutableDictionary dictionary];
    [updateTask setValue:@"1979-02-03" forKey:@"date"];
    [updateTask setValue:@"updated by a test-case" forKey:@"description"];
    [updateTask setValue:__createId forKey:@"id"];

    
    [tasks save:updateTask success:^(id responseObject) {
        STAssertEqualObjects(__createId, [[responseObject valueForKey:@"id"] stringValue], @"did create task");
        __createId = [[responseObject valueForKey:@"id"] stringValue];
        
        [self setFinishRunLoop:YES];
        
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
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

// DELETE:
// awful name... but this needs to run after UPDATE...
-(void)test_DeleteTask {
    // login....
    [authModule login:@"john" password:@"123" success:^(id object) {
    [tasks remove:__createId success:^(id responseObject) {

        // see if the read is empty now.....
        [tasks read:^(id responseObject) {
            STAssertTrue(0 == [responseObject count], @"should be empty...");
            
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
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
        
}

@end