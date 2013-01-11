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

@implementation AGAbstractBaseTestClass

@synthesize finishRunLoop = _finishRunLoop;

// abstract:
- (id)init
{
    if ([self class] == [AGAbstractBaseTestClass class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
          reason:@"Error, attempting to instantiate AGAbstractBaseTestClass directly." userInfo:nil];
    }
    
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}


-(void)setUp {
    [super setUp];
    _finishRunLoop = NO;
}

-(void)tearDown {
    [super tearDown];
}


@end
