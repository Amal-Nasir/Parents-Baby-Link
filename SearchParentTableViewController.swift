//
//  SearchParentTableViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 12/21/15.
//  Copyright © 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class SearchParentTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating{
    
    var searchUsers = [PFUser]()

    // To search
    var userSearchController: UISearchController!
    var searchActive: Bool = false
    
    // To follow and unfollow users
    var userIds = [""]
    var isFollowing = ["":false]
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
    super.viewDidLoad()
    
    configureSearchController()
    
    self.tableView.reloadData()
    }
    
    func configureSearchController(){
        
        //if #available(iOS 9.0, *) {
        // iOS 9
        /*  } else {
        Fallback on earlier versions
        let _ = self.resultsController.view          // iOS 8
        }*/
    
    self.userSearchController = UISearchController(searchResultsController: nil)
    // Set the search controller to the header of the table
    self.tableView.tableHeaderView = self.userSearchController.searchBar
    // This is used for dynamic search results updating while the user types
    // Requires UISearchResultsUpdating delegate
    self.userSearchController.searchResultsUpdater = self
    self.userSearchController.dimsBackgroundDuringPresentation = false
    self.definesPresentationContext = true
    
    // Configure the search controller's search bar
    self.userSearchController.searchBar.placeholder = "Search for a parent"
    self.userSearchController.searchBar.sizeToFit()
    self.userSearchController.searchBar.delegate = self
    }
    
    // MARK: - Search Bar Delegate Methods
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    // Force search if user pushes button
    
    let searchString: String = searchBar.text!.lowercaseString
    
    searchActive = true
    
    if (searchString != "" ) {
    loadSearchUsers(searchString)
    }/*else{
        let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
        noDataLabel.text = "No result."
        noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        noDataLabel.textAlignment = NSTextAlignment.Center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }*/
    self.tableView.reloadData()
    // self.resultsController.tableView.reloadData()
    self.userSearchController.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    
    searchActive = false
    searchBar.text = ""
    
    self.userSearchController.resignFirstResponder()
    
    self.searchUsers.removeAll(keepCapacity: false)
    let searchString: String = searchBar.text!.lowercaseString
    loadSearchUsers(searchString)
    self.tableView.reloadData()
    //self.resultsController.tableView.reloadData()
    
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    //self.userSearchController.resignFirstResponder()
    searchActive = true
    self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    //self.userSearchController.resignFirstResponder()
    searchActive = false
    self.tableView.reloadData()
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
    
    let searchString: String = searchBar.text!.lowercaseString
    
    if (searchString == ""){
    searchActive = false
        let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
        noDataLabel.text = "No result."
        noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        noDataLabel.textAlignment = NSTextAlignment.Center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
}
    else {
    searchActive = true
    
    if (searchString != "" ){
    loadSearchUsers(searchString)}
    }
    self.tableView.reloadData()
    //self.resultsController.tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    //this clear evry thing when press clear button, but the buttons!!
    self.searchUsers.removeAll(keepCapacity: false)
    self.tableView.reloadData()
        
    let searchString : String = searchController.searchBar.text!.lowercaseString
    
    if (searchString != "" && self.userSearchController.active) {
    loadSearchUsers(searchString)
    self.tableView.reloadData()
    }else{
        let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
        noDataLabel.text = "No result."
        noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        noDataLabel.textAlignment = NSTextAlignment.Center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
    
    }
    
    
    // MARK: - Parse Backend methods
    func loadSearchUsers(searchString: String) {
    
    let NameQuery:PFQuery = PFUser.query()!
    NameQuery.whereKey("first_name", matchesRegex: "(?i)\(searchString)")
    NameQuery.whereKey("role", equalTo: "Parent")
    NameQuery.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
    NameQuery.orderByAscending("first_name")
    
    self.searchActive = true
        if searchString.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()) != "" {

    NameQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
    
    if (error != nil)
{
    let myAlert = UIAlertController(title:"Error", message:error?.localizedDescription, preferredStyle:UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
    myAlert.addAction(okAction)
    self.presentViewController(myAlert, animated: true, completion: nil)
    
    return
    }
    
    if let users = objects {
    
    self.searchUsers.removeAll(keepCapacity: false)
    self.userIds.removeAll(keepCapacity: false)
    self.isFollowing.removeAll(keepCapacity: false)
    
    for object in users {
    if let user = object as? PFUser {
    
    self.searchUsers.append(user)
    self.userIds.append(user.objectId!)
    self.tableView.reloadData()
    
    let query = PFQuery(className: "follow")
    query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
    query.whereKey("toUser", equalTo: user)
    query.whereKey("status", equalTo:"followed")
    
    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
    
    if let objects = objects {
    
    if objects.count > 0 {
    
    self.isFollowing[user.objectId!] = true
    
} else {
    
    self.isFollowing[user.objectId!] = false
    
    }
    }
    
    if self.isFollowing.count == self.searchUsers.count {
    self.tableView.reloadData()
    self.searchActive = false
    }
    
    })
    
    //}end if user.objectId! != PFUser.currentUser()?.objectId
    }//endif let user = object as? PFUser
    } // end for loop
    }
    
    }// end first query
        }
    
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    var numOfSection: NSInteger = 0
    
    if searchUsers.count > 0 || self.userSearchController.active {
    self.tableView.backgroundView = nil
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    numOfSection = 1
    
    } else {
    
    let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
    noDataLabel.text = "No result."
    noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 180.0/255.0, alpha: 1.0)
    noDataLabel.textAlignment = NSTextAlignment.Center
    self.tableView.backgroundView = noDataLabel
    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    
    numOfSection = 0
    }
    return numOfSection
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
{
    
    if  self.userSearchController.active {
    
    return self.searchUsers.count
}else{
    return 0}
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell :AddParentTableViewCell?
    cell = tableView.dequeueReusableCellWithIdentifier("userCell") as? AddParentTableViewCell
    
    if cell == nil {
    cell = AddParentTableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "userCell")
    }
    
    cell!.userNameLabel.text = nil
    cell!.userImage.layer.cornerRadius = cell!.userImage.frame.size.width / 2
    cell!.userImage.clipsToBounds = true
    cell!.userImage.image = nil
    
    if (self.userSearchController.active && self.searchUsers.count > indexPath.row) {
    
    let individualuser = searchUsers[indexPath.row]
    
    let username = individualuser.objectForKey("first_name") as! String
    
    // bind data to the search results cell
    
    cell!.userNameLabel.text = username
    
    if (individualuser.objectForKey("profile_picture") != nil){
    
    let pfimage = individualuser.objectForKey("profile_picture") as! PFFile
    pfimage.getDataInBackgroundWithBlock({
    (result, error) in
    if (result != nil){
    cell!.userImage.image = UIImage(data: result!)}
    else
{cell!.userImage.image = UIImage()}})
    
}else{
    cell!.userImage.image = UIImage(named: "default-user-icon-profile")}
    
    // Button call
    cell!.followbutton.tag = indexPath.row
    cell!.followbutton.addTarget(self, action: "logAction:", forControlEvents: .TouchUpInside)
    }
    //to keep the checkmark`s on the followers
    
    let followedObjectId = userIds[indexPath.row]
    if isFollowing[followedObjectId] == true {
    
    cell!.followbutton.setTitle("Delete", forState: UIControlState.Normal)
    cell!.followbutton.backgroundColor = UIColor.greenColor()
}else {
    cell!.followbutton.setTitle("Add", forState: UIControlState.Normal)
    cell!.followbutton.backgroundColor = UIColor.blueColor()
    }
    
    //print("Hours of code")
    
    return cell!
    
    }
    
    
    @IBAction func logAction(sender: AnyObject) {
    
    var followedObjectId = ""
    
    followedObjectId = userIds[sender.tag]
    
    if isFollowing[followedObjectId] == false {
    
    isFollowing[followedObjectId] = true
    
    (sender as! UIButton).setTitle("Delete", forState: UIControlState.Normal)
    (sender as! UIButton).backgroundColor = UIColor.greenColor()
    
    let following = PFObject(className: "follow")
    let follow:PFQuery = PFUser.query()!
    follow.whereKey("objectId", equalTo: followedObjectId)
    follow.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
    if let users = objects {
    for object in users {
    if let user = object as? PFUser {
    following.setObject(PFUser.currentUser()!, forKey: "fromUser")
    following.setObject(user, forKey: "toUser")
    following.setObject("followed", forKey: "status")
    
    following.saveInBackground()
    }
    
    }
    
    }
    })
    //following.setObject(PFUser.currentUser()!, forKey: "fromUser")
    //following.setObject(PFUser.fetch(), forKey: "toUser")
    //following.setObject("followed", forKey: "status")
    
    
    // following["followTo"] = userIds[sender.tag]
    // following["followFrom"] = PFUser.currentUser()?.objectId
    //following["status"] = "followed"
    
    //following.saveInBackground()
    
} else {
    
    isFollowing[followedObjectId] = false
    
    (sender as! UIButton).setTitle("Add", forState: UIControlState.Normal)
    (sender as! UIButton).backgroundColor = UIColor.blueColor()
    
    let query = PFQuery(className: "follow")
    let follow:PFQuery = PFUser.query()!
    follow.whereKey("objectId", equalTo: followedObjectId)
    follow.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
    
    if let users = objects {
    for object in users {
    if let user = object as? PFUser {
    
    query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
    query.whereKey("toUser", equalTo: user)
    query.whereKey("status", equalTo:"followed")
    
    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
    
    if let objects = objects {
    
    for object in objects {
    
    object.deleteInBackground()
    
    }
    }
    
    
    })
        // Delete a parent's babies
        let DeleteBaby = PFQuery(className: "Baby")
        DeleteBaby.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            
            DeleteBaby.whereKey("user2", equalTo: PFUser.currentUser()!)
            DeleteBaby.whereKey("user1", equalTo: user)
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
            DeleteChat.whereKey("to", equalTo: user)
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
            
            DeleteChat1.whereKey("from", equalTo: user )
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
            DeleteChat3.whereKey("to", equalTo: user)
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
            
            DeleteChat2.whereKey("from", equalTo: user )
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
            DeleteActivity.whereKey("parent_Id", equalTo: user)
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
            DeleteSender.whereKey("parent_Id", equalTo: user)
            DeleteSender.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
        })
    }}}
    })
    
    
    /* query.whereKey("followFrom", equalTo: PFUser.currentUser()!.objectId!)
    query.whereKey("followTo", equalTo: userIds[sender.tag])
    query.whereKey("status", equalTo:"followed")
    
    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
    
    if let objects = objects {
    
    for object in objects {
    
    object.deleteInBackground()
    
    }
    }
    
    
    })*/
    
    
    }
    
    
    
    
    }
    
    
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    self.userSearchController.resignFirstResponder()
    
    // if (self.userSearchController.active && self.searchUsers.count > 0) {}
    // Segue or whatever you want
    
    /*let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    
    let followedObjectId = userIds[indexPath.row]
    
    if isFollowing[followedObjectId] == false {
    isFollowing[followedObjectId] = true
    
    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    
    let following = PFObject(className: "followers")
    following["followTo"] = userIds[indexPath.row]
    following["followFrom"] = PFUser.currentUser()?.objectId
    
    following.saveInBackground()
    
    } else {
    
    isFollowing[followedObjectId] = false
    
    cell.accessoryType = UITableViewCellAccessoryType.None
    
    let query = PFQuery(className: "followers")
    query.whereKey("followFrom", equalTo: PFUser.currentUser()!.objectId!)
    query.whereKey("followTo", equalTo: userIds[indexPath.row])
    
    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
    
    if let objects = objects {
    for object in objects {
    
    object.deleteInBackground()}}})*/
    
    //else {normal data source selection}
    
    }
    
    /* @IBAction func DoneFollowing(sender: AnyObject) {
    
    // self.navigationController?.popViewControllerAnimated(true)
    //self.dismissViewControllerAnimated(true, completion: nil)
    */
    
}

