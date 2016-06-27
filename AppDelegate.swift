//
//  AppDelegate.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 9/2/15.
//  Copyright (c) 2015 Amal Almansour. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarDelegate{

    var window: UIWindow?

        func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            // [Optional] Power your app with Local Datastore. For more info, go to
            // https://parse.com/docs/ios_guide#localdatastore/iOS
            
            Parse.enableLocalDatastore()
            
            
            // Initialize Parse.
            Parse.setApplicationId("74Tjv0vxYlFfY6ED1Ww4TuzMbEVBPFzafPh9CBm5",
                clientKey: "g5MuUnnC2VENu3ScZjkTPR3zAYMo6rwEfJ4WJsEo")
            
            //enable the session errors
            PFUser.enableRevocableSessionInBackground()
       


            // Override point for customization after application launch.
            
            let userName:String? = NSUserDefaults.standardUserDefaults().stringForKey("user_name")
            
            if(userName != nil)
            {
            
            //Navigate to protected page
                let query: PFQuery = PFUser.query()!
                query.whereKey("email", equalTo: userName!)
                query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
                    if error == nil{
                        for user in objects!{
                            if (user["role"] as! String == "Care Provider"){
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewControllerWithIdentifier("CareProviderTabBarController") as! UITabBarController
                                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.window?.rootViewController = vc}
                            else {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewControllerWithIdentifier("ParentsTabBarController") as! UITabBarController
                                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.window?.rootViewController = vc}
                        }
                    }
                }
                
            }
           
            
                        
           // Changing the Default ACL for security setting..  
            
            //let acl = PFACL()
            //acl.publicReadAccess = true
            //PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
            
            /*PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            
            PFUser.enableRevocableSessionInBackgroundWithBlock({(error: NSError?) in
            
            //enable the session errors
            if (error != nil)
            {
            NSLog(error!.localizedDescription)
            }
            })*/
            //get current user
            //let user: PFUser = PFUser.currentUser()!
            
            return true
        }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}