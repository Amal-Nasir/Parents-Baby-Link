//
//  AddParentTableViewCell.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 11/3/15.
//  Copyright © 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse
class AddParentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
   
    @IBOutlet weak var followbutton: UIButton!
    
    
    override func prepareForReuse()
    {
        
        self.userNameLabel.text = nil
        self.userImage.image = nil
        //self.followbutton.tag = 0
        //self.followbutton.addTarget(self, action: nil, forControlEvents: .TouchUpInside)
        //self.followbutton.setTitle(nil , forState: UIControlState.Normal)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /*  @IBAction func FollowUnfollowButton(sender: AnyObject) {
    var myUser = PFUser()
    let currentUser = PFUser.currentUser()
    if currentUser != nil {
    myUser = currentUser!
    } else {
    //Navigate to Sign in page
    let MainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let SignInPage:ViewController = MainStoryBoard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
    let SignInPageNav = UINavigationController(rootViewController: SignInPage)
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    appDelegate.window?.rootViewController = SignInPageNav
    }
    var emailUserToFollow = "xx@aa.ss"
    var query = PFUser.query()
    query!.whereKey("email", equalTo:emailUserToFollow)
    var userToFollow = query!.findObjects()
    let relation = userToFollow.relationForKey("follower")
    relation.addObject(myUser)
    userToFollow.save()}*/
    

}
