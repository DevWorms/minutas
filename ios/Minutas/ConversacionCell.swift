
//
//  ConversacionCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 08/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class ConversacionCell: GenericCell {
    
    @IBOutlet weak var tituloChat: UILabel!
    @IBOutlet weak var usuarios: UILabel!
    
    @IBOutlet weak var fechaChat: UILabel!
    @IBOutlet weak var imagenUsuario: UIImageView!
    @IBOutlet weak var conversacion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //  categoriaPicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    }
    
    
    
}

