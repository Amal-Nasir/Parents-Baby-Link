//
//  SignUpViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 9/13/15.
//  Copyright (c) 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse
import CoreActionSheetPicker

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
        
    @IBOutlet weak var useremailaddress: UITextField!
    @IBOutlet weak var userpassword: UITextField!
    @IBOutlet weak var userrepeatpassword: UITextField!
    @IBOutlet weak var userfirstname: UITextField!
    @IBOutlet weak var userRole1: UITextField!
    
    @IBAction func UserRole(sender: UITextField) {
        let userRole = ActionSheetStringPicker(title: "Select role..", rows: ["Care Provider", "Parent"], initialSelection: 0,
            doneBlock: {
            picker, values, indexes in
            self.userRole1.text = ("\(indexes)")
            return  },
            cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
    
        userRole.showActionSheetPicker()
    }
    
    func textFieldShouldReturn(let textField: UITextField) -> Bool {
        if textField == useremailaddress{
            userpassword.becomeFirstResponder()
        }else if textField == userpassword{
            userrepeatpassword.becomeFirstResponder()
        }else if textField == userrepeatpassword{
            userfirstname.becomeFirstResponder()
        }else if textField == userfirstname{
            userRole1.becomeFirstResponder()
        }else{
        userRole1.resignFirstResponder()
        performAction()
        }
        return true
    }

    
    @IBOutlet weak var profilephotoimageview: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidLayoutSubviews() {
        
        self.edgesForExtendedLayout = UIRectEdge()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //for imageview ...
    
    @IBAction func selectprofilephotobutton(sender: AnyObject) {
     
        let mypickercontroller = UIImagePickerController()
        mypickercontroller.delegate = self
        mypickercontroller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(mypickercontroller, animated: true, completion: nil)
        
    }
    
    //func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        profilephotoimageview.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func signupbottun(sender: AnyObject) {
        
        performAction()
        
    }
    
    func performAction(){
        self.view.endEditing(true)
        
        let useremail = useremailaddress.text
        let userpass = userpassword.text
        let userrepeatpass = userrepeatpassword.text
        let userfname = userfirstname.text
        //let userlname = userlastname.text
        let userrole = userRole1.text
        
        //checks if any of the fields are empt
        if( useremail!.isEmpty || userpass!.isEmpty || userrepeatpass!.isEmpty || userfname!.isEmpty )
        {
            let myAlert = UIAlertController(title:"Error", message:"All fields are requierd to fill in", preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            return
            
        }
        
        // Check if the passwords match
        if (userpass != userrepeatpass) {
            
            let myAlert = UIAlertController(title:"Error", message:"Passwords do not match. Please try again.", preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            return
            
        }
        // Check if password less than 6
        if (userpass!.characters.count < 6) {
            
            let myAlert = UIAlertController(title:"Error", message:"Passwords should be 6 or more characters", preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            return
            
        }
        
        
        let myUser:PFUser = PFUser()
        myUser.username = useremail
        myUser.password = userpass
        myUser.email = useremail
        myUser.setObject(userfname!, forKey: "first_name")
        myUser.setObject(userrole!, forKey: "role")
        
        if let profileImageData = profilephotoimageview.image
        {
            
            let profileImageDataJPEG = UIImageJPEGRepresentation(profileImageData, 1)
            let profileImageFile = PFFile(name: "profile_picture.png", data: profileImageDataJPEG!)
            myUser.setObject(profileImageFile!, forKey: "profile_picture")
            
        }
        
        let ActivityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        ActivityIndicator.labelText = "Sending"
        ActivityIndicator.detailsLabelText = "Please wait"
        
        processSignOut()
        myUser.signUpInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            
            ActivityIndicator.hide(true)
            
            var userMessage = "You are successfully registered. Please check your email."
            
            if(!success)
            {
                userMessage = error!.localizedDescription
            }
            
            let myAlert = UIAlertController(title:"Message", message:userMessage, preferredStyle:UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default) { action in
                
                if(success)
                {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        }
    
    }
    @IBAction func cancelbutton(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Sign the current user out of the app
    func processSignOut() {
        
        // // Sign out
        PFUser.logOut()
        
        // Display sign in / up view controller
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        //self.presentViewController(vc, animated: true, completion: nil)
    }

}


