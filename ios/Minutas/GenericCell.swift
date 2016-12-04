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

    override func layoutSubviews() {
        let f = contentView.frame
        let fr = UIEdgeInsetsInsetRect(f, UIEdgeInsetsMake(5, 0, 5, 0))
        contentView.frame = fr
    }
}
    
