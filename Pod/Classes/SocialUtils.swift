//
//  SocialUtils.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/08/19.
//
//

import Foundation
import Social
import Accounts

extension String {
    public func contains(other: String) -> Bool {
        return (self as NSString).containsString(other)
    }
}

class AccountManager {

    var gotAccounts: Bool = false
    var localAccounts: [AnyObject] = []
    var lastSelectedIndex: Int = 0
    
    static var sharedManager = AccountManager()
    
    func setGotAccounts() {
        self.gotAccounts = true
    }
    
    func hasGotAccounts() -> Bool {
        return self.gotAccounts
    }
    
    func getLastUsedAccountName() -> String? {
        if self.localAccounts.count == 0 {
            println("AccountManager -> Error: There is no twiiter account in this device.")
            return nil
        }
        println(self.localAccounts.count)
        if self.localAccounts.count <= self.lastSelectedIndex {
            println("AccountManager -> Error: Twitter accounts array index out of bounds")
            return nil
        }
        return self.localAccounts[self.lastSelectedIndex].username
    }
    
    func isBuiltInTwitterServiceAvailable() -> Bool {
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            println("AccountManager -> Error: Device hasn't built-in twitter service. (Running on an emulator?)")
            return false
        }
        return true
    }
    
    /* 
    This needs Social.framework & Accounts.framework & network connection
    */
    func chooseTwitterAccount(#parentView: UIView, actionSheetDelegate: UIActionSheetDelegate) {
        
        if !isBuiltInTwitterServiceAvailable() {
            return
        }
        
        var accountStore = ACAccountStore.new()
        var accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        if !self.gotAccounts {
            accountStore.requestAccessToAccountsWithType(accountType, options: nil,
                completion: { granted, error in
                    if (!granted) {
                        println("AccountManager -> failed, no account granted")
                        return
                    } else {
                        println("AccountManager -> ok, account granted")
                    }
                
                    var accounts = accountStore.accountsWithAccountType(accountType)
                    self.localAccounts = accounts
                    self.gotAccounts = true
                    
                    // return to main loop, choose a Twitter account
                    dispatch_async(dispatch_get_main_queue(), {
                        var actionSheet = UIActionSheet.new()
                        actionSheet.title = "Twitter Account"
                        for account in accounts {
                            actionSheet.addButtonWithTitle(account.username)
                            println(account.username)
                        }
                        actionSheet.addButtonWithTitle("cancel")
                        actionSheet.cancelButtonIndex = accounts.count
                        actionSheet.delegate = actionSheetDelegate
                        actionSheet.showInView(parentView)
                    });
            })
            
        } else {
            // Let user choose a Twitter account
            var actionSheet = UIActionSheet.new()
            actionSheet.title = "Twitter Account"
            for account in self.localAccounts {
                actionSheet.addButtonWithTitle(account.username)
            }
            actionSheet.addButtonWithTitle("cancel")
            actionSheet.cancelButtonIndex = self.localAccounts.count
            actionSheet.delegate = actionSheetDelegate
            actionSheet.showInView(parentView)
        }
    }
    
    func handleActionSheetSelection(actionSheet: UIActionSheet, buttonIndex: Int, onCancelBlock: () -> Void, onSelectedBlock: () -> Void) {
        
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            onCancelBlock()
            return;
        }
        
        self.lastSelectedIndex = buttonIndex
        onSelectedBlock()
    }
    
    func postTwitterWithGifData(data: NSData, twitterText: String, onFailBlock: () -> Void, onSuccessBlock: () -> Void) {
        
        var gifImage = UIImage(data: data)
        
        var account = self.localAccounts[self.lastSelectedIndex] as! ACAccount
        
        var url = NSURL(string: "https://api.twitter.com/1.1/statuses/update_with_media.json")
        var params = ["status": twitterText]
        
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: url, parameters: params)
        
        request.account = account
        request.addMultipartData(data, withName: "media[]", type: "image/gif", filename: "image.gif")
        
        request.performRequestWithHandler() { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if response == nil {
                    println("AccountManager -> twitter no response, error: \(error.debugDescription)")
                    onFailBlock()
                    return
                }
                
                if response.debugDescription.contains("status code: 200") {
                    println("AccountManager -> Post ok")
                    onSuccessBlock()
                } else {
                    println("AccountManager -> Post failed. response: \(response.debugDescription)")
                    onFailBlock()
                }
            })
            
        }
    }

}