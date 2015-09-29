//
//  RoundedCornerViewDrawUtils.swift
//  FALKeyboard
//
//  Created by Wang Zhenghong on 2015/06/24.
//  Copyright (c) 2015年 Wang Zhenghong. All rights reserved.
//

import UIKit
import Foundation

class RoundedCornerViewDrawUtils {
    
    class func drawBezierRoundedRect(rect: CGRect, color: UIColor, cornerRadius: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        
        bezierPath.stroke()
        bezierPath.addClip()
        
        color.setFill()
        
        CGPathGetBoundingBox(bezierPath.CGPath)
        CGContextFillPath(context)
        UIRectFill(rect)
    }
    
    class func drawBorderRounderRect(bounds: CGRect, borderColor: UIColor, fillColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(context, borderWidth);
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        let rrect = CGRectInset(bounds, borderWidth, borderWidth)
        
        var radius : CGFloat = cornerRadius;
        let width = CGRectGetWidth(rrect);
        let height = CGRectGetHeight(rrect);
        
        if (radius > width/2.0) {
            radius = width/2.0;
        }
        
        if (radius > height/2.0) {
            radius = height/2.0;
        }
        
        let minx = CGRectGetMinX(rrect);
        let midx = CGRectGetMidX(rrect);
        let maxx = CGRectGetMaxX(rrect);
        let miny = CGRectGetMinY(rrect);
        let midy = CGRectGetMidY(rrect);
        let maxy = CGRectGetMaxY(rrect);
        CGContextMoveToPoint(context, minx, midy);
        CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
        CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
        
        CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
        CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
        CGContextClosePath(context);
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke);
    }
    
}