//
//  ParentDetailMsgTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/19/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class ParentDetailMsgTableViewController: UITableViewController {

    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    // from previous tableviewController
    var CPName:String?
    var CPID:PFUser?
    
   // var timer: NSTimer = NSTimer()
    
    var isLoading: Bool = false
    var users = [PFUser]()
    var messages = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.title = self.CPName
        loadMessages()
        //Here is the change for color happens
        let notRead = PFQuery(className: "SendersID2")
        notRead.whereKey("parent_Id", equalTo: PFUser.currentUser()!)
        notRead.whereKey("sender", equalTo: CPID!)
        notRead.whereKey("Read", equalTo: false)
        notRead.addDescendingOrder("createdAt")
        notRead.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            let User = objects! as [PFObject]
            for objects in User {
                objects["Read"] = true
                objects["Me"] = "Read"
                objects.saveInBackground()
                let read = PFQuery(className: "SendersID2")
                read.whereKey("sender", equalTo: self.CPID!)
                read.whereKey("parent_Id", equalTo: PFUser.currentUser()!)
                read.whereKey("Read", equalTo: true)
                read.orderByDescending("createdAt")
                read.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                    let User = objects! as [PFObject]
                    for objects in User {
                        
                        objects["Me"] = "Read"
                        objects.saveInBackground()
                    }
                }
            }
        }

       
    }
    
    func loadMessages(){
        
        if self.isLoading == false{
            self.isLoading = true
            
            let query = PFQuery(className: "Activity2")
            query.whereKey("sender", equalTo: self.CPID!)
            query.whereKey("parent_Id", equalTo: PFUser.currentUser()!)
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
                
                self.messages.removeAll(keepCapacity: false)
                
                if error == nil{
                if let searchResults = result
                {
                    self.messages = searchResults
                    
                    self.tableView.reloadData()
                }
                }else {
                    
                    self.displayAlert("Network Error", message: "Please come back later.. ")
                }
                
            }
                self.isLoading = false;
                
            }
    
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.messages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Msg2Cell", forIndexPath: indexPath) as! ParentDetailMsgTableViewCell

        // Configure the cell...
        
        let Msg = messages[indexPath.row]
        
        let activity = Msg.objectForKey("activity_type") as? String
        
        let Bname = Msg.objectForKey("baby_name") as? String
        
        cell.activityandBabyName1.text = activity! + " for " + Bname!
        
        cell.type.text = Msg.objectForKey("type") as? String
        
        cell.comments.text = Msg.objectForKey("comments") as? String
        
        let dataFormatter:NSDateFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.timeLabel1.text = dataFormatter.stringFromDate(Msg.createdAt!)

        return cell
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let returnValue:Bool = true
        
        return returnValue
    }
    


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        

        if editingStyle == .Delete {
            // Delete the row from the data source
            
            let msg = messages[indexPath.row]
            
            let acl = PFACL(user: PFUser.currentUser()!)
            acl.publicWriteAccess = true
            acl.publicReadAccess = true
            
            let babyMsgQuery = PFQuery(className: "Activity2")
            babyMsgQuery.whereKey("parent_Id", equalTo:PFUser.currentUser()!)
            babyMsgQuery.whereKey("objectId", equalTo: msg.objectId!)
            
            babyMsgQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects {
                    for object in objects {
                        self.messages.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        object.deleteInBackground()}}})
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

}
