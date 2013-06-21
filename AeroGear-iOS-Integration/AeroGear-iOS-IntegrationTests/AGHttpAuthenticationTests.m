/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGAbstractBaseTestClass.h"

static NSString *const PASSING_USERNAME = @"agnes";
static NSString *const FAILING_USERNAME = @"fail";

static NSString *const LOGIN_PASSWORD = @"123";

/*
 * Test authentication against HTTP Basic/Digest configured server
 * using the NSURLCredential configured on the
 * pipe through the [setCredential] configuration option.
 * 
 */
@interface AGHttpAuthenticationTests : AGAbstractBaseTestClass

@end

@implementation AGHttpAuthenticationTests {
    NSURL *_baseURL;
    AGPipeline *_pipeline;
}

- (void)setUp {
    [super setUp];
    
    // the remote server is configured with 'HTTP Digest' authentication
    _baseURL = [NSURL URLWithString:@"http://controller-aerogear.rhcloud.com/aerogear-controller-demo"];

    // set up the pipeline
    _pipeline = [AGPipeline pipelineWithBaseURL:_baseURL];
}

- (void)tearDown {
    // a bug in the controller-demo has the effect
    // of setting a cookie after successfully authentication.
    // This has the effect of the 'testLoginFails' to successfully
    // authenticate with wrong credentials, cause iOS lib
    // will re-use the cookie from 'testLoginSuccess'.
    // Once https://issues.jboss.org/browse/AGSEC-73 is
    // resolved, clearing of the cooking store won't be needed
    // and can be removed.
    // ----------
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:_baseURL];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    // ----------
    
    [super tearDown];
}

- (void)testLoginSuccess {
    id <AGPipe> pipe = [_pipeline pipe:^(id <AGPipeConfig> config) {
        [config setName:@"autobots"];
        // correct credentials
        [config setCredential:[NSURLCredential
                credentialWithUser:PASSING_USERNAME password:LOGIN_PASSWORD persistence:NSURLCredentialPersistenceNone]];
    }];

    [pipe read:^(id responseObject) {
        [self setFinishRunLoop:YES];
    }  failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"should have read", error);
    }];

    // keep the run loop going
    while (![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// adjust the name so that it runs at the
// end of test suite.
- (void)test_LoginFails {
    id <AGPipe> pipe = [_pipeline pipe:^(id <AGPipeConfig> config) {
        [config setName:@"autobots"];
        // wrong credentials
        [config setCredential:[NSURLCredential
                credentialWithUser:FAILING_USERNAME password:LOGIN_PASSWORD persistence:NSURLCredentialPersistenceNone]];
    }];

    [pipe read:^(id responseObject) {
        [self setFinishRunLoop:YES];
        STFail(@"should NOT have been called");
    }  failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
    }];

    // keep the run loop going
    while (![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
