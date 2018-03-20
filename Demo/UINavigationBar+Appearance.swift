//
//  UINavigationBar+Appearance.swift
//  Demo
//
//  Created by Suric on 2018/3/21.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func setBarTranslucent(_ translucent: Bool) {
        if translucent {
            setBackgroundImage(UIImage(), for: .default)
            shadowImage = UIImage()
            self.isTranslucent = true
        } else {
            setBackgroundImage(nil, for: .default)
            shadowImage = nil
            self.isTranslucent = true
        }
    }
    
    func setBarWhite(_ white: Bool) {
        if white {
            setBackgroundImage(#imageLiteral(resourceName: "pixel"), for: .default)
            shadowImage = #imageLiteral(resourceName: "pixel")
            self.isTranslucent = true
        } else {
            setBackgroundImage(nil, for: .default)
            shadowImage = nil
            self.isTranslucent = true
        }
    }
}

extension UIView {
    func setShadow(with color: CGColor? = UIColor.black.cgColor,
                   radius: CGFloat = 2.5,
                   offset: CGSize = CGSize(width: 0, height: -0.5),
                   opacity: Float = 0.17) {
        layer.shadowColor = color
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
    }
    
    func setButtomShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.1
        let rect = CGRect(x: 1, y: 2, width: self.frame.size.width - 2, height: self.frame.size.height)
        layer.shadowPath = CGPath(rect: rect, transform: nil)
    }
}
