//
//  ProfileViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 10/6/15.
//  Copyright © 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var Namedisplay: UILabel!
    @IBOutlet weak var Emailaddress: UITextField!
    @IBOutlet weak var profilephotoimageview: UIImageView!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Repeatpassword: UITextField!
    @IBOutlet weak var Firstname: UITextField!
    //@IBOutlet weak var Lastname: UITextField!
    
    func textFieldShouldReturn(let textField: UITextField) -> Bool {
        if textField == Emailaddress{
            Password.becomeFirstResponder()
        }else if textField == Password{
            Repeatpassword.becomeFirstResponder()
        }else if textField == Repeatpassword{
            Firstname.becomeFirstResponder()
        }else{
        Firstname.resignFirstResponder()
            performAction()
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Load user details
        
        let useremailaddress = PFUser.currentUser()?.objectForKey("email") as! String
        //let userpassword
        //let userrepeatpassword
        let userfirstname = PFUser.currentUser()?.objectForKey("first_name")as! String
        //let userlastname = PFUser.currentUser()?.objectForKey("last_name")as! String
        
        Emailaddress.text = useremailaddress
        Firstname.text = userfirstname
        //Lastname.text = userlastname
        Namedisplay.text = userfirstname
        
        if (PFUser.currentUser()?.objectForKey("profile_picture") != nil)
        {
            let userImageFile:PFFile = PFUser.currentUser()?.objectForKey("profile_picture") as! PFFile
            
            
            userImageFile.getDataInBackgroundWithBlock ({ (imageData:NSData?, error: NSError?) -> Void in
                
                if(imageData != nil)
                {
                self.profilephotoimageview.image = UIImage(data: imageData!)
                }
        })
    }
    }
    
    override func viewDidLayoutSubviews() {
        
        self.edgesForExtendedLayout = UIRectEdge()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func Changephoto(sender: AnyObject) {
        
        let mypickercontroller = UIImagePickerController()
        mypickercontroller.delegate = self
        mypickercontroller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(mypickercontroller, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        profilephotoimageview.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func Updatebutton(sender: AnyObject) {
        performAction()
        
    }
    func performAction(){
        let userfirstname = PFUser.currentUser()?.objectForKey("first_name")as! String
        //let userlastname = PFUser.currentUser()?.objectForKey("last_name")as! String
        Namedisplay.text = userfirstname //+ " " + userlastname
        
        //Get user data
        let myUser = PFUser.currentUser()!
        
        //Get Profile image
        let profileimageData = profilephotoimageview.image!
        let profileImageDataJPEG = UIImageJPEGRepresentation(profileimageData, 1)
        
        //let profileimagedata = UIImageJPEGRepresentation(profilephotoimageview.image!, 1)
        //let profileImageData = UIImageJPEGRepresentation(profilePictureImageView.image!, 1)
        
        //Checks if all fields are empty
        
        if (Emailaddress.text!.isEmpty &&
            Password.text!.isEmpty &&
            Repeatpassword.text!.isEmpty &&
            Firstname.text!.isEmpty &&
            (profileImageDataJPEG == nil)){
                
                let myAlert = UIAlertController(title:"Alert", message:"All fields are requierd to fill in", preferredStyle:UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                return
                
        }
        
        // Check if the passwords match
        if (!Password.text!.isEmpty && Password.text !=
            Repeatpassword.text!) {
                
                let myAlert = UIAlertController(title:"Alert", message:"Passwords do not match. Please try again.", preferredStyle:UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                return
                
        }
        
        //Check if First name and last name are empty
        
        if (Firstname.text!.isEmpty ||
            Emailaddress.text!.isEmpty)
            
        {
            
            let myAlert = UIAlertController(title:"Alert", message:"First name and last name are requierd fields.", preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            return
        }
        
        //Set new values
        /*let myUser:PFUser = PFUser()
        myUser.username = useremail
        myUser.password = userpass
        myUser.email = useremail
        myUser.setObject(userfname!, forKey: "first_name")
        myUser.setObject(userlname!, forKey: "last_name")*/
        
        let userEmail = Emailaddress.text
        let userFname = Firstname.text
        
        myUser.username = userEmail
        myUser.email = userEmail
        myUser.setObject(userFname!, forKey: "first_name")
        
        if (!Password.text!.isEmpty)
        {
            let userPass = Password.text
            myUser.password = userPass
        }
        
        if (profileImageDataJPEG != nil)
        {
            let profileImageFile = PFFile(data: profileImageDataJPEG!)
            
            myUser.setObject(profileImageFile!, forKey: "profile_picture")
          
        }
        
        // Display activity indicator
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.labelText = "Please wait"
        
        myUser.saveInBackgroundWithBlock { (success, error) -> Void in
            
            // Hide activity indicator
            loadingNotification.hide(true)
            
            if(error != nil)
            {
                
                let myAlert = UIAlertController(title:"Alert", message:error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert);
                
                let okAction =  UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil);
                myAlert.addAction(okAction);
                self.presentViewController(myAlert, animated:true, completion:nil);
                
                return
            }
            
            
            if(success)
            {
                
                let userMessage = "Your profile is successfully updated."
                let myAlert = UIAlertController(title:"Message", message:userMessage, preferredStyle: UIAlertControllerStyle.Alert);
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil);   myAlert.addAction(okAction);
                self.presentViewController(myAlert, animated:true, completion:nil);
                
            }
            
            
            
        }   
        
    }
    
    @IBAction func Signout(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_name")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        PFUser.logOutInBackground()
        
        //Navigate to Sign in page
        let MainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let SignInPage:ViewController = MainStoryBoard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        
        let SignInPageNav = UINavigationController(rootViewController: SignInPage)
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = SignInPageNav

    }
}
