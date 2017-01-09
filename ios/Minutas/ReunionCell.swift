//
//  ReunionCell.swift
//  Minutas
//
//  Created by Emmanuel Valentín Granados López on 08/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class ReunionCell: GenericCell {

    @IBOutlet weak var tituloReunion: UILabel!
    @IBOutlet weak var reunionComplete: UISwitch!
    @IBOutlet weak var fechaReunion: UILabel!
    @IBOutlet weak var invitados: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
