//
//  PasswordResetViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 9/29/15.
//  Copyright © 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse

class PasswordResetViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(let textField: UITextField) -> Bool {
        if textField == Emailaddress{
        Emailaddress.resignFirstResponder()
           performAction()
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var Emailaddress: UITextField!

    @IBAction func Sendbutton(sender: AnyObject) {
        performAction()
    }
    
    func performAction(){
        self.view.endEditing(true)
        //Emailaddress.resignFirstResponder()
        
        let emailAddress = Emailaddress.text
        
        if emailAddress!.isEmpty {
            //Display warning msg
            let userMessage:String = "Please type in your email address."
            displayMessage(userMessage)
            return
        }
        
        
        let ActivityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        ActivityIndicator.labelText = "Sending"
        ActivityIndicator.detailsLabelText = "Please wait"
        
        
        PFUser.requestPasswordResetForEmailInBackground(emailAddress!, block: { (success: Bool, error: NSError?) -> Void in
            
            ActivityIndicator.hide(true)
            
            if (error != nil)
            {
                //Display error msg
                let userMessage:String = error!.localizedDescription
                self.displayMessage(userMessage)
            }else {
                //Display success msg
                let userMessage:String = "An email Message was sent to \(emailAddress!)"
                self.displayMessage(userMessage)
                //self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    
    }
    func displayMessage (userMessage:String)
    {
        let myAlert = UIAlertController(title: "Message", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.Default) {
            action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated:true, completion:nil)
    }
    
    @IBAction func Cancel(sender: AnyObject) {
     
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    /*@IBAction func Cancelbutton(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
