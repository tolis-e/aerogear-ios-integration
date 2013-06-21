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

static NSString *const PASSING_USERNAME = @"john";
static NSString *const FAILING_USERNAME = @"fail";

static NSString *const LOGIN_PASSWORD = @"123";
static NSString *const ENROLL_PASSWORD = @"123";

@interface AGRestAuthenticationTests : AGAbstractBaseTestClass

@end

@implementation AGRestAuthenticationTests {
    id<AGAuthenticationModule> _authModule;
}

-(void)setUp {
    [super setUp];
    
    // setting up authenticator
    NSURL* projectsURL = [NSURL URLWithString:@"https://todo-aerogear.rhcloud.com/todo-server/"];
    
    // create the authenticator
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    _authModule = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"myModule"];
        [config setBaseURL:projectsURL];
    }];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testRestAuthenticationCreation {
    STAssertNotNil(_authModule, @"module should not be nil");
}

-(void)testLoginSuccess {
    [_authModule login:@{@"username":PASSING_USERNAME, @"password":LOGIN_PASSWORD} success:^(id responseObject) {
        STAssertEqualObjects(PASSING_USERNAME, [responseObject valueForKey:@"username"], @"should be equal");
        
        [_authModule logout:^{
            [self setFinishRunLoop:YES];
        } failure:^(NSError *error) {
            STFail(@"should have logout");
            [self setFinishRunLoop:YES];
        }];
        
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"should have login", error);
    }];
    
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testLoginFails {
    [_authModule login:@{@"username":FAILING_USERNAME, @"password":LOGIN_PASSWORD} success:^(id responseObject) {
        STFail(@"should NOT have been called");
        
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
    }];
    
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testLogoutWithoutLogin {
    [_authModule logout:^{
        STFail(@"should NOT have been called");
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
    }];
        
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testEnrollSuccess {
    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    
    // generate a 'unique' username otherwise server will throw
    // an error if we reuse an existing username
    NSString* username = [self generateUUID];
    
    [registerPayload setValue:@"John" forKey:@"firstname"];
    [registerPayload setValue:@"Doe" forKey:@"lastname"];
    [registerPayload setValue:@"emaadsil@mssssse.com" forKey:@"email"];
    [registerPayload setValue:username forKey:@"username"];
    [registerPayload setValue:LOGIN_PASSWORD forKey:@"password"];
    [registerPayload setValue:@"simple" forKey:@"role"];
    
    [_authModule enroll:registerPayload success:^(id responseObject) {
        STAssertEqualObjects(username, [responseObject valueForKey:@"username"], @"should be equal");
        
        [_authModule logout:^{
            [self setFinishRunLoop:YES];
        } failure:^(NSError *error) {
            STFail(@"should have logout");
            [self setFinishRunLoop:YES];
        }];
        
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
        STFail(@"should have enroll", error);
    }];
    
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testEnrollFails {
    NSMutableDictionary* registerPayload = [NSMutableDictionary dictionary];
    
    // registration fields are missing (see testEnroll)
    [registerPayload setValue:@"Bogus" forKey:@"bogus"];
    
    [_authModule enroll:registerPayload success:^(id responseObject) {
        STFail(@"should NOT have been called");
        [self setFinishRunLoop:YES];
    } failure:^(NSError *error) {
        [self setFinishRunLoop:YES];
    }];
    
    // keep the run loop going
    while(![self finishRunLoop]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// util method to generate a unique id
- (NSString *) generateUUID {
    CFUUIDRef UUID = CFUUIDCreate(NULL);
    NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, UUID);
    CFRelease(UUID);
    
    return UUIDString;
}

@end
