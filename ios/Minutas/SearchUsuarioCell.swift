//
//  SearchUsuarioCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 02/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class SearchUsuarioCell: GenericCell {
    
    @IBOutlet weak var imgUsuario: UIImageView!
    @IBOutlet weak var txtNombreUsuario: UILabel!
    var caminoFav = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
 

    @IBOutlet weak var a: UIButton!
    let checkedImage = UIImage(named: "checkFav")! as UIImage
    
    let uncheckedImage = UIImage(named: "favorito")! as UIImage
    // Bool property
    var isChecked: Bool = true {
        didSet{
            if isChecked == true {
                self.a.setImage(checkedImage, forState: .Normal)
               
            } else {
                self.a.setImage(uncheckedImage, forState: .Normal)
        
            }
        }
    }

    @IBAction func checkFav(sender: AnyObject) {
        isChecked = !isChecked
    }
}
