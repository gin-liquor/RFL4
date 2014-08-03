//
//  ViewController.swift
//  RFL4
//
//  Created by Takuya on 2014/07/07.
//  Copyright (c) 2014年 gin_liquor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    @IBOutlet var textView1: UITextView!
    
    //var req = HttpJsonClient()
    var rfl = RFLSystem()
    
    @IBAction func actClear(sender: AnyObject) {
        textView1.text = "";
    }
    
    @IBAction func actTest1(sender: AnyObject) {
        textView1.text = textView1.text + "Hello, world!\n"
    }
    
    @IBAction func actTest2(sender: AnyObject) {
    }
    
    @IBAction func actTest3(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

