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

#import "AGRestPipeTests.h"
#import "AeroGear.h"

@implementation AGRestPipeTests {
    BOOL _finishedFlag;
    id<AGPipe> projectPipe;
}

-(void)setUp {
    [super setUp];
    _finishedFlag = NO;
    
    NSURL* projectsURL = [NSURL URLWithString:@"http://todo-aerogear.rhcloud.com/todo-server/projects/"];
    AGPipeline* todo = [AGPipeline pipelineWithPipe:@"projects" url:projectsURL type:@"REST"];
    
    // get access to the projects pipe
    projectPipe = [todo get:@"projects"];
}

-(void)tearDown {
    projectPipe = nil;
    [super tearDown];
}

-(void) testReadFromRESTfulPipe {
    
    [projectPipe read:^(id responseObject) {
        
        NSLog(@"Projects: %@", [responseObject description]);
        _finishedFlag = YES;
        
    } failure:^(NSError *error) {
        
        NSLog(@"Read: An error occured! \n%@", error);
    }];
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testCreateAndDeleteProject {
    NSMutableDictionary* newProject = [NSMutableDictionary dictionary];
    
    // {"title":"my title","style":"project-232-96-96"}
    [newProject setValue:@"Integration Test" forKey:@"title"];
    [newProject setValue:@"project-255-255-255" forKey:@"style"];
    
    // stash the id for the created resource;
    __block id resourceId;
    
    [projectPipe save:newProject success:^(id responseObject) {
        
        NSLog(@"Create Response\n%@", [responseObject description]);
        
        resourceId = [responseObject valueForKey:@"id"];
        
        
        // Once created and we got the response.... let's delete it :-) !!
        [projectPipe remove:resourceId success:^(id responseObject) {
            
            NSLog(@"Delete Response\n%@", [responseObject description]);
            _finishedFlag = YES;
            
        } failure:^(NSError *error) {
            
            NSLog(@"Delete: An error occured! \n%@", error);
        }];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Create: An error occured! \n%@", error);
    }];
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testUpdateProject {
    NSMutableDictionary* newProject = [NSMutableDictionary dictionary];
    
    // {"title":"my title","style":"project-232-96-96"}
    [newProject setValue:@"306" forKey:@"id"];
    [newProject setValue:@"matzew: do NOT delete!" forKey:@"title"];
    [newProject setValue:@"project-255-255-255" forKey:@"style"];
    

    [projectPipe save:newProject success:^(id responseObject) {
        
        NSLog(@"Update Response\n%@", [responseObject description]);
        _finishedFlag = YES;
        
        id updatedId = [responseObject valueForKey:@"id"];
        
        STAssertEqualObjects([newProject valueForKey:@"id"], [updatedId stringValue], @"Updated ID should match");
        
    } failure:^(NSError *error) {
        
        NSLog(@"Update: An error occured! \n%@", error);
    }];
    
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
