//
//  PBCustomView.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

public class GradientToolbar: UIToolbar {
    
    var gradientView = GradientView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        clipsToBounds = true
        addSubview(gradientView)
        gradientView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        gradientView.colors = [UIColor.blackColor().colorWithAlphaComponent(0.48).CGColor, UIColor.blackColor().colorWithAlphaComponent(0).CGColor]
        gradientView.startPoint = CGPoint(x: 0, y: 1)
        gradientView.endPoint = CGPoint(x: 0, y: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class GradientView: UIView {
    
    var colors: [AnyObject]? {
        get {
            return (layer as! CAGradientLayer).colors
        }
        set {
            (layer as! CAGradientLayer).colors = newValue
        }
    }
    
    var startPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).startPoint
        }
        set {
            (layer as! CAGradientLayer).startPoint = newValue
        }
    }
    
    var endPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).endPoint
        }
        set {
            (layer as! CAGradientLayer).endPoint = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
}
