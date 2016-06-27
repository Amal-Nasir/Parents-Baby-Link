//
//  BabyTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/11/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit

class BabyTableViewController: UITableViewController {

    var userBabies = [PFObject]()
    
    var tableData = [""]
    
    var selectedParent:String?
    var selectedParentId:PFUser?
    var selectedBaby:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        
    }
    override func viewDidAppear(animated: Bool) {
        loadUserBabies()
    }

    func loadUserBabies()
    {
        
        let babyQuery = PFQuery(className: "Baby")
        babyQuery.whereKey("user2", equalTo:PFUser.currentUser()!)
        babyQuery.addDescendingOrder("createdAt")
        babyQuery.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            
            self.userBabies.removeAll(keepCapacity: false)
            self.tableData.removeAll(keepCapacity: false)
            
            if let searchResults = result
            {
                self.userBabies = searchResults
                
                self.tableView.reloadData()
            }else {
                print(error)
            }
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
        
               return userBabies.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BabyListCell", forIndexPath: indexPath) as! BabyTableViewCell
        
        let baby = userBabies[indexPath.row]
        //print(baby)
        let babyName = baby.objectForKey("baby_name") as? String
         cell.babyName.text = babyName
        
        let fullname = baby.objectForKey("parent_fname") as? String
        //cell.parentName.text = fullname
        
        let Id = baby.objectForKey("user1")
        let CheckBaby = PFUser.query()
        CheckBaby!.whereKey("objectId", equalTo: (Id?.objectId)! )
        //CheckBaby.whereKey("first_name", equalTo: fullname)
        CheckBaby!.findObjectsInBackgroundWithBlock({ (object:[PFObject]?,
        error:NSError?) -> Void in
        if error == nil{
        //var parentNameNotChanged = true
        
        for object in object! {
            
        let parent = object["first_name"] as? String
            
        if parent == fullname {
        
        //parentNameNotChanged = false
        cell.parentName.text = fullname
        } else{
        cell.parentName.text = object["first_name"] as? String
            
        }
            let query = PFQuery(className:"Baby")
            query.getObjectInBackgroundWithId(baby.objectId!) {
                (gameScore: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let gameScore = gameScore {
                    gameScore["parent_fname"] = parent
                    gameScore.saveInBackground()
                }
            }
            
            /*let myUser1 = baby.objectForKey("user1") as? PFUser
            myUser1!.setObject(parent!, forKey: "parent_fname")
            myUser1!.saveInBackground()*/

        }
        }else {
        print("Error:\(error!) \(error!.userInfo) ")
        }
        })
        
        
        
        let babyClass = baby.objectForKey("class_name") as? String
        cell.babyClass.text = babyClass
        
        return cell
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
            
            let baby = userBabies[indexPath.row]
            
            self.userBabies.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            let babyQuery = PFQuery(className: "Baby")
            babyQuery.whereKey("user2", equalTo:PFUser.currentUser()!)
            babyQuery.whereKey("objectId", equalTo: baby.objectId!)
            
            babyQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                print((self.userBabies[indexPath.row].objectId))
                
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()}}})
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

}
