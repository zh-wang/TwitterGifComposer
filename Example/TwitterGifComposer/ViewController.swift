//
//  ViewController.swift
//  TwitterGifComposer
//
//  Created by zh-wang on 08/18/2015.
//  Copyright (c) 2015 zh-wang. All rights reserved.
//

import UIKit
import TwitterGifComposer
import FLAnimatedImage

class ViewController: UIViewController, TwitterGifComposerDelegate {
    
    var twitterGifComposer: TwitterGifComposer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onPostFailed() {
        
    }
    
    func onPostSuccessed() {
        
    }
    
    func onStopPost() {
        
    }
    
    @IBAction func touchUpInside(sender: AnyObject) {
        var path = NSBundle.mainBundle().pathForResource("abc", ofType: "gif")
        var data = NSData(contentsOfFile: path!)
        self.twitterGifComposer = TwitterGifComposer.defaultComposer(delegate: self, rootViewController: self).withText("Post Gif").withGifData(data!)
        
        var animatedImageView = FLAnimatedImageView(frame: CGRectZero)
        animatedImageView.animatedImage = FLAnimatedImage(GIFData: data!)
        animatedImageView.startAnimating()
        self.twitterGifComposer!.attachFLAnimatedImageView(animatedImageView)
        
        self.twitterGifComposer!.show()
    }
    
}

