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
    
    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.addAnimation(animation, forKey: nil)
    }

    
    
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

extension UIViewController {
    
    
    
    func hideKeyboardWhenTappedAround() -> UITapGestureRecognizer{
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        return tap
    }
    
    func removeGestureRecognitionText(tap: UITapGestureRecognizer) {
        view.removeGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    
    
    convenience init(hex:Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
    
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

extension CollapsibleTableViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        tableView.beginUpdates()
        for i in 0 ..< sections[section].items.count {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: section)], withRowAnimation: .Automatic)
        }
        tableView.endUpdates()
    }
    
}

extension CalendarioCell: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        subMenuTable!.beginUpdates()
        for i in 0 ..< sections[section].items.count {
            subMenuTable!.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: section)], withRowAnimation: .Automatic)
        }
        subMenuTable!.endUpdates()
    }
    
}
