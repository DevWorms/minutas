//
//  NotificacionCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 09/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

import UIKit

class NotificacionCell: GenericCell {
    
    
    @IBOutlet weak var btnDelegar: UIButton!
    @IBOutlet weak var textoNotificacion: UILabel!
    @IBOutlet weak var btnAceptar: UIButton!
    @IBOutlet weak var btnRechazar: UIButton!
    
    var idTarea = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    
    
    @IBAction func btnAceptar(sender: AnyObject) {
        
    }
    
    
    @IBAction func btnDelegar(sender: AnyObject) {
    
    }
}


