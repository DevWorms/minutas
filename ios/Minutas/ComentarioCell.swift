//
//  ComentarioCell.swift
//  Minutas
//
//  Created by Emmanuel Valentín Granados López on 17/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class ComentarioCell: GenericCell {

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if comment != nil {
            self.comment.adjustsFontSizeToFitWidth = true
        }
        if user != nil {
            self.user.adjustsFontSizeToFitWidth = true
        }
        if date != nil {
            self.date.adjustsFontSizeToFitWidth = true
        }
     
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
