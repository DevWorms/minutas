//
//  CategoryCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit


class CategoryCell: GenericCell {
    
    @IBOutlet weak var tituloPendiente: UILabel!
    @IBOutlet weak var numeroTareasTotal: UILabel!
    @IBOutlet weak var numeroTareasResueltas: UILabel!
    //@IBOutlet weak var inicioDatePicker: UIDatePicker!
    @IBOutlet weak var fechaInicio: UILabel!
    @IBOutlet weak var fechaFin: UILabel!
    
    @IBOutlet weak var autopostergarSwictch: UISwitch!
    @IBOutlet weak var prioridadLabel: UILabel!
    
    @IBOutlet weak var descripcionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     //  categoriaPicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
    }
    
}
 
