//
//  AddBabyViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/10/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class AddBabyViewController: UIViewController, UITextFieldDelegate {

    var PName:String?
    var ParentID:PFUser?

    @IBOutlet weak var babyName: UILabel!

    @IBOutlet weak var parentName: UILabel!
    
    @IBOutlet weak var babyClass: UITextField!
    
    func textFieldShouldReturn(let textField: UITextField) -> Bool {
        if textField == babyName{
            babyClass.becomeFirstResponder()
        } else{
        babyClass.resignFirstResponder()
            performAction()
        }
        return true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentName.text = PName
    }

    
    @IBAction func addBaby(sender: AnyObject) {
        performAction()   
}
    func performAction(){
        if( self.babyName.text!.isEmpty || self.babyClass.text!.isEmpty )
        {
            let myAlert = UIAlertController(title:"Error", message:"All fields are required to fill in.", preferredStyle:UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            return}
        
        
        //print(ParentID!.objectId!)
        
        let CheckBaby = PFQuery(className: "Baby")
        CheckBaby.whereKey("user1", equalTo: ParentID!)
        CheckBaby.whereKey("user2", equalTo: PFUser.currentUser()!)
        CheckBaby.findObjectsInBackgroundWithBlock({ (object:[PFObject]?,
            error:NSError?) -> Void in
            if error == nil{
                var babyNotFound = true
                
                for object in object! {
                    
                    if object["baby_name"] as? String == self.babyName.text {
                        
                        babyNotFound = false
                        
                        //print("This baby has been added before.")
                        let myAlert = UIAlertController(title:"Error", message:"This baby has been added before.", preferredStyle:UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        myAlert.addAction(okAction)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            () -> Void in
                            self.presentViewController(myAlert, animated: true, completion: nil)
                        }
                        return
                    }
                }
                
                if babyNotFound {
                    let addBaby = PFObject(className: "Baby")
                    
                    addBaby.setObject(self.ParentID!, forKey: "user1")
                    addBaby.setObject(self.babyName.text!, forKey: "baby_name")
                    addBaby.setObject(self.parentName.text!, forKey: "parent_fname")
                    addBaby.setObject(self.babyClass.text!, forKey: "class_name")
                    addBaby.setObject(PFUser.currentUser()!, forKey: "user2")
                    
                    addBaby.saveInBackgroundWithBlock { (saved:Bool, error:NSError?) -> Void in
                        
                        if saved {
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            error!.localizedDescription
                        }
                    }
                }
            }else {
                print("Error:\(error!) \(error!.userInfo) ")
            }
        })
        
        
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
