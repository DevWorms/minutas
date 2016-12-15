//
//  HeaderPendiente.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 14/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol HeaderPendienteDelegate {
    func toggleSection(header: HeaderPendiente, section: Int)
}

class HeaderPendiente:  UITableViewHeaderFooterView {
    
    var delegate: HeaderPendienteDelegate?
    var section: Int = 0
    
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        //
        // Constraint the size of arrow label for auto layout
        //
        arrowLabel.widthAnchor.constraintEqualToConstant(12).active = true
        arrowLabel.heightAnchor.constraintEqualToConstant(12).active = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowLabel)
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = UIColor(hex: 0x2E3944)
        
        titleLabel.textColor = UIColor.whiteColor()
        arrowLabel.textColor = UIColor.whiteColor()
        
        //
        // Autolayout the lables
        //
        let views = [
            "titleLabel" : titleLabel,
            "arrowLabel" : arrowLabel,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-20-[titleLabel]-[arrowLabel]-20-|",
            options: [],
            metrics: nil,
            views: views
            ))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[titleLabel]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[arrowLabel]-|",
            options: [],
            metrics: nil,
            views: views
            ))
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        arrowLabel.rotate(collapsed ? 0.0 : CGFloat(M_PI_2))
    }
    
}
