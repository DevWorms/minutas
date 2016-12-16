//
//  CategoryCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class PendienteCell: GenericCell, HeaderPendienteDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    var view: UIView!
    
    var contexto: PendienteTableViewController!
    
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
    
    
    // MARK: - UIDocumentMenuDelegate
    func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        contexto.presentViewController(documentPicker, animated: true, completion: nil)
    }

    
    @IBAction func attachArchivo(sender: AnyObject) {
        // https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
        let documentMenu = UIDocumentMenuViewController(documentTypes: [
            "com.adobe.pdf",
            "com.microsoft.word.doc",
            "org.openxmlformats.wordprocessingml.document",
            "com.microsoft.excel.xls",
            "org.openxmlformats.spreadsheetml.sheet",
            "public.png",
            "public.rtf",
            "com.pkware.zip-archive",
            "com.compuserve.gif",
            "public.jpeg"
            ], inMode: UIDocumentPickerMode.Import)
        
        documentMenu.delegate = self
        
        //ipad
        documentMenu.popoverPresentationController?.sourceView = self.view
        
        contexto.presentViewController(documentMenu, animated: true, completion: nil)
        

    }
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        if controller.documentPickerMode == UIDocumentPickerMode.Import {
            
            MyFile.url = url
            
            var fileSize : UInt64 = 0
            
            do {
                let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath( MyFile.Path )
                
                if let _attr = attr {
                    fileSize = _attr.fileSize();
                    
                    print("fileSize: \(fileSize)")
                }
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    

    
    @IBAction func abrirPopMover(sender: AnyObject) {
        let popMensajes = PopMover(nibName: "PopMover", bundle: nil)
        popMensajes.showInView(view)

        
        
    }
    
    @IBAction func abrirPopComentarios(sender: AnyObject) {
        let popComentarios = PopVerComentarios(nibName: "PopVerComentarios", bundle: nil)
        popComentarios.showInView(view, nombre: tituloPendiente.text! )
    }
    
    @IBAction func abrirPopMensajes(sender: AnyObject) {
        let popMensajes = PopViewNuevoComentario(nibName: "PopViewNuevoComentario", bundle: nil)
        popMensajes.showInView(view, nombre: tituloPendiente.text! )

    }
    
    @IBAction func abrirPopCalendario(sender: AnyObject) {
        
        let popCalendario = PopCalendario(nibName: "PopCalendario", bundle: nil)
        
        var dateString = fechaFin.text
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var date = dateFormatter.dateFromString(dateString!)
        
        
        
        popCalendario.showInView(view, fechaTermino: date!)

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
 
