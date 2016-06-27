//
//  AddParentViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 10/19/15.
//  Copyright © 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class AddParentViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTable: UITableView!
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var SearchResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return SearchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //Nick code
        /*let cell = tableView.dequeueReusableCellWithIdentifier("emojiCell") as! EmojiPostTableViewCell
        let emojiPost = self.emojiPosts[indexPath.row]
        let user = emojiPost["user"] as! PFUser
        user.fetchIfNeeded()
        cell.emojiLabel.text = emojiPost["emoji"] as? String
        cell.descriptionLabel.text = emojiPost["description"] as? String
        cell.usernameLabel.text = user["name"] as? String
        
        let url = user["imageURL"] as! String
        let imageData = NSData(contentsOfURL: NSURL(string: url)!)
        
        if imageData == nil {
        cell.userImageView.image = UIImage()
        } else {
        cell.userImageView.image = UIImage(data: imageData!)
        }
        return cell*/
        /////////////////////////////////////////////////////////
        
        let Cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! AddParentTableViewCell
        Cell.userNameLabel.text = self.SearchResults[indexPath.row]
        
        
        
       /*  let getImage:PFQuery = PFUser.query()!
        getImage.findObjectsInBackgroundWithBlock { (results :[PFObject]?, error: NSError?) -> Void in
 
            if let objects = results
            {
        print("Amal")
        
        for object in objects
        {
            if (object.objectForKey("profile_picture") != nil){
           // let user:PFUser = (results! as NSArray).firstObject as! PFUser
            print("Loly")
                let myUser:PFUser = object as! PFUser
            let userImageFile:PFFile = myUser["profile_picture"] as! PFFile
            print("Lola")
            userImageFile.getDataInBackgroundWithBlock { (imageData:NSData?, error: NSError?) -> Void in
                print("Lilac")
                if error == nil {
                    if imageData != nil
                  {print("OK")
                    Cell.userImage.image = UIImage(named: self.SearchResults[indexPath.row]) }
                    else
                  {Cell.userImage.image = UIImage()}
          }
        }
      }
    }
  }
}*/
        /*let getImage:PFQuery = PFUser.query()!
        getImage.findObjectsInBackgroundWithBlock { (results :[PFObject]?, error: NSError?) -> Void in
    
    if let objects = results {
        For object in objects {
        let myUser:PFUser = object as! PFUser
        let Profile:PFFile = myUser["profile_picture"] as! PFFile
        Profile.getDataInBackgroundWithBlock { (ImageData:NSData?, error:NSError?) -> Void in
            if error == nil {
                if ImageData == nil {
                    Cell.userImage.image = UIImage()
                } else {
                    Cell.userImage.image = UIImage(data: ImageData!)}}}}}*/
            
        //Cell.userImage.image = self.SearchResults
    
        //............................................................
        //Cell.textLabel?.text = self.SearchResults[indexPath.row]
        //let Cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as! AddParentTableViewCell
        // Cell.textLabel?.text = self.SearchResults[indexPath.row]
        /*let SearchResult = self.SearchResults[indexPath.row]
        let user = SearchResult[] as! PFUser
        user.fetchIfNeeded()
        Cell.userNameLabel.text = SearchResult["first_name"]
        Cell.FollowUnfollowbutton.touchInside
        
        let imageData = NSData(contentsOfURL: NSURL(string: url)!)
        
        if imageData == nil {
        cell.userImage.image = UIImage()
        } else {
        cell.userImage.image = UIImage(data: imageData!)
        }*/
        
        
        return Cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        mySearchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        // called when cancel button pressed
        mySearchBar.resignFirstResponder()
        mySearchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        // called when keyboard search button pressed
        mySearchBar.resignFirstResponder()
        //print("Search word =\(searchBar.text!)")
        
        let firstName = searchBar.text!
        let lastName = searchBar.text!
        
        let firstNameQuery:PFQuery = PFUser.query()!
        firstNameQuery.whereKey("first_name", matchesRegex: "(?i)\(firstName)")
        firstNameQuery.whereKey("first_name", containsString: searchBar.text)
        
        let lastNameQuery:PFQuery = PFUser.query()!
        lastNameQuery.whereKey("last_name", matchesRegex: "(?i)\(lastName)")
        
        
        let query = PFQuery.orQueryWithSubqueries([firstNameQuery, lastNameQuery])
        
        
       /* let myUser:PFUser = PFUser()
        let Profile:PFFile = myUser["profile_picture"] as! PFFile
        Profile.getDataInBackgroundWithBlock { (ImageData:NSData?, error:NSError?) -> Void in
            if error == nil {
                let Image:UIImage = UIImage(data: ImageData!)!
                
            }
        }*/
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if (error != nil)
            {
                let myAlert = UIAlertController(title:"Alert", message:error?.localizedDescription, preferredStyle:UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                return
            }
            
            
            if let objects = results 
            {
                self.SearchResults.removeAll(keepCapacity: false)
                
                for object in objects
                {
                    
                    let firstName = object.objectForKey("first_name") as! String
                    let lastName = object.objectForKey("last_name") as! String
                    let fullName = firstName + " " + lastName
                    self.SearchResults.append(fullName)
                    
                }
                
                dispatch_async(dispatch_get_main_queue())
                    {
                    self.myTable.reloadData()
                    self.mySearchBar.resignFirstResponder()
                    }
            }
        }
    }
   
    @IBAction func Refreshbutton(sender: AnyObject)
    {
        mySearchBar.resignFirstResponder()
        mySearchBar.text = ""
        self.SearchResults.removeAll(keepCapacity: false)
        self.myTable.reloadData()
    }
    
    @IBAction func Cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
