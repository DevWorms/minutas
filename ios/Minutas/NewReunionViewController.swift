//
//  NewReunionesViewControllerDelegate.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol NewReunionViewControllerDelegate: NSObjectProtocol  {
    func newReunionControllerDidCancel()
    func newReunionControllerDidFinish()
}

class NewReunionViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewAsunto: UITableView!
    
    weak var delegate: NewReunionViewControllerDelegate?
    
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_create: UIBarButtonItem!
    
    @IBOutlet
    weak var txtf_name: UITextField!
    
    @IBOutlet weak var txtf_lugar: UITextField!
    
    @IBOutlet weak var txtf_usuarios: UITextField!
    
    @IBOutlet weak var txtf_objetivos: UITextView!
    
    @IBOutlet weak var datePicker_fecha: UIDatePicker!
    
    @IBOutlet weak var datePicker_duracion: UIDatePicker!
    
    
    var usuarios = [String]()
    var tap:UITapGestureRecognizer!
    
    var noAsunto: Int = 1
    
    
    // MARK: Responding to view events
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableViewAsunto.delegate = self
        self.tableViewAsunto.delegate = self
        
        txtf_objetivos.delegate = self
        
        if tap == nil{
            tap = self.hideKeyboardWhenTappedAround()
        }
        NSUserDefaults.standardUserDefaults().setObject(1, forKey: "prioridadSelected")
        
        txtf_name.becomeFirstResponder()
        //self.hideKeyboardWhenTappedAround()
        btn_create.enabled = true
        
        
        let currentDate: NSDate = NSDate()
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        // let calendar: NSCalendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")!
        
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar
        
        components.year = 0
        components.month = 0
        components.day = 0
        let minDate: NSDate = calendar.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        
        self.datePicker_fecha.minimumDate = minDate
        
        self.loadUsuarios("@")
    }
    
    @IBAction func addAsunto(sender: AnyObject) {
        
        self.noAsunto = self.noAsunto + 1
        self.tableViewAsunto.reloadData()
    }
    
    
    // MARK: Configuring the view's layout behavior
    
    override func viewDidLayoutSubviews() {
        navigationBar.subviews[0].frame = CGRect(x: 0.0, y: -20.0, width: view.bounds.width, height: 64.0)
    }
    
    // MARK: Managing the status bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.txtf_usuarios{
            
            let arrayResponsables = self.txtf_usuarios.text!.componentsSeparatedByString("@")
            let ultimaPalabra = arrayResponsables[arrayResponsables.count-1]
            print("responsable clikeado" + ultimaPalabra)
            if self.tableView.hidden == true {
                self.tableView.hidden = false
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.filterString = ultimaPalabra
                self.tableView?.reloadData()
            }
            
        }
        
        if string.isEmpty {
            if textField.text!.startIndex.distanceTo(textField.text!.endIndex) - range.length == 0 {
                btn_create.enabled = false
            }
        } else if !btn_create.enabled {
            btn_create.enabled = true
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == self.txtf_usuarios{
            
            if self.tableView.hidden == true {
                self.tableView.hidden = false
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                if self.tap != nil{
                    self.removeGestureRecognitionText(self.tap)
                    self.tap = nil
                    self.tableView?.reloadData()
                }
                
            }
            
        }else{
            if tap == nil{
                tap = self.hideKeyboardWhenTappedAround()
            }
            if self.tableView.hidden == false {
                self.tableView.hidden = true
                
            }
        }
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView == self.txtf_objetivos{
            
            if tap == nil{
                tap = self.hideKeyboardWhenTappedAround()
            }
            if self.tableView.hidden == false {
                self.tableView.hidden = true
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Actions
    
    @IBAction
    func cancelPasswordRecovery() {
        delegate?.newReunionControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        
        var asuntos = ""
        var indexPath : NSIndexPath
        //var txtAsunto = ""
        
        for indexAsunto in 0 ... (self.noAsunto-1) {
            
            indexPath = NSIndexPath(forRow: indexAsunto, inSection: 0)
            
            if let cell = self.tableViewAsunto.cellForRowAtIndexPath(indexPath) as? AsuntoReunionCell {
                if let txtAsunto = cell.txtf_asunto.text   {
                    
                    if txtAsunto != "" {
                        asuntos = asuntos + "&\(WebServiceRequestParameter.asuntos)=\(txtAsunto)"
                    }
                    
                }
            }
        }
        
        if     !((txtf_name.text?.isEmpty)!)
            && !((txtf_usuarios.text?.isEmpty)!)
            && !((txtf_lugar.text?.isEmpty)!)
            && !((txtf_objetivos.text?.isEmpty)!)
            && !((asuntos.isEmpty)){
        
            let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
            if let nombereText = txtf_name.text {
                if let lugatTxt = txtf_lugar.text {
                    if let objetivos = txtf_objetivos.text {
                        if let usuarios = txtf_usuarios.text {
                            let styler = NSDateFormatter()
                            styler.dateFormat = "yyyy-MM-dd"
                            let diaReunion = styler.stringFromDate(datePicker_fecha.date)
        
                            let stylerH = NSDateFormatter()
                            stylerH.dateFormat = "HH:mm"
                            let hora = stylerH.stringFromDate(datePicker_duracion.date)
                        
                            let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.nombreReunion)=\(nombereText)&\(WebServiceRequestParameter.usuariosAsignados)=\(usuarios)&\(WebServiceRequestParameter.diaReunion)=\(diaReunion)&\(WebServiceRequestParameter.horaReunion)=\(hora)&\(WebServiceRequestParameter.lugarReunion)=\(lugatTxt)&\(WebServiceRequestParameter.objetivoReunion)=\(objetivos)" + asuntos
                        
                            print(parameterString)
        
                            if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                                let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.newReunion)")!)
                                urlRequest.HTTPMethod = "POST"
            
                                NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
                            } else {
                                print("Error de codificación de caracteres.")
                            }
                        }
                    }
                }
            }
        }
        else{
            let vc_alert = UIAlertController(title: "Un momento", message: "Debe llenar todos los campos antes de agendar una nueva reunion", preferredStyle: .Alert)
            
            vc_alert.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Default,
                handler: nil))
            self.presentViewController(vc_alert, animated: true, completion: nil)
            
        }
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
                            self.delegate?.newReunionControllerDidFinish()
                        }
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SearchUsuarioCell
            
            cell.txtNombreUsuario.text = visibleResults[indexPath.item]
            
            /*let json = tareas[indexPath.item]
             
             cell.tituloTarea.text = json[WebServiceResponseKey.nombreSubPendientes] as? String
             cell.tareaCompletaSwitch.on = json[WebServiceResponseKey.pendienteStatus] as! Bool
             // cell.documentosAttachados.text = json[WebServiceResponseKey.fechaInicio] as? String
             */
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellAsunto", forIndexPath: indexPath)
            return cell
        }
        
        
    }
    
    lazy var visibleResults: [String] = self.usuarios
    
    /// A `nil` / empty filter string means show all results. Otherwise, show only results containing the filter.
    var filterString: String? = nil {
        didSet {
            if filterString == nil || filterString!.isEmpty || self.usuarios.count <= 0 {
                visibleResults = usuarios
            }
            else {
                // Filter the results using a predicate based on the filter string.
                let filterPredicate = NSPredicate(format: "self contains[c] %@", argumentArray: [filterString!.lowercaseString])
                visibleResults = usuarios.filter { filterPredicate.evaluateWithObject($0) }
                
            }
            
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if visibleResults.count == 0{
                self.tableView.hidden = true
            }
            return visibleResults.count
        } else {
            return noAsunto
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.tableView {
            var arrayResponsables = self.txtf_usuarios.text!.componentsSeparatedByString("@")
            print("texto basura " + arrayResponsables.popLast()!)
            
            var responsables = ""
            print(arrayResponsables.description)
            for str in arrayResponsables {
                if(str != ""){
                    responsables = responsables +  "@" + str
                    print(responsables)
                }
            }
            
            let responsable =  visibleResults[indexPath.item] + ", "
            
            self.txtf_usuarios.text =  responsables + responsable
            
            tableView.hidden = true
            if tap == nil{
                tap = self.hideKeyboardWhenTappedAround()
            }
        }
    }

    func loadUsuarios(strUsuario:String) {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let urlStr = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.find)\(userId)/\(apiKey)/\(strUsuario)/"
        print(urlStr)
        let url = NSURL(string: urlStr)!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonUsuarios).resume()
    }
    
    func parseJsonUsuarios(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.usuarios.count > 0 {
                            self.usuarios.removeAll()
                        }
                        
                        let jsonArray = json[WebServiceResponseKey.usuarios] as! [[String : AnyObject]]
                        
                        for jsonItem in jsonArray{
                            
                            let strApodo = jsonItem[WebServiceResponseKey.apodo] as? String
                            self.usuarios.append(strApodo!)
                            
                        }
                        
                        print(self.usuarios.description)
                        
                        
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
