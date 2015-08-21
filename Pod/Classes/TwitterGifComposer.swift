//
//  TwitterGifComposer.swift
//  Pods
//
//  Created by Wang Zhenghong on 2015/08/18.
//
//

import UIKit
import Foundation

public protocol TwitterGifComposerDelegate: NSObjectProtocol {
    func onStopPost()
    func onPostSuccessed()
    func onPostFailed()
}

public class TwitterGifComposer: UIWindow, UITextViewDelegate, UIActionSheetDelegate {
    
    let CONTENT_LENGTH_LIMIT = 140
    
    let WIDTH = UIScreen.mainScreen().bounds.size.width - 32 * 2
    let imageViewArea = CGRectMake(8, 48 + 4, UIScreen.mainScreen().bounds.size.width - 32 * 2 - 16, 80)
    
    var twitterPostView = RoundedCornerView(frame: CGRectZero)
    var accountManager = AccountManager.sharedManager
    
    var imageView: UIImageView?
    var textView: UITextView?
    var countLabel: UILabel?
    var delegate: TwitterGifComposerDelegate?
    
    var gifData: NSData?
    var text: String?
    var hasReplacedImageView: Bool = false
    
    public class func defaultComposer(#delegate: TwitterGifComposerDelegate?, rootViewController: UIViewController) -> TwitterGifComposer {
        var composer = TwitterGifComposer(frame: UIScreen.mainScreen().bounds)
        composer.rootViewController = rootViewController
        composer.delegate = delegate
        composer.buildDefaultUI(rootViewController)
        return composer
    }
    
    public func show() {
        if !accountManager.isBuiltInTwitterServiceAvailable() {
            return
        }
        
        if accountManager.hasGotAccounts() {
            self.FillContent()
            self.animateIn(twitterPostView, up: true)
            self.textView!.becomeFirstResponder()
            self.makeKeyAndVisible()
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    self.alpha = 1
                }, completion: nil)
            
        } else {
            assert(self.rootViewController != nil)
            self.buildDefaultUI(self.rootViewController!)
            accountManager.chooseTwitterAccount(parentView: self.rootViewController!.view, actionSheetDelegate: self)
        }
        
    }
    
    public func hide() {
        self.textView?.endEditing(true)
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.alpha = 0
            }, completion: { Bool -> Void in
                var windowCount = UIApplication.sharedApplication().windows.count
                var nextWindow = UIApplication.sharedApplication().windows[windowCount - 2] as! UIWindow
                nextWindow.makeKeyAndVisible()
            })
    }
    
    public func withText(text: String) -> TwitterGifComposer {
        self.text = text
        return self
    }
    
    public func withGifData(data: NSData) -> TwitterGifComposer {
        self.gifData = data
        return self
    }
    
    public func attachFLAnimatedImageView(animatedImageView: UIImageView) {
        if let imageView = self.imageView {
            imageView.removeFromSuperview() // remove static image view from composer
        }
        self.hasReplacedImageView = true
        animatedImageView.frame = self.imageViewArea
        self.twitterPostView.addSubview(animatedImageView)
    }
    
    func animateIn(view: UIView, up: Bool) {
        let movementDistance = view.frame.origin.y / 3 * 2
        let movementDuration = 0.3
        
        var movement = up ? -movementDistance : movementDistance
        var targetFrame = view.frame
        targetFrame.origin.y = targetFrame.origin.y + movement
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                view.frame = targetFrame
        }, completion: nil)
    }
    
    func buildDefaultUI(rootViewController: UIViewController) {
        self.alpha = 0
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.rootViewController = rootViewController
        self.windowLevel = UIWindowLevelAlert
        
        var width = WIDTH
        var startY = UIScreen.mainScreen().bounds.size.height / 2
        
        twitterPostView = RoundedCornerView(frame: CGRectMake(32, startY - 120, width, 120 * 2))
        twitterPostView.fillColor = UIColor.whiteColor()
        self.addSubview(twitterPostView)
        
        var cancelButton = UIButton(frame: CGRectMake(8, 0, 60, 46))
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        cancelButton.addTarget(self, action: Selector("tapTwitterCancelButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        twitterPostView.addSubview(cancelButton)
        
        var titleButton = UIButton(frame: CGRectMake(twitterPostView.frame.width / 2 - 50, 0, 100, 46))
        var username = accountManager.getLastUsedAccountName()
        titleButton.setTitle("Twitter", forState: UIControlState.Normal)
        titleButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        titleButton.addTarget(self, action: Selector("tapTitleButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        twitterPostView.addSubview(titleButton)
        
        var postButton = UIButton(frame: CGRectMake(twitterPostView.frame.width - 8 - 60, 0, 60, 46))
        postButton.setTitle("Post", forState: UIControlState.Normal)
        postButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        postButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        postButton.addTarget(self, action: Selector("tapTwitterPostButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        twitterPostView.addSubview(postButton)
        
        self.imageView = UIImageView(frame: CGRectMake(8, 48 + 4, twitterPostView.frame.width - 16, 80))
        imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        twitterPostView.addSubview(imageView!)
        
        var seperator = UIView(frame: CGRectMake(0, 47, twitterPostView.frame.width, 1))
        seperator.backgroundColor = UIColor.grayColor()
        twitterPostView.addSubview(seperator)
        
        self.textView = UITextView(frame: CGRectMake(8, 48 + 4 + 80 + 4, twitterPostView.frame.width - 16, twitterPostView.frame.height - 48 - 4 - 80 - 4 - 8))
        textView!.font = UIFont.systemFontOfSize(18)
        textView!.text = ""
        textView!.delegate = self
        twitterPostView.addSubview(textView!)
        
        self.countLabel = UILabel(frame: CGRectMake(twitterPostView.frame.width - 32 - 4, twitterPostView.frame.height - 16 - 4, 32, 16))
        countLabel!.font = UIFont.systemFontOfSize(10)
        countLabel!.textColor = UIColor.grayColor()
        countLabel!.text = String(format: "%d", arguments: [count(textView!.text)])
        countLabel!.textAlignment = NSTextAlignment.Right
        twitterPostView.addSubview(countLabel!)
    }
    
    func FillContent() {
        // text content
        if let textView = self.textView {
            textView.text = self.text // fill text content
            if let countLabel = self.countLabel {
                countLabel.text = String(format: "%d", arguments: [count(textView.text)]) // fill counter
            }
        }
        // image content
        if !self.hasReplacedImageView {
            if let imageView = self.imageView {
                imageView.image = UIImage(data: self.gifData!) // this will be a static image
            }
        } else {
            // We have done settings from the caller, so do NOTHING here
        }
    }
    
    func tapTitleButton(sender: UIButton) {
        self.hide()
        accountManager.chooseTwitterAccount(parentView: self.rootViewController!.view, actionSheetDelegate: self)
    }
    
    func tapTwitterCancelButton(sender: UIButton) {
        self.hide()
    }
    
    func tapTwitterPostButton(sender: UIButton) {
        assert(self.gifData != nil)
        accountManager.postTwitterWithGifData(self.gifData!, twitterText: self.textView!.text, onFailBlock: { () -> Void in
            
            }, onSuccessBlock: { () -> Void in
                
            })
    }
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        self.accountManager.handleActionSheetSelection(actionSheet, buttonIndex: buttonIndex,
            onCancelBlock: { () -> Void in
                
            }, onSelectedBlock: { () -> Void in
                self.show()
            } )
    }
    
    public func textViewDidChange(textView: UITextView) {
        if let countLabel = self.countLabel {
            if let textView = self.textView {
                countLabel.text = String(format: "%d", arguments: [count(textView.text)])
            }
        }
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range:NSRange, replacementText text:String ) -> Bool {
        if let textView = self.textView {
            return count(self.textView!.text) + (count(text) - range.length) <= CONTENT_LENGTH_LIMIT;
        }
        return true
    }
}
