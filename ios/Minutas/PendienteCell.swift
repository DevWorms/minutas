//
//  CategoryCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class PendienteCell: GenericCell {//, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    
  @IBOutlet weak var checkBox: UIButton!
    
  /*  var view: UIView!
    
    var contexto: PendienteTableViewController!
 */
    @IBOutlet weak var viewStatusCerrado: UIView!
    @IBOutlet weak var tituloPendiente: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var btnTareas: UIButton!
    @IBOutlet weak var fecha: UILabel!
    @IBOutlet weak var cateOrPendOrJunta: UILabel!
    
    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    
    let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     //  categoriaPicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    }
    
    // Bool property
    /*var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.checkBox.setImage(checkedImage, forState: .Normal)
                viewStatusCerrado.hidden = false
            } else {
                self.checkBox.setImage(uncheckedImage, forState: .Normal)
                viewStatusCerrado.hidden = true
            }
        }
    }*/
    
    
    @IBAction func checkButton(sender: AnyObject) {
        //isChecked = !isChecked
    }
}
 
