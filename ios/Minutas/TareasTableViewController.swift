//
//  TareasTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class TareasTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewTareaViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var archivos: UILabel!
    @IBOutlet weak var tituloPendiente: UILabel!
    @IBOutlet weak var fechaFin: UILabel!
    @IBOutlet weak var descripcion: UITextView!
    
    @IBOutlet weak var prioridadLabel: UILabel!
    @IBOutlet weak var estatus: UILabel!
    
    @IBOutlet weak var responsables: UITextView!
    @IBOutlet weak var categorias: UIPickerView!
    
    var tareas = [[String : AnyObject]]()
    var pendienteJson = [String : AnyObject]()
    var categories = [[String : AnyObject]]()

    var pickerData = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTareas()
        loadCategories()
        categorias.delegate = self
        categorias.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print(pendienteJson.description)
        
        tituloPendiente.text = pendienteJson[WebServiceResponseKey.nombrePendiente] as? String
        
        fechaFin.text = pendienteJson[WebServiceResponseKey.fechaFin] as? String
        
        if pendienteJson[WebServiceResponseKey.pendienteStatus] as! Bool{
            estatus.text = "Cerrado"
        }
        else{
            estatus.text = "Abierto"
        }
        
        switch pendienteJson[WebServiceResponseKey.prioridad] as! Int {
        case 1:
            prioridadLabel.text = "Prioridad: Baja"
        case 2:
            prioridadLabel.text = "Prioridad: Media"
        case 3:
            prioridadLabel.text = "Prioridad: Alta"
        default:
            prioridadLabel.text = "Prioridad: Media"
        }

        descripcion.text = pendienteJson[WebServiceResponseKey.descripcion] as? String
        
        var responsablesVar = pendienteJson[WebServiceResponseKey.usuariosAsignados] as? String
        
        if responsablesVar == nil || responsablesVar == "" {
            responsablesVar = "No se asigno un responsable"
        }
        
        print(responsablesVar)
        
        responsables.text = responsablesVar
        
        
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        NSUserDefaults.standardUserDefaults().setObject(row, forKey: "prioridadSelected")
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadFile(sender: AnyObject) {
       

    }
   
 
    
    // Make the background color show through
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TareasCell
        
        let json = tareas[indexPath.item]
        
        cell.tituloTarea.text = json[WebServiceResponseKey.nombreSubPendientes] as? String
        cell.tareaCompletaSwitch.on = json[WebServiceResponseKey.pendienteStatus] as! Bool
        cell.responsableTarea.text = json[WebServiceResponseKey.responsable] as? String
        
       // cell.documentosAttachados.text = json[WebServiceResponseKey.fechaInicio] as? String
        
        return cell
        
    }
    
    func newTareaControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newTareaControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadTareas()
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tareas.count
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevoTarea"{
            (segue.destinationViewController as! NewTareaViewController).delegate = self
        }
    }
    
    
    func loadTareas() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        let pendienteId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.pendienteId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.tareas)\(userId)/\(apiKey)/\(pendienteId)")!
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
                        if self.tareas.count > 0 {
                            self.tareas.removeAll()
                        }
                        
                        self.tareas.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
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
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Montserrat", size: 16)
            pickerLabel?.textColor = UIColor.whiteColor()
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        pickerLabel?.text = pickerData[row]
        
        return pickerLabel!;
    }

    
    // para cuadrar las imagenes
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100
    }
    
    func loadCategories() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.categories)\(userId)/\(apiKey)")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonCategorias).resume()
    }
    
    func parseJsonCategorias(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.categories.count > 0 {
                            self.categories.removeAll()
                        }
                        
                        self.categories.appendContentsOf(json[WebServiceResponseKey.categories] as! [[String : AnyObject]])
                        
                        for categoria in self.categories{
                            
                            let strApodo = categoria[WebServiceResponseKey.categoryName] as? String
                            self.pickerData.append(strApodo!)
                            
                        }

                        
                        
                        self.categorias?.reloadAllComponents()
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
                        NSUserDefaults.standardUserDefaults().setObject("false", forKey: "login")
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }

}
