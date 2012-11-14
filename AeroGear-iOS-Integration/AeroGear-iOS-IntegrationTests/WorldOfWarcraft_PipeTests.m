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

@interface WorldOfWarcraft_PipeTests : AGAbstractBaseTestClass

@end

@implementation WorldOfWarcraft_PipeTests

-(void) testWoWStatus {
    
    NSURL* baseURL = [NSURL URLWithString:@"http://us.battle.net/api/wow"];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    [pipeline pipe:^(id<AGPipeConfig> config) {
        [config name:@"status"];
        [config endpoint: @"realm/status"]; //endpoint with no trailing slash
        [config type:@"REST"];
    }];
    
    id<AGPipe> wowStatusPipe = [pipeline get:@"status"];
    
    [wowStatusPipe read:^(id responseObject) {
        NSLog(@"==>data %@", responseObject);
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        NSLog(@"==>ERRROR %@", error);
        [self setFinishRunLoop:YES];
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}
-(void) xtest404 {
    
    NSURL* baseURL = [NSURL URLWithString:@"https://todo-aerogear.rhcloud.com/todo-server"];
    AGPipeline* pipeline = [AGPipeline pipeline:baseURL];
    [pipeline pipe:^(id<AGPipeConfig> config) {
        [config name:@"projwwwects"];
        [config type:@"REST"];
    }];
    
    id<AGPipe> wowStatusPipe = [pipeline get:@"projwwwects"];
    
    [wowStatusPipe read:^(id responseObject) {
        NSLog(@"==>data %@", responseObject);
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        NSLog(@"==>ERRROR %@", error);
        [self setFinishRunLoop:YES];
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
