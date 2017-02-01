//
//  IndiceEficienciaTopCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 12/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation


class IndiceEficienciaTopCell: UITableViewCell{
    
    
    @IBOutlet weak var nombreLabel: UILabel!
    
    @IBOutlet weak var numeroPendientesLabel: UILabel!
    @IBOutlet weak var incumplimiento: UILabel!
    @IBOutlet weak var numeroDiasAtrasoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if numeroPendientesLabel != nil{
            numeroPendientesLabel.adjustsFontSizeToFitWidth = true
        }
        if incumplimiento != nil{
            incumplimiento.adjustsFontSizeToFitWidth = true
        }
        if numeroDiasAtrasoLabel != nil{
            numeroDiasAtrasoLabel.adjustsFontSizeToFitWidth = true
        }
        
    }
}
