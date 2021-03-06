//
//  ViewController.swift
//  taskapp
//
//  Created by 松波優也 on 2016/04/04.
//  Copyright © 2016年 yuya.matsunami. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    
    var category = try! Realm().objects(Task).filter("category IN {%@, %@, %@, %@, %@}","1", "2", "3", "4", "5")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var search: UISearchBar!
    
    var searchFlag: Bool = false
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        search.resignFirstResponder()
    }
    
    // 検索する時の処理
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchFlag = true
        if let search = searchBar.text{
            category = try! Realm().objects(Task).filter("category = '\(search)'")
        } else {
            category = try! Realm().objects(Task).filter("category IN {%@, %@, %@, %@, %@}","1", "2", "3", "4", "5")
        }
        
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.utf16.count == 0 {
            searchFlag = false
            tableView.reloadData()
        }
    }
    
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchFlag == true {
            
            return category.count
            
        } else {

           return taskArray.count
        }
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if searchFlag == true {
            
            let task = category[indexPath.row]
            cell.textLabel?.text = "\(task.title) 　　　　　　　　　　\(task.category)"
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.stringFromDate(task.date)
            cell.detailTextLabel?.text = dateString

            
        } else {
            
            let task = taskArray[indexPath.row]
            cell.textLabel?.text = "\(task.title) 　　　　　　　　　　\(task.category)"
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.stringFromDate(task.date)
            cell.detailTextLabel?.text = dateString

        }
            
        return cell

    }
    
    
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        
}
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // segue で画面遷移するに呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }

}

