//
//  SendActivityTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/24/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class SendActivityTableViewController: UITableViewController {

    var userBabies = [PFObject]()
    
    //var tableData = [""]
    
    var selectedParent:String?
    var selectedParentId:PFUser?
    var selectedBaby:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        //self.navigationItem.rightBarButtonItem = self.Done(<#T##sender: AnyObject##AnyObject#>)
        
        
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
           // self.tableData.removeAll(keepCapacity: false)
            
            if let searchResults = result
            {
                self.userBabies = searchResults
                
                self.tableView.reloadData()
            }
            else{
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BabyListCell1", forIndexPath: indexPath) as! SendActivityTableViewCell
        
        let baby = userBabies[indexPath.row]
        
        let babyName = baby.objectForKey("baby_name") as? String
        cell.babyName.text = babyName
        print(babyName)
        let fullname = baby.objectForKey("parent_fname") as? String
        cell.parentName.text = fullname
        
        return cell
    }
    
    /// Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        
        let returnValue:Bool = true
        
        return returnValue
    }
    
    
    
    // Override to support editing the table view.
    /*override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
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
    }*/
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        /*let DisplayBabiesTableView = self.storyboard?.instantiateViewControllerWithIdentifier("ActivitiesViewController") as! ActivitiesViewController
        DisplayBabiesTableView.selectedUser = selectedUser as? PFUser
        self.navigationController?.showViewController(DisplayBabiesTableView, sender: true)*/
        
        //print("Fila \(userBabies[indexPath.row]) seleccionada")
        
        let baby = userBabies[indexPath.row]
        
        let babyName = baby.objectForKey("baby_name") as? String
        
        let parentName = baby.objectForKey("parent_fname") as? String
        
        let parentID = baby.objectForKey("user1") as? PFUser
        
        selectedParent = parentName
        selectedParentId = parentID
        selectedBaby = babyName
        
        
        performSegueWithIdentifier("activityMsgView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "activityMsgView") {
            let vc = segue.destinationViewController as! ActivitiesViewController
            vc.PName = selectedParent
            vc.BName = selectedBaby
            vc.ParentID = selectedParentId
        }
    }
    
    
    @IBAction func Done(sender: AnyObject) {
        
         self.navigationController?.popViewControllerAnimated(true)
        
    }
    
}
