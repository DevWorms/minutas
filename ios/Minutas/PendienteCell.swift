//
//  CategoryCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class PendienteCell: GenericCell, HeaderPendienteDelegate {
    
    @IBOutlet weak var tituloPendiente: UILabel!
    @IBOutlet weak var numeroTareasTotal: UILabel!
    @IBOutlet weak var numeroTareasResueltas: UILabel!
    //@IBOutlet weak var inicioDatePicker: UIDatePicker!
    @IBOutlet weak var fechaFin: UILabel!
    @IBOutlet weak var autopostergar: UILabel!
    
    @IBOutlet weak var prioridadLabel: UILabel!
    
    @IBOutlet weak var responsables: UITextView!
    
    @IBOutlet weak var descripcion: UITextView!
    
    @IBOutlet weak var cerrarabrirTarea: UISwitch!
    
    @IBOutlet weak var abrirPopMensajes: UIButton!
    @IBOutlet weak var estatus: UILabel!
    
    @IBOutlet weak var archivos: UILabel!
    @IBOutlet weak var abrirPopComentarios: UIButton!
    @IBOutlet weak var abrirPopCalendario: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
     //  categoriaPicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func attachArchivo(sender: AnyObject) {
        
    }
    
    @IBAction func abrirPopMover(sender: AnyObject) {
        
    }
    
    @IBAction func abrirPopComentarios(sender: AnyObject) {
    }
    
    @IBAction func abrirPopMensajes(sender: AnyObject) {
    }
    
    @IBAction func abrirPopCalendario(sender: AnyObject) {
    }
    
    func toggleSection(header: HeaderPendiente, section: Int) {
       /* let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        tableView.beginUpdates()
        for i in 0 ..< sections[section].items.count {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: section)], withRowAnimation: .Automatic)
        }
        tableView.endUpdates()*/
    }

}
 
