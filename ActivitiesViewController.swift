//
//  ActivitiesViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 10/16/15.
//  Copyright © 2015 Amal Almansour. All rights reserved.
//

import UIKit

class ActivitiesViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    
    @IBOutlet weak var ParentName: UILabel!
    
    @IBOutlet weak var BabyName: UILabel!
    
    @IBOutlet weak var ActivityType: UITextField!
    
    @IBOutlet weak var Type: UITextField!
    
    @IBOutlet weak var Comments: UITextField!
    
    var pickOption = ["Select one..","Feeding", "Diapering", "Sleeping", "Supplies", "Other"]
    
    var BName:String?
    var PName:String?
    var ParentID:PFUser?
    
    func textFieldShouldReturn(let textField: UITextField) -> Bool {
        if textField == ActivityType{
            Type.becomeFirstResponder()
        }else if textField == Type{
            
            Comments.becomeFirstResponder()
        }else{
        Comments.resignFirstResponder()
            performAction()
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor.blueColor()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
        let spaceButton = UIBarButtonItem(title: "Select Activity's Name ..", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        spaceButton.tintColor = UIColor.blackColor()
        //let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        ActivityType.inputView = picker
        ActivityType.inputAccessoryView = toolBar
        
        BabyName.text = BName
        ParentName.text = PName
        
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ActivityType.text = pickOption[row]
    }
    func donePicker() {
        ActivityType.resignFirstResponder()
    }
    /*func cancelPreferencePicker() {
        ActivityType.resignFirstResponder()
    }*/
    
    override func viewDidLayoutSubviews() {
        
        self.edgesForExtendedLayout = UIRectEdge()
    }

   
    @IBAction func sendActivityMsg(sender: AnyObject) {
        performAction()
    }
    
    func performAction(){
        
        let SendActivityMsg = PFObject(className: "Activity")
        let acl = PFACL(user: PFUser.currentUser()!)
        acl.publicWriteAccess = true
        acl.publicReadAccess = true
        acl.publicWriteAccess = true
        SendActivityMsg.ACL = acl
        
        /*if( self.BabyName.text!.isEmpty || self.ParentName.text!.isEmpty || self.ActivityType.text!.isEmpty )
        {
        let myAlert = UIAlertController(title:"Error", message:"All fields are requierd to fill in", preferredStyle:UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
        
        return}*/
        
        if(self.ActivityType.text!.isEmpty )
        {
            let myAlert = UIAlertController(title:"Error", message:"Please fill in the activity name.", preferredStyle:UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            return}
        
        
        SendActivityMsg.setObject(self.BName!, forKey: "baby_name")
        SendActivityMsg.setObject(self.PName!, forKey: "parent_name")
        SendActivityMsg.setObject(self.ActivityType.text!, forKey: "activity_type")
        SendActivityMsg.setObject(self.Type.text!, forKey: "type")
        SendActivityMsg.setObject(self.Comments.text!, forKey: "comments")
        SendActivityMsg.setObject(ParentID!, forKey: "parent_Id")
        SendActivityMsg.setObject(PFUser.currentUser()!, forKey: "sender")
        
        PFUser.currentUser()!.addObjectsFromArray([self.ParentID!], forKey: "ActivityParents")
        PFUser.currentUser()!.saveInBackground()
        // print("ActivityParents Saved")
        
        SendActivityMsg.saveInBackgroundWithBlock { (saved:Bool, error:NSError?) -> Void in
            
            if saved {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                error!.localizedDescription
            }
        }
        
        let saveUsersID = PFObject(className: "SendersID")

        let getUserMSGQuery = PFQuery(className: "SendersID")
        getUserMSGQuery.whereKey("sender", equalTo: PFUser.currentUser()!)
        getUserMSGQuery.whereKey("parent_Id", equalTo: ParentID!)
        getUserMSGQuery.orderByDescending("createdAt")
        getUserMSGQuery.limit = 1
        getUserMSGQuery.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error:NSError?) -> Void in
            
            if object == nil{
                saveUsersID.setObject(PFUser.currentUser()!, forKey: "sender")
                saveUsersID.setObject(self.ParentID!, forKey: "parent_Id")
                saveUsersID.setObject(false, forKey: "Read")
                saveUsersID.setObject("notRead", forKey: "Me")
                saveUsersID.saveInBackground()
            }else{
                
                let deleteOldIdQuery = PFQuery(className: "SendersID")
                deleteOldIdQuery.whereKey("sender", equalTo: PFUser.currentUser()!)
                deleteOldIdQuery.whereKey("parent_Id", equalTo: self.ParentID!)
                deleteOldIdQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                            
                            saveUsersID.setObject(PFUser.currentUser()!, forKey: "sender")
                            saveUsersID.setObject(self.ParentID!, forKey: "parent_Id")
                            saveUsersID.setObject(false, forKey: "Read")
                            saveUsersID.setObject("notRead", forKey: "Me")
                            saveUsersID.saveInBackground()
                            
                            
                        }
                    }
                })
            }
        }
        
        
       let SendActivityMsg2 = PFObject(className: "Activity2")
         /*let acl2 = PFACL(user: PFUser.currentUser()!)
        acl2.publicWriteAccess = true
        acl2.publicReadAccess = true
        acl2.publicWriteAccess = true
        SendActivityMsg2.ACL = acl*/
        
        if(self.ActivityType.text!.isEmpty )
        {
            let myAlert = UIAlertController(title:"Error", message:"Please fill in the activity.", preferredStyle:UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            return}
        
        
        SendActivityMsg2.setObject(self.BName!, forKey: "baby_name")
        SendActivityMsg2.setObject(self.PName!, forKey: "parent_name")
        SendActivityMsg2.setObject(self.ActivityType.text!, forKey: "activity_type")
        SendActivityMsg2.setObject(self.Type.text!, forKey: "type")
        SendActivityMsg2.setObject(self.Comments.text!, forKey: "comments")
        SendActivityMsg2.setObject(ParentID!, forKey: "parent_Id")
        SendActivityMsg2.setObject(PFUser.currentUser()!, forKey: "sender")
        
        PFUser.currentUser()!.addObjectsFromArray([self.ParentID!], forKey: "ActivityParents")
        PFUser.currentUser()!.saveInBackground()
        // print("ActivityParents Saved")
        
        SendActivityMsg2.saveInBackgroundWithBlock { (saved:Bool, error:NSError?) -> Void in
            
            if saved {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                error!.localizedDescription
            }
        }

        let saveUsersID2 = PFObject(className: "SendersID2")
        
        let getUserMSGQuery2 = PFQuery(className: "SendersID2")
        getUserMSGQuery2.whereKey("sender", equalTo: PFUser.currentUser()!)
        getUserMSGQuery2.whereKey("parent_Id", equalTo: ParentID!)
        getUserMSGQuery2.orderByDescending("createdAt")
        getUserMSGQuery2.limit = 1
        getUserMSGQuery2.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error:NSError?) -> Void in
            
            if object == nil{
                saveUsersID2.setObject(PFUser.currentUser()!, forKey: "sender")
                saveUsersID2.setObject(self.ParentID!, forKey: "parent_Id")
                saveUsersID2.setObject(false, forKey: "Read")
                saveUsersID2.setObject("notRead", forKey: "Me")
                saveUsersID2.saveInBackground()
            }else{
                
                let deleteOldIdQuery = PFQuery(className: "SendersID2")
                deleteOldIdQuery.whereKey("sender", equalTo: PFUser.currentUser()!)
                deleteOldIdQuery.whereKey("parent_Id", equalTo: self.ParentID!)
                deleteOldIdQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                            
                            saveUsersID2.setObject(PFUser.currentUser()!, forKey: "sender")
                            saveUsersID2.setObject(self.ParentID!, forKey: "parent_Id")
                            saveUsersID2.setObject(false, forKey: "Read")
                            saveUsersID2.setObject("notRead", forKey: "Me")
                            saveUsersID2.saveInBackground()
                            
                        }
                    }
                })
            }
        }


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
}
