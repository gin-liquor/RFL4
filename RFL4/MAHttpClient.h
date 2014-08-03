//
//  MAHttpClient.h
//  RFL
//
//  Created by Takuya on 2013/02/15.
//  Copyright (c) 2013年 gin_liquor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAHttpClient : NSObject {
    bool skipRequestFlag;
    int requestCount;
    int requestThreshold;
}
@property long submittedBytes, receivedBytes;
@property dispatch_semaphore_t semaphore;
- (void)skipRequest;
- (int)getRequestCount;
- (void)setRequestThreshold:(int)threshold;
- (NSData*)callToServer:(NSData *)data method:(NSString *)method url:(NSString *)url;
- (NSMutableDictionary*)callJson:(NSMutableDictionary *)query method:(NSString *)method url:(NSString *)url;
- (long*)receivedBytesPtr;
- (long*)submittedBytesPtr;
+ (NSDictionary*)jsonDecode:(NSData*)data;

@end
