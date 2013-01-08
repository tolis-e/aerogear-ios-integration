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

@implementation WorldOfWarcraft_PipeTests {
    AGPipeline* wowPipeline;
}

-(void)setUp {
    [super setUp];
    
    // setting up the pipeline for the WoW pipes:
    NSURL* baseURL = [NSURL URLWithString:@"http://us.battle.net/api/wow"];
    wowPipeline = [AGPipeline pipelineWithBaseURL:baseURL];
}

-(void)tearDown {
    [super tearDown];
}

-(void) testWoWStatus {
    [wowPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"status"];
        [config setEndpoint: @"realm/status"]; //endpoint with no trailing slash
        [config setType:@"REST"];
    }];
    
    id<AGPipe> wowStatusPipe = [wowPipeline pipeWithName:@"status"];
    
    [wowStatusPipe read:^(id responseObject) {
        NSLog(@"%@", responseObject);
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self setFinishRunLoop:YES];
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testWoW_CharacterRace{
    [wowPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"races"];
        [config setEndpoint: @"data/character/races"]; //endpoint with no trailing slash
        [config setType:@"REST"];
    }];
    
    id<AGPipe> wowStatusPipe = [wowPipeline pipeWithName:@"races"];
    
    [wowStatusPipe read:^(id responseObject) {
        NSLog(@"%@", responseObject);
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void) testWoWRecipe{
    [wowPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"recipe33994"];
        [config setEndpoint: @"recipe/33994"]; //endpoint with no trailing slash
        [config setType:@"REST"];
    }];
    
    id<AGPipe> wowStatusPipe = [wowPipeline pipeWithName:@"recipe33994"];
    
    [wowStatusPipe read:^(id responseObject) {
        NSLog(@"%@", responseObject);
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self setFinishRunLoop:YES];
        STFail(@"%@", error);
    }];
    
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
