
//
//  NewTareaViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol NewTareaViewControllerDelegate: NSObjectProtocol {
    func newTareaControllerDidCancel()
    func newTareaControllerDidFinish()
}

class NewTareaViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    weak var delegate: NewTareaViewControllerDelegate?
    
    @IBOutlet weak var switch_autoasignar: UISwitch!
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_create: UIBarButtonItem!
    
    @IBOutlet weak var txtf_usuarios_asignados: UITextField!
    @IBOutlet
    weak var txtf_name: UITextField!
    
    // MARK: Responding to view events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtf_name.becomeFirstResponder()
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
        delegate?.newTareaControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        
        if     !((txtf_name.text?.isEmpty)!)
            && !((txtf_usuarios_asignados.text?.isEmpty)!){
            
            if let nombre = txtf_name.text{
                if let asignados = txtf_usuarios_asignados.text{
                    let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
                    let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
                    let pendienteId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.pendienteId)
                    
                    let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(pendienteId)&\(WebServiceRequestParameter.autoasignar)=\(Int(switch_autoasignar.isOn))&\(WebServiceRequestParameter.nombreSubPendiente)=\(nombre)&\(WebServiceRequestParameter.usuariosAsignados)=\(asignados)"
                    
                    if let httpBody = parameterString.dataUsingEncoding(String.Encoding.utf8) {
                        let url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.asuntonuevo)"
                        let urlRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                        urlRequest.httpMethod = "POST"
                        
                        URLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
                    } else {
                        print("Error de codificación de caracteres.")
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
                            self.delegate?.newTareaControllerDidFinish()
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
