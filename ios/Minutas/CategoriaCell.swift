//
//  CategoriaCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 13/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

import UIKit

class CategoriaCell: UICollectionViewCell {
    
    @IBOutlet weak var pendientes: UIButton!
    @IBOutlet weak var reunion: UIButton!
    @IBOutlet weak var fecha: UILabel!
    @IBOutlet weak var nombre: UILabel!
    
    let json = [AnyObject]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if nombre != nil {
            nombre.adjustsFontSizeToFitWidth = true
        }
        if fecha != nil{
            fecha.adjustsFontSizeToFitWidth = true
        }
        
        

        //  categoriaPicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    }

    
    @IBAction func reunion(sender: AnyObject) {
        
    }
    
    @IBAction func pendientes(sender: AnyObject) {
      
    }
}

