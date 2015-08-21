//
//  RoundedGifView.swift
//  AnimeKaomoji
//
//  Created by Wang Zhenghong on 2015/07/14.
//  Copyright (c) 2015年 FAL. All rights reserved.
//

import UIKit
import Foundation

class RoundedCornerView : UIView {
    
    var fillColor = UIColor.whiteColor()
    var borderColor = UIColor.whiteColor()
    var borderWidth: CGFloat = 0.0
    var cornerRadius: CGFloat = 8.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        RoundedCornerViewDrawUtils.drawBorderRounderRect(self.bounds, borderColor: borderColor, fillColor: fillColor, borderWidth: borderWidth, cornerRadius: cornerRadius)
    }
    
}
