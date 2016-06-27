//
//  ParentChatMSGViewController.swift
//  Parents-Baby Link
//
//  Created by Amal Almansour on 2/22/16.
//  Copyright © 2016 Amal Almansour. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController
//import MediaPlayer
//import AVKit

class ParentChatMSGViewController: JSQMessagesViewController, UIActionSheetDelegate, UINavigationControllerDelegate, UINavigationBarDelegate {
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var PName:String?
    var ParentID:PFUser?
    
    var chattingWith = false
    
    var timer: NSTimer = NSTimer()
    
    var messageTo = ""
    var messageUser = ""
    
    var PFUserTo = PFUser()
    
    var isLoading: Bool = false
    var users = [PFUser]()
    var Read = [Bool]()
    var Me = [String]()
    
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var blankAvatarImage: JSQMessagesAvatarImage!
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var messages = [JSQMessage]()
    
    var senderImageUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar?.contentView?.leftBarButtonItem?.hidden = true
        // query for object ID
        blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "default-user-icon-profile.png"), diameter: 30)
        isLoading = false
        
        let query: PFQuery = PFUser.query()!
        query.whereKey("first_name", equalTo: self.PName!)
        query.whereKey("objectId", equalTo: self.ParentID!.objectId!)
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            if error == nil{
                for user in objects!{
                    self.PFUserTo = user as! PFUser
                    
                }
            }
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: "loadMessages", userInfo: nil, repeats: false)
        self.senderId = PFUser.currentUser()!.objectId
        self.senderDisplayName = PFUser.currentUser()!["first_name"] as! String
        
        let notRead = PFQuery(className: "Messages2")
        notRead.whereKey("to", equalTo: PFUser.currentUser()!)
        notRead.whereKey("from", equalTo: ParentID!)
        notRead.whereKey("Read", equalTo: false)
        notRead.orderByAscending("createdAt")
        notRead.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) -> Void in
            let User = objects! as [PFObject]
            for objects in User {
                objects["Read"] = true
                objects["Me"] = "Read"
                objects.saveInBackground()
                let read = PFQuery(className: "Messages2")
                read.whereKey("from", equalTo: self.ParentID!)
                read.whereKey("to", equalTo: PFUser.currentUser()!)
                read.whereKey("Read", equalTo: true)
                read.orderByAscending("createdAt")
                read.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                    let User = objects! as [PFObject]
                    for objects in User {
                        
                        objects["Me"] = "Read"
                        objects.saveInBackground()
                    }
                }

            }
        }
        
    } // end view didload
    

    
    override func viewDidAppear(animated: Bool) {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
        reloadMessagesView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView!.collectionViewLayout.springinessEnabled = false
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
        reloadMessagesView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        timer.invalidate()
    }
    
    func reloadMessagesView(){
        
        self.collectionView?.reloadData()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    func loadMessages(){
        if self.isLoading == false{
            self.isLoading = true
            let lastMessage = messages.last
            
            let query = PFQuery(className: "Messages2")
            query.whereKey("from", equalTo: PFUser.currentUser()!)
            query.whereKey("to", equalTo: self.PFUserTo)
            
            
            
            let query1 = PFQuery(className: "Messages2")
            query1.whereKey("from", equalTo: self.PFUserTo)
            query1.whereKey("to", equalTo: PFUser.currentUser()!)
            
            let query2 = PFQuery.orQueryWithSubqueries([query, query1])
            
            if lastMessage != nil {
                
                query2.whereKey("createdAt", greaterThan: (lastMessage?.date)!)
            }
            query2.orderByDescending("createdAt")
            query2.limit = 100
            query2.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.automaticallyScrollsToMostRecentMessage = false
                    
                    for object in Array((objects as [PFObject]!).reverse()){
                        
                        self.addMessage(object)
                    }
                    if objects!.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                    
                } else {
                    
                    self.displayAlert("Network Error", message: "Please try again")
                }
                self.isLoading = false;
                
            }
            
            self.collectionView?.reloadData()
            
            
            /*let query3 = PFQuery(className: "Messages")
            query3.whereKey("from", equalTo: PFUser.currentUser()!)
            query3.whereKey("to", equalTo: self.PFUserTo)
            
            
            
            let query4 = PFQuery(className: "Messages")
            query4.whereKey("from", equalTo: self.PFUserTo)
            query4.whereKey("to", equalTo: PFUser.currentUser()!)
            
            let query5 = PFQuery.orQueryWithSubqueries([query3, query4])
            
            if lastMessage != nil {
                
                query5.whereKey("createdAt", greaterThan: (lastMessage?.date)!)
            }
            query5.orderByDescending("createdAt")
            query5.limit = 100
            query5.findObjectsInBackgroundWithBlock{ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    self.automaticallyScrollsToMostRecentMessage = false
                    
                    for object in Array((objects as [PFObject]!).reverse()){
                        
                        self.addMessage(object)
                    }
                    if objects!.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                    
                } else {
                    
                    self.displayAlert("Network Error", message: "Please try again")
                }
                self.isLoading = false;
                
            }
            
            self.collectionView?.reloadData()*/

        }
        
    }
    
    
    func addMessage(object: PFObject){
        var message: JSQMessage!
        
        let user = object["from"] as! PFUser
        let name = self.PFUserTo["first_name"] as! String
        //print(name)
        message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, text: (object["text"] as? String))
        let read = object["Read"] as! Bool
        let me = object["Me"] as! String
        users.append(user)
        messages.append(message)
        Read.append(read)
        Me.append(me)
    }
    
    func sendMessage(text: String){
        
        let object = PFObject(className: "Messages")
        
        object["to"] = self.PFUserTo
        object["from"] = PFUser.currentUser()!
        object["text"] = text
        object["Username"] = self.PFUserTo["first_name"] as! String
        object["Me"] = "notRead"
        object["Read"] = false
        
        
        object.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.loadMessages()
            } else {
                
                self.displayAlert("Network error", message: "Please try again later")
            }
        }
        self.finishSendingMessage()
    
        
        let object2 = PFObject(className: "Messages2")
        
        object2["to"] = self.PFUserTo
        //print(self.PFUserTo)
        object2["from"] = PFUser.currentUser()!
        object2["text"] = text
        object2["Username"] = self.PFUserTo["first_name"] as! String
        object2["Me"] = "Read"
        object2["Read"] = true

        //PFUser.currentUser()!.addObjectsFromArray([self.PFUserTo.objectId!], forKey: "MessagedUsers")
        //PFUser.currentUser()!.saveInBackground()
        //print("User Saved")
        
        
        object2.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.loadMessages()
            } else {
                
                self.displayAlert("Network error", message: "Please try again later")
            }
        }
        self.finishSendingMessage()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.sendMessage(text)
        self.finishSendingMessage()

    }
    
    // override func didPressAccessoryButton(sender: UIButton!) {
    //let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    //}
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.row]
        if message.senderId == self.senderId{
            return outgoingBubble
        }
        return incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let user = self.users[indexPath.item]
        if self.avatars[user.objectId!] == nil{
            //do {
                 user.fetchIfNeededInBackground()
           // } catch _ {
                //print("There was an error")
           // }
            
            let thumbnailFile = user["profile_picture"] as? PFFile
            thumbnailFile?.getDataInBackgroundWithBlock{ (imageData:NSData?, error:NSError?) -> Void in
                if error == nil {
                    self.avatars[user.objectId! as String] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: imageData!), diameter: 30)
                    self.collectionView!.reloadData()
                }
            }
            return blankAvatarImage
        }
        return self.avatars[user.objectId!]
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0{
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId{
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId{
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // UICollectionView datasource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId{
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    // UICollectionView flow layout
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0{
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId{
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId{
                return 0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    // responding to collection view tap event
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("didTapAvatarImageView")
        //self.performSegueWithIdentifier("back", sender: self)
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("didTapMessageBubbleAtIndexPath")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
    }
    
}



