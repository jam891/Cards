//
//  UIView.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation

extension UIView {
    
    
    @IBInspectable var borderColor: UIColor {
        get {
            return layer.borderColor == nil ? UIColor.clearColor() : UIColor(CGColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    
    // MARK: Shadow
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return layer.shadowColor == nil ? UIColor.clearColor() : UIColor(CGColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.CGColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity:Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    func firstResponder() -> UIView? {
        if self.isFirstResponder() {
            return self
        }
        for subview in subviews {
            let responder = subview.firstResponder()
            if responder != nil {
                return responder
            }
        }
        return nil
    }
}