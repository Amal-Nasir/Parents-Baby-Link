//
//  CPMsgTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/29/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit

class CPMsgTableViewController: UITableViewController {
    var Array: NSMutableArray = NSMutableArray()
    var ConnectObject = PFObject?()
    var timer: NSTimer = NSTimer()
    var selectedParentMSG:String?
    var selectedParentId:PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
      loadSendersUsers()
       /* let notRead = PFQuery(className: "SendersID")
        notRead.whereKey("sender", equalTo: PFUser.currentUser()!)
        notRead.whereKey("Read", equalTo: true)
        notRead.orderByDescending("createdAt")
        notRead.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            let User = objects! as [PFObject]
            for objects in User {
                
                objects["Me"] = "notRead"
                objects.saveInBackground()
                
                let read = PFQuery(className: "SendersID")
                read.whereKey("sender", equalTo: PFUser.currentUser()!)
                read.whereKey("Read", equalTo: false)
                read.orderByDescending("createdAt")
                read.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                    let User = objects! as [PFObject]
                    for objects in User {
                        
                        objects["Me"] = "Read"
                        objects.saveInBackground()
                    }
                }
            }
        }*/

        //timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "loadSendersUsers", userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(animated: Bool) {
                
    }

    
    
    func loadSendersUsers() {
        
        self.Array.removeAllObjects()
        
        // retrive the users that sent msg to PFUser.currentUser
        let getUserMSGQuery = PFQuery(className: "SendersID")
        getUserMSGQuery.whereKey("sender", equalTo: PFUser.currentUser()!)
        //getUserMSGQuery.whereKey("createdAt", greaterThan: (Array.date)!)
        getUserMSGQuery.orderByDescending("createdAt")
        getUserMSGQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil  {
                // The find succeeded.
                print("succesfully loaded the user that sent MSG in Activity class")
                
                // Do something with the found objects
                for object  in objects!   {
                    
                    self.Array.addObject(object)
                    
                }
                
                self.tableView.reloadData()
                
            }else {
                // Log details of the failure
                print("error loading activities ")
                print(error)}
           }
        
       }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Array.count
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Msg3Cell") as! CPMsgTableViewCell
        
        cell.ParentName.text = nil
        cell.ParentImage.image = nil
        cell.ParentImage.layer.cornerRadius = cell.ParentImage.frame.size.width / 2
        cell.ParentImage.clipsToBounds = true
        cell.activityandBabyname.text = nil
        cell.timeLabel.text = nil
        
        ConnectObject = Array.objectAtIndex(indexPath.row) as? PFObject
        
        cell.ParentImage.image = UIImage(named: "default-user-icon-profile")
        
        if let ConnectObject = ConnectObject{

            // retrive the activity info from Activity class
            // This way works!!
            
            let queryActivity = PFQuery(className: "Activity")
            queryActivity.whereKey("parent_Id", equalTo: ConnectObject["parent_Id"] as! PFUser)
            queryActivity.whereKey("sender", equalTo: ConnectObject["sender"] as! PFUser)
            queryActivity.orderByAscending("createdAt")
            queryActivity.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) -> Void in
                if error == nil && objects != nil{
                    for object in objects!{
                        //print (object)
                        
                        let activity = object["activity_type"] as! String
                        let baby = object["baby_name"] as! String
                        cell.activityandBabyname.text = activity + " for " + baby
                        
                        let dataFormatter:NSDateFormatter = NSDateFormatter()
                        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        cell.timeLabel.text = dataFormatter.stringFromDate(object.createdAt!)
                        
                    }
                }
            })
            
            // retrive the sender info from User class
            let parent : PFUser = ConnectObject["parent_Id"] as! PFUser
            let queryUsers = PFUser.query()
            queryUsers?.getObjectInBackgroundWithId(parent.objectId!, block: { (Object:PFObject?, error:NSError?) -> Void in
                
                if error == nil && Object != nil {
                    let senderUser:PFUser = Object as! PFUser
                    
                    cell.ParentName.text = senderUser["first_name"]as? String
                    
                    if let pfimage = senderUser["profile_picture"] as? PFFile{
                        pfimage.getDataInBackgroundWithBlock({(result, error) in
                            if (result != nil)
                            {cell.ParentImage.image = UIImage(data: result!)}
                            else
                            {cell.ParentImage.image = UIImage()}
                        })
                    }else
                    {cell.ParentImage.image = UIImage(named: "default-user-icon-profile")}
                    
                }
                
            })
            
           
               /* cell.HiddenLabel.text! = ConnectObject["Me"] as! String
                cell.HiddenLabel.hidden = true
                if cell.HiddenLabel.text! == "notRead"{
                   cell.backgroundColor = UIColor.lightGrayColor()
                }else {
                    cell.backgroundColor = UIColor.clearColor()
                }*/
        }
        
        return  cell
        
    }
    
    /// Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        
        let returnValue:Bool = true
        
        return returnValue
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            let parentUser = Array.objectAtIndex(indexPath.row) as! PFObject
            //print(parentUser)
            let query1 = PFQuery(className: "Activity")
            let query2 = PFQuery(className: "SendersID")
            //let CPUser:PFQuery = PFUser.query()!
            
            //CPUser.whereKey("objectId", equalTo: parentUser!.objectId!)
            //CPUser.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                //if let users = objects {
                    //for object in users {
                        //if let user = object as? PFUser {
            /*let babyMsgQuery = PFQuery(className: "Activity")
            babyMsgQuery.whereKey("sender", equalTo:PFUser.currentUser()!)
            babyMsgQuery.whereKey("objectId", equalTo: msg.objectId!)
            
            babyMsgQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            // print((self.messages[indexPath.row].objectId))
            
            if let objects = objects {
            for object in objects {
            self.messages.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            object.deleteInBackground()}}})*/
            query2.whereKey("sender", equalTo: PFUser.currentUser()!)
            query2.whereKey("parent_Id", equalTo: parentUser["parent_Id"] as! PFUser)
            query2.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                //self.Array.removeObjectAtIndex(indexPath.row)
                //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
                
                query1.whereKey("sender", equalTo: PFUser.currentUser()!)
                query1.whereKey("parent_Id", equalTo: parentUser["parent_Id"] as! PFUser)
                query1.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    self.Array.removeObjectAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                    
                    
                })
            })
            
                        //}}}
            //})
            
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = UITableViewCell()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        ConnectObject = Array.objectAtIndex(indexPath.row) as? PFObject
        
        if let ConnectObject = ConnectObject{
            
            let parentID : PFUser = ConnectObject["parent_Id"] as! PFUser
            
            let queryUsers = PFUser.query()
            queryUsers?.getObjectInBackgroundWithId(parentID.objectId!, block: { (Object:PFObject?, error:NSError?) -> Void in
                
                if error == nil && Object != nil {
                    let parentUser:PFUser = Object as! PFUser
                    
                    let parentName = parentUser["first_name"]as? String
                    
                    self.selectedParentMSG = parentName
                    self.selectedParentId = parentID
                    self.performSegueWithIdentifier("viewDetails1", sender: indexPath.row)
                    
                }
            })
            
            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "viewDetails1") {
            let vc = segue.destinationViewController as! CPDetailMsgTableViewController
            vc.PName = selectedParentMSG
            vc.PID = selectedParentId
            //print(vc.PID)
        }
    }
    
}
