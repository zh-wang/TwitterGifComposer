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
    let IMAGE_AREA = CGRectMake(8, 48 + 4, UIScreen.mainScreen().bounds.size.width - 32 * 2 - 16, 80)
    
    let WIDTH = UIScreen.mainScreen().bounds.size.width - 32 * 2
    
    var twitterPostView = RoundedCornerView(frame: CGRectZero)
    var accountManager = AccountManager.sharedManager
    
    var imageView: UIImageView?
    var textView: UITextView?
    var countLabel: UILabel?
    var delegate: TwitterGifComposerDelegate?
    
    var gifData: NSData?
    var text: String?
    var hasReplacedImageView: Bool = false
    
    public class func defaultComposer(delegate delegate: TwitterGifComposerDelegate?, rootViewController: UIViewController) -> TwitterGifComposer {
        let composer = TwitterGifComposer(frame: UIScreen.mainScreen().bounds)
        composer.rootViewController = rootViewController
        composer.delegate = delegate
        composer.buildDefaultUI(rootViewController)
        return composer
    }
    
    public func chooseTwitterAccount() {
        if !accountManager.isBuiltInTwitterServiceAvailable() {
            return
        }
        assert(self.rootViewController != nil)
        accountManager.chooseTwitterAccount(parentView: self.rootViewController!.view, actionSheetDelegate: self)
    }
    
    public func hide() {
        self.textView?.endEditing(true)
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.alpha = 0
            }, completion: { Bool -> Void in
                let windowCount = UIApplication.sharedApplication().windows.count
                let nextWindow = UIApplication.sharedApplication().windows[windowCount - 2] 
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
        animatedImageView.frame = IMAGE_AREA
        self.twitterPostView.addSubview(animatedImageView)
    }
    
    func animateIn(view: UIView, up: Bool) {
        let movementDistance = view.frame.origin.y / 3 * 2
        let movement = up ? -movementDistance : movementDistance
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
        
        let width = WIDTH
        let startY = UIScreen.mainScreen().bounds.size.height / 2
        
        twitterPostView = RoundedCornerView(frame: CGRectMake(32, startY - 120, width, 120 * 2))
        twitterPostView.fillColor = UIColor.whiteColor()
        self.addSubview(twitterPostView)
        
        let cancelButton = UIButton(frame: CGRectMake(8, 0, 60, 46))
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        cancelButton.addTarget(self, action: Selector("tapTwitterCancelButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        twitterPostView.addSubview(cancelButton)
        
        let titleButton = UIButton(frame: CGRectMake(twitterPostView.frame.width / 2 - 50, 0, 100, 46))
        titleButton.setTitle("Twitter", forState: UIControlState.Normal)
        titleButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        titleButton.addTarget(self, action: Selector("tapTitleButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        twitterPostView.addSubview(titleButton)
        
        let postButton = UIButton(frame: CGRectMake(twitterPostView.frame.width - 8 - 60, 0, 60, 46))
        postButton.setTitle("Post", forState: UIControlState.Normal)
        postButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        postButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        postButton.addTarget(self, action: Selector("tapTwitterPostButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        twitterPostView.addSubview(postButton)
        
        self.imageView = UIImageView(frame: IMAGE_AREA)
        imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        twitterPostView.addSubview(imageView!)
        
        let seperator = UIView(frame: CGRectMake(0, 47, twitterPostView.frame.width, 1))
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
        countLabel!.text = String(format: "%d", arguments: [textView!.text.characters.count])
        countLabel!.textAlignment = NSTextAlignment.Right
        twitterPostView.addSubview(countLabel!)
    }
    
    func FillContent() {
        // text content
        if let textView = self.textView {
            textView.text = self.text // fill text content
            if let countLabel = self.countLabel {
                countLabel.text = String(format: "%d", arguments: [textView.text.characters.count]) // fill counter
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
                self.FillContent()
                self.animateIn(self.twitterPostView, up: true)
                self.textView!.becomeFirstResponder()
                self.makeKeyAndVisible()
                
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut,
                    animations: { () -> Void in
                        self.alpha = 1
                    }, completion: nil)
            } )
    }
    
    public func textViewDidChange(textView: UITextView) {
        if let countLabel = self.countLabel {
            if let textView = self.textView {
                countLabel.text = String(format: "%d", arguments: [textView.text.characters.count])
            }
        }
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range:NSRange, replacementText text:String ) -> Bool {
        if let textView = self.textView {
            return textView.text.characters.count + (text.characters.count - range.length) <= CONTENT_LENGTH_LIMIT;
        }
        return true
    }
}
