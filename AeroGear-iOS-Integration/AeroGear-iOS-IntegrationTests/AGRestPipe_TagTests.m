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


@interface AGRestPipe_TagTests : AGAbstractBaseTestClass
@end

@implementation AGRestPipe_TagTests {
    id<AGAuthenticationModule> _authModule;
    id<AGPipe> _tags;
}

//hack:
NSString* __createId;

-(void)setUp {
    [super setUp];
    
    // setting up authenticator, pipeline and the pipe for the projects:
    // basic setup, for every test
    
    NSURL* projectsURL = [NSURL URLWithString:@"https://todo-aerogear.rhcloud.com/todo-server/"];
    
    // create the authenticator
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    _authModule = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"myModule"];
        [config setBaseURL:projectsURL];
    }];
    
    // set up the pipeline for the projects
    AGPipeline* todo = [AGPipeline pipelineWithBaseURL:projectsURL];
    [todo pipe:^(id<AGPipeConfig> config) {
        [config setName:@"tags"];
        [config setBaseURL:projectsURL];
        [config setAuthModule:_authModule];
        [config setType:@"REST"];
        [config setRecordId:@"id"];
    }];
    
    // get access to the tags pipe
    _tags = [todo pipeWithName:@"tags"];
}

-(void)tearDown {
    [super tearDown];
}

// CREATE
-(void)testCreateTag {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {

        // a new tag object, structure looks like:
        NSMutableDictionary* tag = [NSMutableDictionary dictionary];
        [tag setValue:@"itest tag" forKey:@"title"];
        
        // save tag
        [_tags save:tag success:^(id responseObject) {
            STAssertEqualObjects(@"itest tag", [responseObject valueForKey:@"title"], @"did create tag");
            
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
-(void)testReadTags {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {
        
        // read all tags
        [_tags read:^(id responseObject) {
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

-(void)testReadSingleTag {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {
        
        // save the updated project on server
        [_tags read:__createId success:^(id responseObject) {
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
-(void)testUpdateTag {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {
        
        NSMutableDictionary* tag = [NSMutableDictionary dictionary];
        [tag setObject:@"updated by a test-case" forKey:@"title"];
        [tag setValue:__createId forKey:@"id"];        
        
        // save the updated tag on server
        [_tags save:tag success:^(id responseObject) {
            STAssertEqualObjects(__createId,
                                 [[responseObject valueForKey:@"id"] stringValue], @"did update tag");
            
            
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
-(void)test_DeleteTag {
    // login....
    [_authModule login:@"john" password:@"123" success:^(id object) {
        
        NSMutableDictionary* tag = [NSMutableDictionary dictionary];
        [tag setValue:__createId forKey:@"id"];

        // remove tag
        [_tags remove:tag success:^(id responseObject) {
            
            // see if the read is empty now.....
            [_tags read:^(id responseObject) {
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
