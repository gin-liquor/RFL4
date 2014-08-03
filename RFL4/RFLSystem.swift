//
//  RFLSystem.swift
//  RFL4
//
//  Created by Takuya on 2014/07/10.
//  Copyright (c) 2014年 gin_liquor. All rights reserved.
//

import Foundation
import UIKit

struct RFLInfo {
    static var instance = RFLInfo()
    var address: String = "http://192.168.1.3:8002/"
    var thumbs = NSMutableDictionary()
    var infos = NSMutableDictionary()
    
    func setInfoFlag(id: String, LWT: String, flag: Bool) {
        if id == nil {
            return
        }
        var entry = self.infos[id] as? NSArray
        //self.infos.setObject([entry![0], flag], forkey: id)
        self.infos[id] = [LWT, flag]
    }
    
    func checkInfo(id: String, date: String) -> Bool {
        if id == nil {
            return false
        }
        var entry = self.infos[id] as? NSArray
        if entry {
            if entry![0] as NSString != date {
                //self.infos[id] = [date, false]
                self.thumbs.removeObjectForKey(id)
                return true
            } else {
                self.infos[id] = [date, true]
                return false
            }
        } else {
            self.infos[id] = [date, true];
            return false
        }
    }
    
}

class RFLSystem {
    
    //var info: RFLSystemInfo = RFLSystemInfo.instance
    
    var semaphore: dispatch_semaphore_t = 0
    var waitcount: Int = 0
    var requestQueue: Array<String> = Array()
    
    var info: RFLInfo {
        return RFLInfo.instance
    }

    func test1(closure: (String) -> ()) {
        var url = NSURL(string: self.info.address + "rfl_get.txt?id=0000&method=get")
        
        var str = String();
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if response {
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var s:String = String(NSString(data:data, encoding:NSUTF8StringEncoding));
            var fs = String(format:"%@\n%@", response, s)
            println(fs);
            //str += s;
            dispatch_async(dispatch_get_main_queue()) {
                closure(fs)
            }
            }
        }

        task.resume()
    }

    func get_list(id: String, closure: (NSDictionary) -> ()) {
        //println("get_list(\(id))")
        
        var encid = id.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedString().stringByReplacingOccurrencesOfString("\r\n", withString: "", options: nil, range: nil);
        
        var url = NSURL(string: self.info.address + "rfl_get.txt?method=get_list&id=" + encid!)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if response {
                var s: String = String(NSString(data: data, encoding: NSUTF8StringEncoding))
                var dic = MAHttpClient.jsonDecode(data)
                var children = dic["children"] as NSArray;
                
                //リストに格納
                for d in children {
                    var cid = d["id"] as String
                    //println("cid=\(cid)")
                    //古いエントリーとの比較
                    self.info.checkInfo(cid, date: d["LWT"] as String)
                }
                
                //クロージャー
                dispatch_async(dispatch_get_main_queue()) {
                    closure(dic);
                }
            }
        }
        
        task.resume()
    }

    func get_thumbnail(id: String, size: Int, closure: (UIImage) -> ()) {
        //リストのアップデート項目参照
        var entry = self.info.infos[id] as? NSArray
        if entry {
            var image: AnyObject! = self.info.thumbs[id];
            if image {
                closure(self.info.thumbs[id]! as UIImage)
                println("load from cache(\(id))")
                return
            }
            println("load from server(update)(\(id))")
        }
        /*
        if entry {
            self.info.setInfoFlag(id, LWT: entry![0] as String, flag: false)
            println("load from server(\(id))")
        }
        */
        //セマフォ初期化
        if self.semaphore == 0 {
            self.semaphore = dispatch_semaphore_create(1)
        }
        
        //セマフォ
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
        
        //キューの数が一定以上ならば新しいリクエストを捨てて処理を戻す
        if self.requestQueue.count >= 25 {
            println("remove(\(id))")
            dispatch_semaphore_signal(self.semaphore)
            return
        }
        
        //リクエストキューに記録
        self.requestQueue.append(id)
        //println("add(\(id))")
        
        //リクエストのBASS64エンコード
        var encid = id.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedString().stringByReplacingOccurrencesOfString("\r\n", withString: "", options: nil, range: nil);
        
        //リクエストURLを生成
        var url = NSURL(string: self.info.address + "rfl_get.txt?method=get_thumbnail&thumbsize=" + String(size) + "&id=" + encid!)
        
        //タスクの設定
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if response {
                var image = UIImage(data: data, scale:2.0)
                self.info.thumbs[id] = image
                dispatch_async(dispatch_get_main_queue()) {
                    //println("complete(\(id))")
                    self.requestQueue.removeAtIndex(find(self.requestQueue, id)!)
                    closure(image)
                }
            }
        }
        
        task.resume()
        
        //リソースの解放
        dispatch_semaphore_signal(self.semaphore)
    }
    
    func get_thumbnail2(id: String, size: Int, closure: (UIImage) -> ()) {
        //セマフォ初期化
        if self.semaphore == 0 {
            self.semaphore = dispatch_semaphore_create(1)
        }
        
        //セマフォ
        var waitrc = dispatch_semaphore_wait(self.semaphore, 0)
        
        //キューの数が一定以上ならば新しいリクエストを捨てて処理を戻す
        if waitrc != 0 {
            println("*remove(\(id))")
            dispatch_semaphore_signal(self.semaphore)
            return
        }
        
        //リクエストキューに記録
        println("add(\(id))")
        
        //リクエストのBASS64エンコード
        var encid = id.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedString().stringByReplacingOccurrencesOfString("\r\n", withString: "", options: nil, range: nil);
        
        //リクエストURLを生成
        var url = NSURL(string: self.info.address + "rfl_get.txt?method=get_thumbnail&thumbsize=" + String(size) + "&id=" + encid!)
        
        //タスクの設定
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if response {
                var image = UIImage(data: data, scale:2.0);
                dispatch_async(dispatch_get_main_queue()) {
                    println("complete(\(id))")
                    closure(image)
                }
            }
        }
        
        task.resume()
        
        //リソースの解放
        dispatch_semaphore_signal(self.semaphore)
    }
    
    func get_file(id: String, size: Int, closure: (NSData) -> ()) {
        var encid = id.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedString().stringByReplacingOccurrencesOfString("\r\n", withString: "", options: nil, range: nil);
        
        var url = NSURL(string: self.info.address + "rfl_get.txt?method=get_thumbnail&thumbsize=72&id=" + encid!)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            if response {
                dispatch_async(dispatch_get_main_queue()) {
                    closure(data);
                }
            }
        }
        
        task.resume()
    }
}

