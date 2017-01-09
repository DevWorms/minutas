//
//  GenericCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit


class GenericCell: UITableViewCell {

    var aparecio = false
    override func layoutSubviews() {
        if aparecio == false{
            let f = contentView.frame
            let fr = UIEdgeInsetsInsetRect(f, UIEdgeInsetsMake(2, 0, 2, 0))
            contentView.frame = fr
            aparecio = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
}

