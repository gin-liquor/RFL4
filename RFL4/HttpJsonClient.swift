//
//  HttpJsonClient.swift
//  RFL4
//
//  Created by Takuya on 2014/07/02.
//  Copyright (c) 2014年 gin_liquor. All rights reserved.
//

import Foundation

class HttpJsonClient : NSObject {
    /*
    //var receivedBytesPtr
    var requestCount: Int = 0
    var requestThreshold: Int = 20
    let semaphore: dispatch_semaphore_t
    
    func callToServer(data:NSData, method:NSString, url:NSString) -> NSData! {
        //if (uiApp == nil)
        //    uiApp = [UIApplication sharedApplication];
        
        requestCount++
        //uiApp.networkActivityIndicatorVisible = YES;
        
        //dispatch_semaphore_t smph = dispatch_semaphore_create(1);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        //待ちが多くなると処理キャンセル
        if (requestCount > requestThreshold) {
            requestCount--;
            dispatch_semaphore_signal(semaphore);
            return nil;
        }
        
        var tempstr = url.
        let myURL = NSURL(string:))
        
        let request = CFHTTPMessageCreateRequest(alloacator:kCFAllocatorDefault, requestMethod:"POST", url:myURL, httpVersion:kCFHTTPVersion1_1)
        CFHTTPMessageSetBody(message:request, bodyData:data)
        let requestStream = CFReadStreamCreateForHTTPRequest(alloc:kCFAllocatorDefault, request:request)
        if CFReadStreamOpen(stream:requestStream) == false || requestStream == CFStreamStatus.NotOpen {
            dispatch_semaphore_signal(semaphore)
            return nil
        }
        
        var responseBytes: NSMutableData
        var recvBytes:Int = 0
        //CFIndex numBytesRead = 0 ;
        var numBytesRead:Int = 0
        do
        {
            //UInt8 buf[1024];
            UInt8 buf[1024];
            //numBytesRead = CFReadStreamRead(requestStream, buf, sizeof(buf));
            numBytesRead = CFReadStreamRead(stream:requestStream, buffer:buf, bufferLength:sizeof(buf))
            
            //if(numBytesRead > 0)
            //[responseBytes appendBytes:buf length:numBytesRead];
            if numBytesRead > 0 {
                responseBytes.appendBytes(bytes:buf, length:numBytesRead)
            }
            recvBytes += numBytesRead;
            //*[self receivedBytesPtr] = recvBytes;
        } while numBytesRead > 0
        
        CFReadStreamClose(requestStream);
        
        //if (--requestCount == 0)
        //    uiApp.networkActivityIndicatorVisible = NO;
        dispatch_semaphore_signal(semaphore);
        
        return responseBytes;
    }
    
    //static UIApplication *uiApp = nil;
    let version:NSString?
    let instanced:NSString?
*/*/

    func test1() -> NSString {
        let req = MAHttpClient()
        let data = req.callToServer(nil, method:"rfl_test.txt", url:"http://192.168.1.3:8002/")
        return NSString(data: data, encoding: NSUTF8StringEncoding)
    }
}
