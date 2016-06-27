//
//  CareProviderTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/22/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class CareProviderTableViewController: UITableViewController {

    
    var Array: NSMutableArray = NSMutableArray()
    var ConnectObject = PFObject?()
    
    var refresher: UIRefreshControl!
    
    var selectedParent:String?
    var selectedParentId:PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: "loadFollowerUsers", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        loadFollowerUsers()
        let notRead = PFQuery(className: "Message2")
        notRead.whereKey("to", equalTo: PFUser.currentUser()!)
        //notRead.whereKey("from", equalTo: ParentID!)
        notRead.whereKey("Read", equalTo: false)
        notRead.addDescendingOrder("createdAt")
        notRead.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            let User = objects! as [PFObject]
            for objects in User {
                objects["Read"] = true
                objects["Me"] = "Read"
                objects.saveInBackground()
                let read = PFQuery(className: "Message2")
                //read.whereKey("from", equalTo: self.ParentID!)
                read.whereKey("to", equalTo: PFUser.currentUser()!)
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
    
    func loadFollowerUsers() {
        
        self.Array.removeAllObjects()
        
        let getFollowedUsersQuery = PFQuery(className: "follow")
        getFollowedUsersQuery.whereKey("toUser", equalTo: PFUser.currentUser()!)
        getFollowedUsersQuery.whereKey("status", equalTo: "followed")
        getFollowedUsersQuery.addDescendingOrder("createdAt")
        getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil  {
                // The find succeeded.
                print("succesfully loaded the fromUser  in Activity class")
                
                // Do something with the found objects
                for object  in objects!   {
                    
                    self.Array.addObject(object)
                    
                }
                
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }else {
                // Log details of the failure
                print("error loading care providers ")
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
        
        //return searchUsers.count
        return Array.count
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CareCell") as! CareProviderTableViewCell
        
        cell.userNameLabel.text = nil
        cell.userImage.image = nil
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage.clipsToBounds = true
        cell.chatMSG.hidden = true
        cell.backgroundColor = UIColor.clearColor()
       
        ConnectObject = Array.objectAtIndex(indexPath.row) as? PFObject
        
        cell.userImage.image = UIImage(named: "default-user-icon-profile")
        
        if let ConnectObject = ConnectObject{
            
            let fromUserID : PFUser = ConnectObject["fromUser"] as! PFUser
            
            let queryUsers = PFUser.query()
            queryUsers?.getObjectInBackgroundWithId(fromUserID.objectId!, block: { (Object:PFObject?, error:NSError?) -> Void in
                
                if error == nil && Object != nil {
                    let FromUser:PFUser = Object as! PFUser
                    
                    cell.userNameLabel.text = FromUser["first_name"]as? String
                    
                    //if (ToUser.objectForKey("profile_picture") != nil){
                    if let pfimage = FromUser["profile_picture"] as? PFFile{
                        pfimage.getDataInBackgroundWithBlock({(result, error) in
                            if (result != nil)
                            {cell.userImage.image = UIImage(data: result!)}
                            else
                            {cell.userImage.image = UIImage()}
                        })
                    }else
                    {cell.userImage.image = UIImage(named: "default-user-icon-profile")}
                    
                }
                
            })
            
      
        
        //Check if the message read or not and then present the MSG emoji
        let query = PFQuery(className: "Messages2")
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        query.whereKey("from", equalTo: ConnectObject["fromUser"] as! PFUser)
        query.orderByAscending("createdAt")
        query.limit = 100
        query.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                cell.chatMSG.hidden = true
                for object in objects!{
                    print("For loop ")
                    print(object["Me"] as! String)
                    if object["Me"] as! String == "notRead"{
                        //print(object["Me"] as! String)
                        cell.chatMSG.hidden = false
                        cell.backgroundColor = UIColor.lightGrayColor()
                    }else {
                        cell.chatMSG.hidden = true
                        cell.backgroundColor = UIColor.clearColor()
                    }
                }
            }}
        }
        
        return  cell
        
    }
    
    /// Override to support conditional editing of the table view.
   /* override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        
        let returnValue:Bool = true
        
        return returnValue
    }*/
    
    
    
    // Override to support editing the table view.
   /* override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            //let followedParent = Array[indexPath.row]
            let query = PFQuery(className: "follow")
            let follow:PFQuery = PFUser.query()!
            //follow.whereKey("objectId", equalTo: followedParent)
            follow.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            
                            query.whereKey("fromUser", equalTo: user )
                            query.whereKey("toUser", equalTo: PFUser.currentUser()!)
                            query.whereKey("status", equalTo:"followed")
                            
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                
                                self.Array.removeObjectAtIndex(indexPath.row)
                                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                
                                if let objects = objects {
                                    
                                    for object in objects {
                                        
                                        object.deleteInBackground()
                                        
                                    }
                                }
                            })
                        }}}
            })
            
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }*/
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        ConnectObject = Array.objectAtIndex(indexPath.row) as? PFObject
        
        
        if let ConnectObject = ConnectObject{
            
            let FromUserID : PFUser = ConnectObject["fromUser"] as! PFUser
            
            let queryUsers = PFUser.query()
            queryUsers?.getObjectInBackgroundWithId(FromUserID.objectId!, block: { (Object:PFObject?, error:NSError?) -> Void in
                
                if error == nil && Object != nil {
                    let FromUser:PFUser = Object as! PFUser
                    
                    let parentName = FromUser["first_name"]as? String
                    let parentID = FromUserID
                    
                    self.selectedParent = parentName
                    self.selectedParentId = parentID
                    self.performSegueWithIdentifier("chat2", sender: indexPath.row)
                    
                }
            })
            
            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "chat2") {
            let vc = segue.destinationViewController as! ParentChatMSGViewController
            vc.PName = selectedParent
            vc.ParentID = selectedParentId
            
            print(vc.PName)
        }
    }
    
}
