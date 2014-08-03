//
//  MAHttpClient.m
//  RFL
//
//  Created by Takuya on 2013/02/15.
//  Copyright (c) 2013年 gin_liquor. All rights reserved.
//

#import "MAHttpClient.h"

@implementation MAHttpClient
@synthesize receivedBytes, submittedBytes, semaphore;

NSNumber *httpclient_receivedBytes, *httpclient_submittedBytes;

- (long*)receivedBytesPtr
{
    return &receivedBytes;
}

- (long*)submittedBytesPtr
{
    return &submittedBytes;
}

- (NSData*)callToServer:(NSData *)data method:(NSString *)method url:(NSString *)url
{
    //if (uiApp == nil)
    //    uiApp = [UIApplication sharedApplication];
    
    requestCount++;
    //uiApp.networkActivityIndicatorVisible = YES;
    
    //dispatch_semaphore_t smph = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //待ちが多くなると処理キャンセル
    if (requestCount > requestThreshold) {
        requestCount--;
        dispatch_semaphore_signal(semaphore);
        return nil;
    }
    
    
    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, method]];
    
    CFHTTPMessageRef request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("POST"), (__bridge CFURLRef)myURL, kCFHTTPVersion1_1);
    CFHTTPMessageSetBody(request, (__bridge CFDataRef)data);
    
    CFReadStreamRef requestStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
    
    if (CFReadStreamOpen(requestStream) == FALSE || (long)requestStream == kCFStreamStatusNotOpen) {
        //Open失敗
        dispatch_semaphore_signal(semaphore);
        return nil;
    }
    
    NSMutableData *responseBytes = nil;
    responseBytes = [NSMutableData new];
    long recvBytes = 0;
    CFIndex numBytesRead = 0 ;
    do
    {
        UInt8 buf[1024];
        numBytesRead = CFReadStreamRead(requestStream, buf, sizeof(buf));
        
        if(numBytesRead > 0)
            [responseBytes appendBytes:buf length:numBytesRead];
        
        recvBytes += numBytesRead;
        *[self receivedBytesPtr] = recvBytes;
    } while(numBytesRead > 0);

    CFReadStreamClose(requestStream);
    
    //if (--requestCount == 0)
    //    uiApp.networkActivityIndicatorVisible = NO;
    dispatch_semaphore_signal(semaphore);
    
    return responseBytes;
}

//static UIApplication *uiApp = nil;
static NSString *version = nil;
static NSString *instanceid = nil;

- (NSDictionary*)callJson:(NSMutableDictionary *)query method:(NSString *)method url:(NSString *)url
{
    NSDictionary *r;
    @try {
        //バージョン情報
        if (version == nil) {
            version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        }
        query[@"version"] = version;
        //インスタンスID
        if (instanceid == nil) {
            CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
            instanceid = (__bridge id)(CFUUIDCreateString(kCFAllocatorDefault, uuid));
            CFRelease(uuid);
        }
        query[@"instanceid"] = instanceid;
        //通信
        r = [NSJSONSerialization JSONObjectWithData:[self callToServer:[NSJSONSerialization dataWithJSONObject:query options:nil error:nil] method:method url:url] options:nil error:nil];
    }
    @catch (NSException *ex) {
        r = nil;
    }
    return r;
}

- (void)skipRequest
{
    if (requestCount != 0) {
        skipRequestFlag = true;
    }
}

- (int)getRequestCount
{
    return requestCount;
}

- (void)setRequestThreshold:(int)threshold
{
    requestThreshold = threshold;
}

- (id)init
{
    skipRequestFlag = false;
    requestThreshold = 30;
    semaphore = dispatch_semaphore_create(10);
    return self;
}

+ (NSDictionary*)jsonDecode:(NSData*)data
{
    NSDictionary *r = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
    return r;
}

@end

