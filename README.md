# TwitterGifComposer

[![CI Status](http://img.shields.io/travis/zh-wang/TwitterGifComposer.svg?style=flat)](https://travis-ci.org/zh-wang/TwitterGifComposer)
[![Version](https://img.shields.io/cocoapods/v/TwitterGifComposer.svg?style=flat)](http://cocoapods.org/pods/TwitterGifComposer)
[![License](https://img.shields.io/cocoapods/l/TwitterGifComposer.svg?style=flat)](http://cocoapods.org/pods/TwitterGifComposer)
[![Platform](https://img.shields.io/cocoapods/p/TwitterGifComposer.svg?style=flat)](http://cocoapods.org/pods/TwitterGifComposer)

## Usage

Native iOS twitter composer does NOT support gif. This composer will help if you need to post gifs.

Although this project does NOT rely on [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage), but it can do better with it.

        class ViewController: UIViewController, TwitterGifComposerDelegate {

        /* ... */

        @IBAction func touchUpInside(sender: AnyObject) {

            var path = NSBundle.mainBundle().pathForResource("abc", ofType: "gif")
            var data = NSData(contentsOfFile: path!)
            self.twitterGifComposer = TwitterGifComposer.defaultComposer(delegate: self, rootViewController: self).withText("Post Gif").withGifData(data!)

            /*
                The image view in composer only show static image, by default.
                But if FLAnimatedImage is also imported, you can replace it as FLAnimatedImageView
            */
            var animatedImageView = FLAnimatedImageView(frame: CGRectZero)
            animatedImageView.animatedImage = FLAnimatedImage(GIFData: data!)
            animatedImageView.startAnimating()
            self.twitterGifComposer!.attachFLAnimatedImageView(animatedImageView)

            /* show the composer */
            self.twitterGifComposer!.show()

        }

        func onPostFailed() { }

        func onPostSuccessed() { }

        func onStopPost() { }

![alt tag](http://i.imgur.com/S5Il9FE.png)

## Requirements

iOS 8.0

## Installation

TwitterGifComposer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TwitterGifComposer"
```

## Author

zh-wang, viennakanon@gmail.com

## License

TwitterGifComposer is available under the MIT license. See the LICENSE file for more info.
