//
//  PendientesHeader.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 14/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

//
//  CollapsibleTableViewHeader.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 12/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

protocol PendientesHeaderViewHeaderDelegate {
    func toggleSection(header: PendientesHeader, section: Int)
}

class PendientesHeader: UITableViewHeaderFooterView {
    
    var delegate: PendientesHeaderViewHeaderDelegate?
    var section: Int = 0
    
    let tituloPendiente = UILabel()
    let fechaTermino = UILabel()
    let arrowLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        //
        // Constraint the size of arrow label for auto layout
        //
        arrowLabel.widthAnchor.constraintEqualToConstant(12).active = true
        arrowLabel.heightAnchor.constraintEqualToConstant(12).active = true
        
        tituloPendiente.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(tituloPendiente)
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
        
        tituloPendiente.textColor = UIColor.whiteColor()
        arrowLabel.textColor = UIColor.whiteColor()
        
        //
        // Autolayout the lables
        //
        let views = [
            "tituloPendiente" : tituloPendiente,
            "arrowLabel" : arrowLabel,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-20-[tituloPendiente]-[arrowLabel]-20-|",
            options: [],
            metrics: nil,
            views: views
        ))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[tituloPendiente]-|",
            options: [],
            metrics: nil,
            views: views
        ))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[tituloPendiente]-|",
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
