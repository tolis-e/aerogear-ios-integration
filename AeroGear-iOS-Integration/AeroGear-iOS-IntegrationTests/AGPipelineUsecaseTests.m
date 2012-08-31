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

#import "AGPipelineUsecaseTests.h"
#import "AGPipeline.h"
#import "AGPipe.h"

@implementation AGPipelineUsecaseTests {
    BOOL _finishedFlag;
    
    id<AGPipe> projects;
}

// TODO: static hack...
NSMutableDictionary* projectEntity;

-(void)setUp {
    [super setUp];
    _finishedFlag = NO;
    
    // basic setup, for every test:
    // create the 'todo' pipeline;
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"projects" url:projectsURL type:@"REST"];
    
    // get access to the projects pipe
    projects = [todo get:@"projects"];
    
    
}

-(void)tearDown {
    projects = nil;
    [super tearDown];
}

-(void) testCreateTodoPipelineAndCreateProject{
    // PIPELINE is created in setup
    
    
    // create a 'new' project entity...
    // using NS(Mutable)Dictionary, for now..........
    
    projectEntity = [NSMutableDictionary dictionary];
    [projectEntity setValue:@"Hello World" forKey:@"title"];
    
    
    // save the 'new' project:
    [projects save:projectEntity success:^(id responseObject) {
        NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
        
        // get the id of the new project:
        id resourceId = [responseObject valueForKey:@"id"];
        // update the 'object'.....
        [projectEntity setValue:[resourceId stringValue] forKey:@"id"];
        
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];
    
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


-(void) testCreateTodoPipelineAndUpdateProject{
    
    // change the title of the project:
    [projectEntity setValue:@"Hello Update World!" forKey:@"title"];
    
    
    [projects save:projectEntity success:^(id responseObject) {
        NSLog(@"UPDATE RESPONSE\n%@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"UPDATE: An error occured! \n%@", error);
    }];
    
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testCreateTodoPipelineAnd_RemoveProject{
    // just remove this project:
    [projects remove:[projectEntity objectForKey:@"id"] success:^(id responseObject) {
        NSLog(@"DELETE RESPONSE\n%@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"DELETE: An error occured! \n%@", error);
    }];
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


@end