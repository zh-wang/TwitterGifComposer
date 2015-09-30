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
    
    func setGotAccounts(gotAccounts: Bool) {
        self.gotAccounts = gotAccounts
    }

    func hasGotAccounts() -> Bool {
        return self.gotAccounts
    }
    
    func getLastUsedAccountName() -> String? {
        if self.localAccounts.count == 0 {
            print("AccountManager -> Error: There is no twiiter account in this device.", terminator: "")
            return nil
        }
        print(self.localAccounts.count, terminator: "")
        if self.localAccounts.count <= self.lastSelectedIndex {
            print("AccountManager -> Error: Twitter accounts array index out of bounds", terminator: "")
            return nil
        }
        return self.localAccounts[self.lastSelectedIndex].username
    }
    
    func isBuiltInTwitterServiceAvailable() -> Bool {
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            print("AccountManager -> Error: Device hasn't built-in twitter service. (Running on an emulator?)", terminator: "")
            return false
        }
        return true
    }
    
    /* 
    This needs Social.framework & Accounts.framework & network connection
    */
    func chooseTwitterAccount(parentView parentView: UIView, actionSheetDelegate: UIActionSheetDelegate) {
        
        if !isBuiltInTwitterServiceAvailable() {
            return
        }
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        if !self.gotAccounts {
            accountStore.requestAccessToAccountsWithType(accountType, options: nil,
                completion: { granted, error in
                    if (!granted) {
                        print("AccountManager -> failed, no account granted", terminator: "")
                        return
                    } else {
                        print("AccountManager -> ok, account granted", terminator: "")
                    }
                
                    let accounts = accountStore.accountsWithAccountType(accountType)
                    self.localAccounts = accounts
                    self.gotAccounts = true
                    
                    dispatch_async(dispatch_get_main_queue(), { // return to main loop
                        // let user choose a Twitter account
                        let actionSheet = UIActionSheet()
                        actionSheet.title = "Twitter Account"
                        for account in accounts {
                            actionSheet.addButtonWithTitle(account.username)
                            print(account.username, terminator: "")
                        }
                        actionSheet.addButtonWithTitle("cancel")
                        actionSheet.cancelButtonIndex = accounts.count
                        actionSheet.delegate = actionSheetDelegate
                        actionSheet.showInView(parentView)
                    });
            })
            
        } else { // we already pulled accounts to LOCAL, so we fetch them from LOCAL
            let actionSheet = UIActionSheet()
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
        
        let account = self.localAccounts[self.lastSelectedIndex] as! ACAccount
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update_with_media.json")
        let params = ["status": twitterText]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: url, parameters: params)
        
        request.account = account
        request.addMultipartData(data, withName: "media[]", type: "image/gif", filename: "image.gif")
        
        request.performRequestWithHandler() { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if response == nil {
                    print("AccountManager -> twitter no response, error: \(error.debugDescription)", terminator: "")
                    onFailBlock()
                    return
                }
                
                if response.debugDescription.contains("status code: 200") {
                    print("AccountManager -> Post ok", terminator: "")
                    onSuccessBlock()
                } else {
                    print("AccountManager -> Post failed. response: \(response.debugDescription)", terminator: "")
                    onFailBlock()
                }
            })
            
        }
    }

}