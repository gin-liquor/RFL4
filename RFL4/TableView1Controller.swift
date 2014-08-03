//
//  TableView1Controller.swift
//  RFL4
//
//  Created by Takuya on 2014/07/15.
//  Copyright (c) 2014年 gin_liquor. All rights reserved.
//

import UIKit

class TableView1Controller : UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    typealias Entry = NSDictionary
    typealias EntryList = NSArray
    
    var rfl = RFLSystem()
    var data: Entry = Entry()
    var list: EntryList = EntryList()
    
    var folderId: String = "root"
    var selectedId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        rfl.get_list(self.folderId) {
            let dic = $0 as Entry
            self.list = dic["children"] as EntryList
            self.data = dic
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if self.data.count == 0 {
            return 0
        }
        return self.list.count
    }
    
    func updateCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        var d = self.list[indexPath.row] as Entry
        var title = String(d["name"] as NSString) + " " + String(d["size"] as NSString)
        cell.textLabel.text = title
        cell.imageView.image = nil
        switch d["ext"].lowercaseString as NSString {
        case ".jpg", ".png":
                rfl.get_thumbnail(d["id"] as NSString, size: 72) {
                    cell.imageView.image = $0
                    cell.setNeedsLayout()
            }
        default:
            cell.imageView.image = nil
        }
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cellId = "itemViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as UITableViewCell
        if cell == nil {
            cell = UITableViewCell()
        }
        
        self.updateCell(cell, indexPath:indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, willSelectRowAtIndexPath indexPath: NSIndexPath!) -> NSIndexPath! {
        var d = self.list[indexPath.row] as Entry
        if d["type"] as NSString == "folder" {
            self.selectedId = d["id"] as? String
            return indexPath;
        } else if d["type"] as NSString == "file" {
            return nil;
        }
        return nil;
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //self.selected = self.list[indexPath.row] as? Entry
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        var id = segue.identifier;
        if id == "toFolder" {
            var vc = segue.destinationViewController as TableView1Controller
            vc.folderId = self.selectedId!
            return
        }
    }
    
    @IBAction func actViewInfoList(sender: AnyObject) {
        println(self.rfl.info.infos.description);
    }
}