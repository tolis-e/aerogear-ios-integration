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


@interface AGRestPipe_ProjectTests : AGAbstractBaseTestClass
@end

@implementation AGRestPipe_ProjectTests {
    id<AGAuthenticationModule> _authModule;
    id<AGPipe> _projects;
}

//hack:
NSString* __createId;

-(void)setUp {
    [super setUp];
    
    // setting up authenticator, pipeline and the pipe for the projects:
    // basic setup, for every test

    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/"];
    
    // create the authenticator
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    _authModule = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"myModule"];
        [config setBaseURL:projectsURL];
    }];
    
    // set up the pipeline for the projects
    AGPipeline* todo = [AGPipeline pipelineWithBaseURL:projectsURL];
    [todo pipe:^(id<AGPipeConfig> config) {
        [config setName:@"projects"];
        [config setBaseURL:projectsURL];
        [config setAuthModule:_authModule];
        [config setType:@"REST"];
        [config setRecordId:@"id"];
    }];
    
    // get access to the projects pipe
    _projects = [todo pipeWithName:@"projects"];
}

-(void)tearDown {
    [super tearDown];
}

// CREATE
-(void)testCreateProject {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {

    // a new project object, structure looks like:
    NSMutableDictionary* project = [NSMutableDictionary dictionary];
    [project setValue:@"itest project" forKey:@"title"];
    
    // save project
    [_projects save:project success:^(id responseObject) {
        STAssertEqualObjects(@"itest project", [responseObject valueForKey:@"title"], @"did create project");
        
        // store the id for this newly created object
        __createId = [[responseObject valueForKey:@"id"] stringValue];

        
        // now, we need to logout:
        [_authModule logout:^{
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

// READ
-(void)testReadProjects {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {
    
    // read all projects
    [_projects read:^(id responseObject) {
        NSLog(@"%@", responseObject);
        STAssertTrue(0 < [responseObject count], @"should NOT be empty...");
        
        // now, we need to logout:
        [_authModule logout:^{
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

-(void)testReadSingleProject {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {
        
        // save the updated project on server
        [_projects read:__createId success:^(id responseObject) {
            STAssertEqualObjects(__createId,
                                 [[responseObject valueForKey:@"id"] stringValue], @"did read single project");
            
            // now, we need to logout:
            [_authModule logout:^{
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

// UPDATE
-(void)testUpdateProject {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {

    NSMutableDictionary* project = [NSMutableDictionary dictionary];
    [project setValue:@"updated by a test-case" forKey:@"title"];
    [project setValue:__createId forKey:@"id"];

    // save the updated project on server
    [_projects save:project success:^(id responseObject) {
        STAssertEqualObjects(__createId,
                             [[responseObject valueForKey:@"id"] stringValue], @"did update project");

        // now, we need to logout:
        [_authModule logout:^{
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

// DELETE:
// awful name... but this needs to run after UPDATE...
-(void)test_DeleteProject {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {
        
    NSMutableDictionary* project = [NSMutableDictionary dictionary];
    [project setValue:@"updated by a test-case" forKey:@"title"];
    [project setValue:__createId forKey:@"id"];
        
    // remove project
    [_projects remove:project success:^(id responseObject) {
        
        // see if the read is empty now.....
        [_projects read:__createId success:^(id responseObject) {
            STAssertTrue(0 == [responseObject count], @"should be empty...");
            
            // now, we need to logout:
            [_authModule logout:^{
                [self setFinishRunLoop:YES];
            } failure:^(NSError *error) {
                [self setFinishRunLoop:YES];
                STFail(@"%@", error);
            }];
            
        } failure:^(NSError *error) {
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
