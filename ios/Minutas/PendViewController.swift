//
//  PendViewController.swift
//  Minutas
//
//  Created by Emmanuel Valentín Granados López on 11/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol PendViewControllerDelegate: NSObjectProtocol  {
    func pendienteDidCancel()
    func pendienteDidFinish()
}

class PendViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: PendViewControllerDelegate?
    
    @IBOutlet weak var archivos: UILabel!
    @IBOutlet weak var tituloPendiente: UILabel!
    @IBOutlet weak var fechaFin: UILabel!
    @IBOutlet weak var descripcion: UITextView!
    @IBOutlet weak var prioridadLabel: UILabel!
    @IBOutlet weak var estatus: UILabel!
    @IBOutlet weak var responsables: UITextView!
    @IBOutlet weak var categorias: UIPickerView!
    
    var pendienteJson = [String : AnyObject]()
    var pickerData = [String]()
    var categories = [[String : AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadCategories()
        
        print("pendienteJson<<<<<")
        
        print(pendienteJson.description)
        
        categorias.delegate = self
        categorias.dataSource = self
        
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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelar(_: AnyObject) {
        delegate?.pendienteDidCancel()
    }
    
    @IBAction func ok(_: AnyObject) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
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
    
    func loadCategories() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.categories)\(userId)/\(apiKey)")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonCategorias).resume()
    }
    
    func parseJsonCategorias(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    //print(json)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
