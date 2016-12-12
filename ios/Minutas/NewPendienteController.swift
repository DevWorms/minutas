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

class NewPendienteViewController: UIViewController, UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    
    weak var delegate: NewPendienteControllerDelegate?
    
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
    
    
    
    let pickerData = ["Selecciona prioridad","Prioridad baja","Prioridad normal","Prioridad alta"]
    
    
    // MARK: Responding to view events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtf_name.becomeFirstResponder()
        
        opcionesPicker.delegate = self
        opcionesPicker.dataSource = self
        
         self.hideKeyboardWhenTappedAround()
        UserDefaults.standard.set(1, forKey: "prioridadSelected")
        
        
        let currentDate: NSDate = NSDate()
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        // let calendar: NSCalendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar as Calendar
        
        components.year = 0
        components.month = 0
        components.day = 0
        let minDate: NSDate = calendar.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        
        self.datePicketFechaTermino.minimumDate = minDate as Date
        
        
        
        
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        UserDefaults.standard.set(row, forKey: "prioridadSelected")
    }
    
    // MARK: Configuring the view's layout behavior
    
    override func viewDidLayoutSubviews() {
        navigationBar.subviews[0].frame = CGRect(x: 0.0, y: -20.0, width: view.bounds.width, height: 64.0)
    }
    
    // MARK: Managing the status bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
             if textField.text!.distance(from: textField.text!.startIndex, to: textField.text!.endIndex) - range.length == 0 {
                btn_create.isEnabled = false
            }
        } else if !btn_create.isEnabled {
            btn_create.isEnabled = true
        }
        
        return true
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
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        
        let prioridadSelected = UserDefaults.standard.value(forKey: "prioridadSelected")!
        
        
        if     !((txtf_responsable.text?.isEmpty)!)
            && !((txtf_descripcion.text?.isEmpty)!)
            && !((txtf_name.text?.isEmpty)!)
            && (prioridadSelected as? Int)! > 0{
            
        
        
            let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
            let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
            let categoryId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.categoryId)
            
            if let nombereText = txtf_name.text {
                print(nombereText)
                let styler = DateFormatter()
                styler.dateFormat = "yyyy-MM-dd"
                let fechaFinal = styler.string(from: datePicketFechaTermino.date)
        
        
                let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.categoryId)=\(categoryId)&\(WebServiceRequestParameter.pendienteName)=\(nombereText)&\(WebServiceRequestParameter.descripcion)=\(txtf_descripcion.text)&\(WebServiceRequestParameter.autopostergar)=\(Int(autopostergarSwitch.isOn) )&\(WebServiceRequestParameter.prioridad)=\(prioridadSelected)&\(WebServiceRequestParameter.fechaFin)=\(fechaFinal)&\(WebServiceRequestParameter.responsable)=\(txtf_responsable.text!)"
        
                if let httpBody = parameterString.dataUsingEncoding(String.Encoding.utf8) {
                    let urlRequest = NSMutableURLRequest(url: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.newPendiente)")! as URL)
                    urlRequest.httpMethod = "POST"
            
                    URLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody,  completionHandler: parseJson).resume()
                
                } else {
                    print("Error de codificación de caracteres.")
                }
                
            }
            
        }
        else{
            let vc_alert = UIAlertController(title: "Un momento", message: "Debe llenar todos los campos antes de crear un nuevo pendiente", preferredStyle: .alert)
            
            vc_alert.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil))
            self.present(vc_alert, animated: true, completion: nil)
            
        }
    }
    
    func parseJson(data: NSData?, urlResponse: URLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_get_main_queue().asynchronously() {
                if let json = try? JSonSerialization.JSonObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.delegate?.newPendienteControllerDidFinish()
                        }
                        })
                    self.present(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSon de respuesta es inválido.")
                }
            }
        }
    }
}
