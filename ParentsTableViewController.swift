//
//  ParentsTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 1/28/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class ParentsTableViewController: UITableViewController {
    
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
        
        
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        loadFollowerUsers()
        let notRead1 = PFQuery(className: "Message")
        notRead1.whereKey("to", equalTo: PFUser.currentUser()!)
        //notRead1.whereKey("from", equalTo: ParentID!)
        notRead1.whereKey("Me", equalTo: "notRead")
        notRead1.orderByAscending("createdAt")
        notRead1.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            let User = objects! as [PFObject]
            for objects in User {
                //if objects["Me"] as! String == "notRead"{
                print(objects["Me"] as! String)
                print(objects["text"] as! String)
                objects["Read"] = true
                objects["Me"] = "Read"
                objects.saveInBackground()//}
                
                let read = PFQuery(className: "Message")
                read.whereKey("to", equalTo: PFUser.currentUser()!)
                //read.whereKey("from", equalTo: self.ParentID!)
                read.whereKey("Me", equalTo: "Read")
                read.orderByAscending("createdAt")
                read.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                    let User = objects! as [PFObject]
                    for objects in User {
                        //if objects["Me"] as! String == "Read"{
                        objects["Me"] = "Read"
                        objects.saveInBackground()//}
                    }
                }
                
            }
        }
    }
  
    func loadFollowerUsers() {
    
        self.Array.removeAllObjects()
        
            let getFollowedUsersQuery = PFQuery(className: "follow")
            getFollowedUsersQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
            getFollowedUsersQuery.whereKey("status", equalTo: "followed")
            getFollowedUsersQuery.addDescendingOrder("createdAt")
            getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil  {
                    // The find succeeded.
                    print("succesfully load parents in Activity class")
                        
                    // Do something with the found objects
                        for object  in objects!   {
                            
                          self.Array.addObject(object)
                            
                          }
                        
                          self.tableView.reloadData()
                          self.refresher.endRefreshing()

                   }else {
                        // Log details of the failure
                        print("error loading parents ")
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
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ParentsCell") as! ParentsTableViewCell
        
        cell.userNameLabel.text = nil
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage.clipsToBounds = true
        cell.userImage.image = nil
        cell.chatMSG.hidden = true
        cell.backgroundColor = UIColor.clearColor()

        //let individualUser = searchUsers[indexPath.row]
        
        ConnectObject = Array.objectAtIndex(indexPath.row) as? PFObject
        cell.userImage.image = UIImage(named: "default-user-icon-profile")
        
        if let ConnectObject = ConnectObject{
        
        let ToUserID : PFUser = ConnectObject["toUser"] as! PFUser
        
        let queryUsers = PFUser.query()
        queryUsers?.getObjectInBackgroundWithId(ToUserID.objectId!, block: { (Object:PFObject?, error:NSError?) -> Void in
            
          if error == nil && Object != nil {
            let ToUser:PFUser = Object as! PFUser
            
            cell.userNameLabel.text = ToUser["first_name"]as? String
            
            if let pfimage = ToUser["profile_picture"] as? PFFile{
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
        let query = PFQuery(className: "Messages")
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        query.whereKey("from", equalTo: ConnectObject["toUser"] as! PFUser)
        query.orderByAscending("createdAt")
        query.limit = 100
        query.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                cell.chatMSG.hidden = true
                for object in objects!{
                    //print("I am in for loop")
                    //print(object["Me"] as! String)
                    if object["Me"] as! String == "notRead"{
                       
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
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        
        let returnValue:Bool = true
        
        return returnValue
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            let followedParent = Array.objectAtIndex(indexPath.row) as? PFObject
            print("Found object: \(followedParent) ")
            let query = PFQuery(className: "follow")
            let follow:PFQuery = PFUser.query()!
            //follow.whereKey("objectId", equalTo: followedParent!.objectId!)
            follow.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
               // if let users = objects {
                    //for object in users {
                        //if let user = object as? PFUser {
                            //print(user)
                            query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
                            query.whereKey("toUser", equalTo: followedParent!["toUser"])
                            //query.whereKey("objectId", equalTo: followedParent!.objectId! )
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
                        //}
                   // }}
            })
            // Delete a parent's babies
            let DeleteBaby = PFQuery(className: "Baby")
            DeleteBaby.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                DeleteBaby.whereKey("user2", equalTo: PFUser.currentUser()!)
                DeleteBaby.whereKey("user1", equalTo: followedParent!["toUser"])
                DeleteBaby.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            })
            // Delete chat messages between them
            let DeleteChat = PFQuery(className: "Messages")
            DeleteChat.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                DeleteChat.whereKey("from", equalTo: PFUser.currentUser()!)
                DeleteChat.whereKey("to", equalTo: followedParent!["toUser"])
                DeleteChat.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            })
            let DeleteChat1 = PFQuery(className: "Messages")
            DeleteChat1.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                DeleteChat1.whereKey("from", equalTo:followedParent!["toUser"] )
                DeleteChat1.whereKey("to", equalTo: PFUser.currentUser()!)
                DeleteChat1.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            })
            
            let DeleteChat3 = PFQuery(className: "Messages2")
            DeleteChat3.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                DeleteChat3.whereKey("from", equalTo: PFUser.currentUser()!)
                DeleteChat3.whereKey("to", equalTo: followedParent!["toUser"])
                DeleteChat3.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            })
            let DeleteChat2 = PFQuery(className: "Messages2")
            DeleteChat2.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                DeleteChat2.whereKey("from", equalTo:followedParent!["toUser"] )
                DeleteChat2.whereKey("to", equalTo: PFUser.currentUser()!)
                DeleteChat2.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            })

            // Delete Activity MSG
            let DeleteActivity = PFQuery(className: "Activity")
            DeleteActivity.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                DeleteActivity.whereKey("sender", equalTo:PFUser.currentUser()!)
                DeleteActivity.whereKey("parent_Id", equalTo:followedParent!["toUser"])
                DeleteActivity.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            })
            let DeleteSender = PFQuery(className: "SendersID")
            DeleteSender.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                DeleteSender.whereKey("sender", equalTo:PFUser.currentUser()!)
                DeleteSender.whereKey("parent_Id", equalTo:followedParent!["toUser"])
                DeleteSender.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            })
            
    }
}
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
         ConnectObject = Array.objectAtIndex(indexPath.row) as? PFObject
        
        
        if let ConnectObject = ConnectObject{
            
            let ToUserID : PFUser = ConnectObject["toUser"] as! PFUser
            
            let queryUsers = PFUser.query()
            queryUsers?.getObjectInBackgroundWithId(ToUserID.objectId!, block: { (Object:PFObject?, error:NSError?) -> Void in
                
                if error == nil && Object != nil {
                    let ToUser:PFUser = Object as! PFUser
                    
                   let parentName = ToUser["first_name"]as? String
                   let parentID = ToUserID
                    
                    self.selectedParent = parentName
                    self.selectedParentId = parentID
                                        
                    

                    self.performSegueWithIdentifier("chat", sender: indexPath.row)
                    
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "chat") {
            let vc = segue.destinationViewController as! ChatMSGViewController
            vc.PName = selectedParent
            vc.ParentID = selectedParentId
            
                    }
    }


    

}
