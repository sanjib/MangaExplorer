//
//  SettingsTableViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/20/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var valueForNumberOfMangasInDatabaseLabel: UILabel!
    @IBOutlet weak var tellAFriendTableViewCell: UITableViewCell!
    
    struct TellAFriendMessage {
        static let Body = "Discover new mangas of your choice with the Manga Explorer app. For more details, visit: http://objectcoder.com/manga-explorer"
        static let ErrorTitle = "Cannot Send Message"
        static let ErrorMessage = "Please check your configuration and try again."
    }
    
    struct TellAFriendMail {
        static let Subject = "Manga Explorer app"
        static let Body = "Discover new mangas of your choice with the Manga Explorer app. For more details, visit: <a href=\"http://objectcoder.com/manga-explorer\">http://objectcoder.com/manga-explorer</a>"
        static let ErrorTitle = "Cannot Send Mail"
        static let ErrorMessage = "Please check your mail configuration and try again."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = NSLocale.currentLocale().objectForKey(NSLocaleGroupingSeparator) as! String
        let mangaCount = numberFormatter.stringFromNumber(NSNumber(integer: fetchNumberOfMangasInDatabase()))!
        valueForNumberOfMangasInDatabaseLabel.text = "\(mangaCount)"
    }
    
    // MARK: - Core data
    
    private var sharedContext: NSManagedObjectContext {
        let context = CoreDataStackManager.sharedInstance.managedObjectContext!
        return context
    }
    
    private func fetchNumberOfMangasInDatabase() -> Int {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Manga", inManagedObjectContext: sharedContext)
        fetchRequest.includesSubentities = false

        let error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
        let count = sharedContext.countForFetchRequest(fetchRequest, error: error)
        if error != nil {
            return 0
        }
        return count
    }
    
    // MARK: - Tell a friend
    
    private func tellAFriend(cell: UITableViewCell) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

        let mailAction = UIAlertAction(title: "Mail", style: UIAlertActionStyle.Default) { action in
            if MFMailComposeViewController.canSendMail() {
                self.tellAFriendMail()
            } else {
                self.tellAFriendErrorAlertCannotSendMail()
            }
        }
        let messageAction = UIAlertAction(title: "Message", style: UIAlertActionStyle.Default) { action in
            if MFMessageComposeViewController.canSendText() {
                self.tellAFriendMessage()
            } else {
                self.tellAFriendErrorAlertCannotSendMessage()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { action in
            
        }
        alertController.addAction(mailAction)
        alertController.addAction(messageAction)
        alertController.addAction(cancelAction)
        
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = cell.textLabel
            popover.sourceRect = cell.textLabel!.bounds
            popover.permittedArrowDirections = UIPopoverArrowDirection.Any
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func tellAFriendMail() {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setSubject(TellAFriendMail.Subject)
        mailComposeViewController.setMessageBody(TellAFriendMail.Body, isHTML: true)
        presentViewController(mailComposeViewController, animated: true, completion: nil)
    }
    
    private func tellAFriendErrorAlertCannotSendMail() {
        let sendMailErrorAlert = UIAlertView(title: TellAFriendMail.ErrorTitle, message: TellAFriendMail.ErrorMessage, delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    private func tellAFriendMessage() {
        let messageComposeViewController = MFMessageComposeViewController()
        messageComposeViewController.messageComposeDelegate = self
        messageComposeViewController.body = TellAFriendMessage.Body
        presentViewController(messageComposeViewController, animated: true, completion: nil)
    }
    
    private func tellAFriendErrorAlertCannotSendMessage() {
        let sendMessageErrorAlert = UIAlertView(title: TellAFriendMessage.ErrorTitle, message: TellAFriendMessage.ErrorMessage, delegate: self, cancelButtonTitle: "OK")
        sendMessageErrorAlert.show()
    }
    
    // MARK: - Message UI delegates
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - TableView delegates
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = UIColor.blackColor()
        cell.selectedBackgroundView = backgroundView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell == tellAFriendTableViewCell {
            tellAFriend(cell!)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
