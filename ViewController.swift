//
//  ViewController.swift
//  Parents-Baby Link
//  Created by Amal Almansour on 9/2/15.
//  Copyright (c) 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UINavigationControllerDelegate, UITabBarDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var UserEmailAddress: UITextField!
    @IBOutlet weak var UserPassword: UITextField!
    
    @IBOutlet weak var SaveStatusSwitch: UISwitch!
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == UserEmailAddress{
            UserPassword.becomeFirstResponder()
        }else {
            UserPassword.resignFirstResponder()
            performAction()
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SaveStatusSwitch.addTarget(self, action: Selector("switchIsChanged:"), forControlEvents: UIControlEvents.ValueChanged)
       // SaveStatusSwitch.addTarget(self, action: Selector("Signinbutton:Pressed"), forControlEvents: UIControlEvents.ValueChanged)
   
}

override func viewDidLayoutSubviews() {
    
    self.edgesForExtendedLayout = UIRectEdge()
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}

    
    //Playing with switch
    /*func switchIsChanged(mySwitch: UISwitch) {
        if SaveStatusSwitch.on {
            myswitch.text = "UISwitch is ON"
        } else {
            myswitch.text = "UISwitch is OFF"}}
    
    @IBAction func Test(sender: AnyObject) {
        if SaveStatusSwitch.on {
            myswitch.text = "UISwitch is OFF"
            print("Switch is on")
            SaveStatusSwitch.setOn(false, animated:true)
        } else {
            myswitch.text = "UISwitch is ON"
            print("Switch is off")
            SaveStatusSwitch.setOn(true, animated:true)}}*/
    
    
    @IBAction func Signinbutton(sender: AnyObject) {
        performAction()
        
            }
    
    func performAction() {
        self.view.endEditing(true)
        
        
        let userEmail = UserEmailAddress.text
        let userPass = UserPassword.text
        
        if( userEmail!.isEmpty || userPass!.isEmpty)
        {
            
            let myAlert = UIAlertController(title:"Error", message:"Email address and password cannot be empty", preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            return
        }
        
        let ActivityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        ActivityIndicator.labelText = "Sending"
        ActivityIndicator.detailsLabelText = "Please wait"
        
        PFUser.logOut()
        PFUser.logInWithUsernameInBackground(userEmail!, password: userPass!) { (user:PFUser?, error:NSError?) -> Void in
            
            ActivityIndicator.hide(true)
            
            var userMsg = "Welcome to Parents-Baby Link!"
            
            if (user != nil)
            {
                
                if user!["emailVerified"] as! Bool == true {
                    
                } else {
                    // User needs to verify email address before continuing
                    let alertController = UIAlertController(
                        title: "Email address verification",
                        message: "We have sent you an email that contains a link - you must click this link before you can continue.",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.Default,
                        handler: { alertController in self.processSignOut()})
                    )
                    // Display alert
                    self.presentViewController(alertController,animated: true,completion: nil)
                    
                    return
                }
                
                //Remmember the user sign in state
                
                if self.SaveStatusSwitch.on {
                    let userName:String? = user?.username
                    NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "user_name")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    //   self.myswitch.text = "UISwitch is ON"
                } else {
                    //  self.myswitch.text = "UISwitch is OFF"
                }
                
                if (user!["role"] as! String == "Care Provider"){
                    
                    //Welcome Msg
                    let myAlert = UIAlertController(title:"Welcome!", message:userMsg, preferredStyle:UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    myAlert.addAction(okAction)
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    
                    //Navigate to protected page
                    /*let MainStoryBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainPage:MainPageViewController = MainStoryBoard.instantiateViewControllerWithIdentifier("MainPageViewController") as! MainPageViewController
                    let mainPageNav = UINavigationController(rootViewController: mainPage)
                    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = mainPageNav*/
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("CareProviderTabBarController") as! UITabBarController
                    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = vc
                }
                    
                else {//Welcome Msg
                    let myAlert = UIAlertController(title:"Welcome!", message:userMsg, preferredStyle:UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    myAlert.addAction(okAction)
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("ParentsTabBarController") as! UITabBarController
                    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = vc
                }
                
            } else {
                
                userMsg = error!.localizedDescription
                let myAlert = UIAlertController(title:"Error", message:userMsg, preferredStyle:UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction (title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                myAlert.addAction(okAction)
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            }
            
            
        }
    
    }

    // Sign the current user out of the app
    func processSignOut() {
        
        // // Sign out
        PFUser.logOut()
        
        // Display sign in / up view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}

