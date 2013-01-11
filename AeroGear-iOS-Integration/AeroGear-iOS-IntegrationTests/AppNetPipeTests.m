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

@interface AppNetPipeTests : AGAbstractBaseTestClass

@end
@implementation AppNetPipeTests {
    AGPipeline* appNetPipeline;
}

-(void)setUp {
    [super setUp];
    
    // setting up the pipeline for the WoW pipes:
    NSURL* baseURL = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/"];
    appNetPipeline = [AGPipeline pipelineWithBaseURL:baseURL];
}

-(void)tearDown {
    [super tearDown];
}

-(void) testAppNetPipeline {
    [appNetPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"globalStream"];
        [config setEndpoint: @"posts/stream/global"]; //endpoint with no trailing slash
        [config setType:@"REST"];
    }];
    
    id<AGPipe> wowStatusPipe = [appNetPipeline pipeWithName:@"globalStream"];
    
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



@end
