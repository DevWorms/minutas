//
//  BuscadorCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 13/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class BuscadorCell: GenericCell{
    
    @IBOutlet weak var nombreBusqueda: UILabel!
    
    @IBOutlet weak var tipoBusqueda: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if nombreBusqueda != nil{
            nombreBusqueda.adjustsFontSizeToFitWidth = true
        }
        if tipoBusqueda != nil{
            tipoBusqueda.adjustsFontSizeToFitWidth = true
        }
        
    }
    

}
