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

#import "AGIntegrationTests.h"
#import "AeroGear.h"

@implementation AGIntegrationTests {
    BOOL _finishedFlag;
}

- (void)setUp
{
    [super setUp];
    _finishedFlag = NO;
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testReadAllProjects
{
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"projects" url:projectsURL type:@"REST"];
    
    id<AGPipe> projects = [todo get:@"projects"];
    
    [projects read:^(id responseObject) {
        NSLog(@"INTEGRATION TESTS RESPONSE\n%@", [responseObject description]);
        
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];
    
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


@end