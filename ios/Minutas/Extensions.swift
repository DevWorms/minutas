//
//  Extensions.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 02/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

extension UIView {
    
    func drawBorderWithColor(color: UIColor, width: CGFloat, cornerRadius: CGFloat = 0.0) {
        layer.borderWidth = width
        layer.borderColor = color.CGColor
        layer.cornerRadius = cornerRadius
    }
    
    func drawRoundedBorder() {
        drawBorderWithColor(backgroundColor ?? tintColor, width: 1.0, cornerRadius: 5.0)
    }
    
    
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    
    class func placeholderColor() -> UIColor {
        return UIColor(red: 0.0, green: 0.0, blue: 25.0/255.0, alpha: 0.22)
    }
    
}

extension UIScreen {
    
    func sizeEqualTo3_5Inch() -> Bool {
        return UIScreen.mainScreen().bounds.height == 480.0
    }
    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
