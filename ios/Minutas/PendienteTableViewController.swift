//
//  CategoryController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 03/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class PendienteTableViewController: UITableViewController, NewPendienteControllerDelegate, HeaderPendienteDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var pendientes = [[String : AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        loadPendiente()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Make the background color show through
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as? HeaderPendiente ?? HeaderPendiente(reuseIdentifier: "header")
        
        
        header.titleLabel.text = "nombre"//sections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(true)
        
        //header.section = section
        header.delegate = self
        
        return header
    }

    
    func toggleSection(header: HeaderPendiente, section: Int) {
        /*let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        tableView.beginUpdates()
        for i in 0 ..< sections[section].items.count {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: section)], withRowAnimation: .Automatic)
        }*/
        tableView.endUpdates()
    }

   

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PendienteCell
        
        let json = pendientes[indexPath.item]
        
        cell.tituloPendiente.text = json[WebServiceResponseKey.nombrePendiente] as? String
        cell.descripcion.text = json[WebServiceResponseKey.descripcion] as? String
        
        cell.fechaFin.text = json[WebServiceResponseKey.fechaFin] as? String
        if json[WebServiceResponseKey.autoPostergar] as! Bool{
            cell.autopostergar.text = "Autopostergar: si"
        }
        else{
            cell.autopostergar.text = "Autopostergar: no"
        }
        switch json[WebServiceResponseKey.prioridad] as! Int {
            case 1:
                cell.prioridadLabel.text = "Prioridad: Baja"
            case 2:
                cell.prioridadLabel.text = "Prioridad: Media"
            case 3:
                cell.prioridadLabel.text = "Prioridad: Alta"
            default:
                cell.prioridadLabel.text = "Prioridad: Media"
        }
        
        cell.responsables.text = json[WebServiceResponseKey.usuariosAsignados] as? String
        cell.cerrarabrirTarea.on = (json[WebServiceResponseKey.statusPendiente] as? Bool)!
        cell.numeroTareasTotal.text = json[WebServiceResponseKey.total] as? String
        cell.numeroTareasResueltas.text = json[WebServiceResponseKey.completados] as? String
        
        if json[WebServiceResponseKey.pendienteStatus] as! Bool{
            cell.estatus.text = "Estatus: Cerrado"
        }
        else{
            cell.estatus.text = "Estatus: Abierto"
        }
        
               
        
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendientes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let json = pendientes[indexPath.item]
        
        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.pendienteId] as! Int, forKey: WebServiceResponseKey.pendienteId)
    }
    
    func newPendienteControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newPendienteControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadPendiente()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevoPendiente"{
            (segue.destinationViewController as! NewPendienteViewController).delegate = self
        }
    }

    
    func loadPendiente() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        let categoryId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.categoryId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.pendientes)\(userId)/\(apiKey)/\(categoryId)")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.pendientes.count > 0 {
                            self.pendientes.removeAll()
                        }
                        
                        self.pendientes.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
                        self.tableView?.reloadData()
                    }
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSON de respuesta es inválido.")
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                        let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                        vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel , handler: nil))
                        self.presentViewController(vc_alert, animated: true, completion: nil)
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
    // para cuadrar las imagenes
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 306
    }
    
    
    
}
