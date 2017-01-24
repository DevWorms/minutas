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

class PendViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, NewSearchViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    weak var delegate: PendViewControllerDelegate?
    
    @IBOutlet weak var categoriaLbl: UILabel!
    @IBOutlet weak var tituloPendiente: UILabel!
    @IBOutlet weak var fechaFin: UILabel!
    @IBOutlet weak var descripcion: UITextView!
    @IBOutlet weak var prioridadLabel: UILabel!
    @IBOutlet weak var estatus: UILabel!
    @IBOutlet weak var responsables: UITextView!
    @IBOutlet weak var categorias: UIPickerView!
    
    @IBOutlet weak var fechaCambio: UIDatePicker!
    @IBOutlet weak var cambiarFechaBtn: UIButton!
    @IBOutlet weak var addComentario: UIButton!
    @IBOutlet weak var addUser: UIButton!
    @IBOutlet weak var delegarBtn: UIButton!
    
    var pendienteJson = [String : AnyObject]()
    var pickerData = [String]()
    var categoId = [Int]()
    var categories = [[String : AnyObject]]()
    var pendienteIDm = Int()
    var nameCat = String?()
    
    func newConversacionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newConversacionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        //loadFavoritos()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        print("pendienteJson<<<<<")
        
        print(pendienteJson.description)
        
        categorias.delegate = self
        categorias.dataSource = self
        
        let isChecked = pendienteJson[WebServiceResponseKey.statusPendiente] as? Int //
        
        if isChecked == 1 {
            self.fechaCambio.hidden = true
            self.cambiarFechaBtn.hidden = true
            self.addComentario.hidden = true
            self.addUser.hidden = true
            self.delegarBtn.hidden = true
        }
        
        let delegarBool = pendienteJson["is_delegado"] as? Int
        let userBool = pendienteJson["user_id"] as? Int
        if delegarBool == 1 || userBool == NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId) {
            self.delegarBtn.hidden = true
        }
        
        pendienteIDm = pendienteJson[WebServiceResponseKey.pendienteId] as! Int
        
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
        
        responsables.text = responsablesVar

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelar(_: AnyObject) {
        delegate?.pendienteDidCancel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func adjuntarArchivo(sender: AnyObject) {
    }
    
    @IBAction func verComentarios(sender: AnyObject) {
        self.performSegueWithIdentifier("showComentarios", sender: nil)
    }
    
    @IBAction func cambiarCategoria(sender: AnyObject) {
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        let category = NSUserDefaults.standardUserDefaults().integerForKey("prioridadSelected")
        
        
        let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(self.pendienteIDm)&\("id_categoria")=\(categoId[category])"
        
        print(parameterString)
        
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\("pendientes/move")")!)
            urlRequest.HTTPMethod = "POST"
            
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
        } else {
            print("Error de codificación de caracteres.")
        }

    }
    
    @IBAction func cambiarFecha(sender: AnyObject) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        print(dateFormatter.stringFromDate(self.fechaCambio.date))
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(self.pendienteIDm)&\("fecha")=\(dateFormatter.stringFromDate(self.fechaCambio.date))"
            
            print(parameterString)
            
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\("pendientes/set/reprogramar")")!)
                urlRequest.HTTPMethod = "POST"
                
                NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
        } else {
                print("Error de codificación de caracteres.")
        }
        
        //delegate?.pendienteDidCancel()
        
        /*UIView.animateWithDuration(0.4, animations: {
            
            var frame:CGRect = self.fechaCambio.frame
            frame.origin.y = self.view.frame.size.height - 300.0 + 84
            self.fechaCambio.frame = frame
            
        })*/
        
       /* UIView.animateWithDuration(0.4, animations: {
            
            self.fechaCambio.frame = CGRectMake(0.0, 50, 320.0, 300.0)
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            print(dateFormatter.stringFromDate(self.fechaCambio.date))
            
        })*/
    }
    
    @IBAction func agregarComentarios(sender: AnyObject) {
        self.performSegueWithIdentifier("addComment", sender: nil)
    }
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_async(dispatch_get_main_queue()) {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.delegate?.pendienteDidFinish()
                        }
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
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
                
                pickerLabel?.font = UIFont(name: "Arial", size: 12)
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
                            self.categoId.removeAll()
                        }
                        
                        self.categories.appendContentsOf(json[WebServiceResponseKey.categories] as! [[String : AnyObject]])
                        
                        for categoria in self.categories{
                            
                            let strApodo = categoria[WebServiceResponseKey.categoryName] as? String
                            self.pickerData.append(strApodo!)
                            
                            if categoria["id_Categoria"] as? Int == NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.categoryId) {
                                
                                self.categoriaLbl.text = strApodo
                            }
                            
                            self.categoId.append(categoria["id_Categoria"] as! Int)
                            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "asignarPendiente"{
            (segue.destinationViewController as! SearchUserViewController).anadirUsuarioSolamente = 2
            (segue.destinationViewController as! SearchUserViewController).delegate = self
            (segue.destinationViewController as! SearchUserViewController).idAsignar = self.pendienteIDm
            
        }else if segue.identifier == "showComentarios" {
            let vc = segue.destinationViewController as! ComentariosViewController
            
            vc.idPaComentarios = self.pendienteIDm
            vc.endpoint = "pendientes/comments/"
            
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
        }else if segue.identifier == "addComment" {
            let vc = segue.destinationViewController as! AddCommentViewController
            
            vc.idPaComentarios = self.pendienteIDm
            vc.endpoint = "pendientes/comment"
            vc.endpointDos = "id_pendiente"
            
            let controller = vc.popoverPresentationController
            
            if controller != nil {
                controller?.delegate = self
            }
        }else if segue.identifier == "delegarPendiente"{
            (segue.destinationViewController as! SearchUserViewController).anadirUsuarioSolamente = 6
            (segue.destinationViewController as! SearchUserViewController).delegate = self
            (segue.destinationViewController as! SearchUserViewController).idAsignar = self.pendienteIDm
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
