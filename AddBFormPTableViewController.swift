//
//  AddBFormPTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 3/2/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit

class AddBFormPTableViewController: UITableViewController {
    var Array: NSMutableArray = NSMutableArray()
    
    var ConnectObject = PFObject?()
    
    //var refresher: UIRefreshControl!
    
    var selectedParent:String?
    var selectedParentId:PFUser?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
      loadFollowerUsers()
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
                print("succesfully load parents to add baby")
                
                // Do something with the found objects
                for object  in objects!   {
                    
                    self.Array.addObject(object)
                    
                }
                
                self.tableView.reloadData()
                
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
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectParentCell") as! AddBFormPTableViewCell
        
        cell.userNameLabel.text = nil
        
        cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width / 2
        cell.userImage.clipsToBounds = true
        
        cell.userImage.image = nil
        
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
            
        }
        
        return  cell
        
    }
    
       
    @IBAction func Done(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
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
                    self.performSegueWithIdentifier("AddBabyFormParent", sender: indexPath.row)
                    
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "AddBabyFormParent") {
            let vc = segue.destinationViewController as! AddBabyViewController
            vc.PName = selectedParent
            vc.ParentID = selectedParentId
            
           // print(vc.PName)
        }
    }

}
