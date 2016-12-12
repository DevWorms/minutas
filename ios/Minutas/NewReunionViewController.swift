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

class NewReunionViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    weak var delegate: NewReunionViewControllerDelegate?
    
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_create: UIBarButtonItem!
    
    @IBOutlet
    weak var txtf_name: UITextField!
    
    @IBOutlet weak var txtf_lugar: UITextField!
    
    @IBOutlet weak var txtf_usuarios: UITextField!
    
    @IBOutlet weak var txtf_objetivos: UITextField!
    
    @IBOutlet weak var datePicker_fecha: UIDatePicker!
    
    @IBOutlet weak var datePicker_duracion: UIDatePicker!
    
    
    // MARK: Responding to view events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtf_name.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
        btn_create.isEnabled = true
        
        
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
        
        
        self.datePicker_fecha.minimumDate = minDate as Date
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
        delegate?.newReunionControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        
        
        if     !((txtf_name.text?.isEmpty)!)
            && !((txtf_usuarios.text?.isEmpty)!)
            && !((txtf_lugar.text?.isEmpty)!)
            && !((txtf_objetivos.text?.isEmpty)!){
        
            let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
            let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
            if let nombereText = txtf_name.text {
                if let lugatTxt = txtf_lugar.text {
                    if let objetivos = txtf_objetivos.text {
                        let styler = DateFormatter()
                        styler.dateFormat = "yyyy-MM-dd"
                        let diaReunion = styler.string(from: datePicker_fecha.date)
        
                        let stylerH = DateFormatter()
                        stylerH.dateFormat = "HH:mm"
                        let hora = stylerH.string(from: datePicker_duracion.date)

            
                        let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.nombreReunion)=\(txtf_name.text!)&\(WebServiceRequestParameter.usuariosAsignados)=\(nombereText)&\(WebServiceRequestParameter.diaReunion)=\(diaReunion)&\(WebServiceRequestParameter.horaReunion)=\(hora)&\(WebServiceRequestParameter.lugarReunion)=\(lugatTxt)&\(WebServiceRequestParameter.objetivoReunion)=\(objetivos)"
        
                        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
                            let urlRequest = NSMutableURLRequest(url: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.newReunion)")! as URL)
                        urlRequest.httpMethod = "POST"
            
                            URLSession.sharedSession.uploadTaskWithRequest(urlRequest as URLRequest, fromData: httpBody, completionHandler: parseJson).resume()
                        } else {
                            print("Error de codificación de caracteres.")
                        }
                    }
                }
            }
        }
        else{
            let vc_alert = UIAlertController(title: "Un momento", message: "Debe llenar todos los campos antes de agendar una nueva reunion", preferredStyle: .alert)
            
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
                            self.delegate?.newReunionControllerDidFinish()
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
