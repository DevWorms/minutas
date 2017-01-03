//
//  TareasCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class TareasCell: GenericCell {
  
    @IBOutlet weak var responsableTarea: UILabel!
    @IBOutlet weak var documentosAttachados: UILabel!
    @IBOutlet weak var tituloTarea: UILabel!
    @IBOutlet weak var tareaCompletaSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //  categoriaPicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
    }
   
    @IBAction func asignarUsuario(sender: AnyObject) {
    }
    
    @IBAction func attachButton(sender: AnyObject) {
    }

    
    


}
 
