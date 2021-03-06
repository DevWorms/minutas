//
//  NewPendienteController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//


import UIKit

protocol NewPendienteControllerDelegate: NSObjectProtocol {
    func newPendienteControllerDidCancel()
    func newPendienteControllerDidFinish()
}

class NewPendienteViewController: UIViewController, UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var autoasignar: UISwitch!
    weak var delegate: NewPendienteControllerDelegate?
    var tap:UITapGestureRecognizer!
    
    @IBOutlet weak var autopostergarSwitch: UISwitch!
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_create: UIBarButtonItem!
    
    @IBOutlet weak var txtf_descripcion: UITextView!
    @IBOutlet weak var txtf_name: UITextField!
    
    @IBOutlet weak var datePicketFechaTermino: UIDatePicker!
    @IBOutlet weak var txtf_responsable: UITextField!
    
    @IBOutlet weak var opcionesPicker: UIPickerView!
    
    var idRequest = ""
    var idRequested = 0
    var endPointPendiente = ""
    
    let pickerData = ["Selecciona prioridad","Prioridad baja","Prioridad normal","Prioridad alta"]
    
    var usuarios = [String]()
    
    // MARK: Responding to view events
    
    override func viewDidAppear(animated: Bool) {
        
        tableView.delegate = self
        tableView.dataSource = self
        txtf_descripcion.delegate = self;
        
        //self.tableView.allowsSelection = true
        
        super.viewDidAppear(animated)
        txtf_name.becomeFirstResponder()
        
        opcionesPicker.delegate = self
        opcionesPicker.dataSource = self
        
        if tap == nil{
            tap = self.hideKeyboardWhenTappedAround()
        }
        NSUserDefaults.standardUserDefaults().setObject(1, forKey: "prioridadSelected")
        
        
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
        
        
        self.datePicketFechaTermino.minimumDate = minDate
        
        
        self.loadUsuarios("@")
        
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
        
        if textField == self.txtf_responsable{
            
            let arrayResponsables = self.txtf_responsable.text!.componentsSeparatedByString("@")
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
        
        if textField == self.txtf_responsable{
            
            if self.tableView.hidden == true {
                self.tableView.hidden = false
                
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.removeGestureRecognitionText(self.tap)
                self.tap = nil
                self.tableView?.reloadData()
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
        
        if textView == self.txtf_descripcion{
            
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
        delegate?.newPendienteControllerDidCancel()
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Montserrat", size: 16)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        pickerLabel?.text = pickerData[row]
        
        return pickerLabel!;
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        
        let prioridadSelected = NSUserDefaults.standardUserDefaults().valueForKey("prioridadSelected")!
        
        if  ( !((txtf_responsable.text?.isEmpty)!) && autoasignar.on  ||
              (txtf_responsable.text?.isEmpty)! && autoasignar.on  ||
              !((txtf_responsable.text?.isEmpty)!) && autoasignar.on == false )

        
            && !((txtf_descripcion.text?.isEmpty)!)
            && !((txtf_name.text?.isEmpty)!)
            && prioridadSelected as? Int > 0 {
            
        
        
            let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
            //let categoryId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.categoryId)
            
            if let nombereText = txtf_name.text {
                let styler = NSDateFormatter()
                styler.dateFormat = "yyyy-MM-dd"
                let fechaFinal = styler.stringFromDate(datePicketFechaTermino.date)
        
                /*let apodo = NSUserDefaults.standardUserDefaults().stringForKey(WebServiceResponseKey.apodo)
                
                print(apodo)
                return*/
                
                let responsables = txtf_responsable.text!
                var autoasig = 0
                if autoasignar.on {
                    autoasig = 1
                }
                
                   /* if ((txtf_responsable.text?.isEmpty) != nil){
                        responsables = apodo!
                    }else{
                        if txtf_responsable.text![txtf_responsable.text!.endIndex.predecessor()] != ","{
                            responsables = responsables + "," + apodo!
                        }else{
                            responsables = responsables + apodo!
                        }
                    }
                    
                    
                    print(responsables)
                }else{
                    
                    if txtf_responsable.text![txtf_responsable.text!.endIndex.predecessor()] == ","{
                        txtf_responsable.text! = txtf_responsable.text!.substringToIndex(txtf_responsable.text!.endIndex.predecessor())
                        
                    }
                    print(txtf_responsable.text!)
               }*/
                
                var parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteName)=\(nombereText)&\(WebServiceRequestParameter.descripcion)=\(txtf_descripcion.text)&\(WebServiceRequestParameter.autopostergar)=\(Int(autopostergarSwitch.on) )&\(WebServiceRequestParameter.prioridad)=\(prioridadSelected)&\(WebServiceRequestParameter.fechaFin)=\(fechaFinal)&\(WebServiceRequestParameter.responsable)=\(responsables)&\("auto_asignar")=\(autoasig)"
                
                if self.idRequest != "" {
                    parameterString = parameterString + "&\(self.idRequest)=\(self.idRequested)"
                }
                
                if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                    let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(self.endPointPendiente)")!)
                    urlRequest.HTTPMethod = "POST"
            
                    NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody,  completionHandler: parseJson).resume()
                
                } else {
                    print("Error de codificación de caracteres.")
                }
                
            }
            
        }
        else{
            let vc_alert = UIAlertController(title: "Un momento", message: "Debe llenar todos los campos antes de crear un nuevo pendiente", preferredStyle: .Alert)
            
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
                    print(json)
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.delegate?.newPendienteControllerDidFinish()
                        }
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
    }
    
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SearchUsuarioCell
        
        cell.txtNombreUsuario.text = visibleResults[indexPath.item]
        
        /*let json = tareas[indexPath.item]
        
        cell.tituloTarea.text = json[WebServiceResponseKey.nombreSubPendientes] as? String
        cell.tareaCompletaSwitch.on = json[WebServiceResponseKey.pendienteStatus] as! Bool
        // cell.documentosAttachados.text = json[WebServiceResponseKey.fechaInicio] as? String
        */
        return cell
        
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
        
        if visibleResults.count == 0{
            self.tableView.hidden = true
        }
        return visibleResults.count
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var arrayResponsables = self.txtf_responsable.text!.componentsSeparatedByString("@")
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
        
        self.txtf_responsable.text =  responsables + responsable
        
        tableView.hidden = true
        if tap == nil{
            tap = self.hideKeyboardWhenTappedAround()
        }
    }
    
    // para cuadrar las imagenes
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 52
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
