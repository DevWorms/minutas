//
//  NewAsuntosViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol NewAsuntosViewControllerDelegate: NSObjectProtocol {
    func newAsuntoControllerDidCancel()
    func newAsuntoControllerDidFinish()
}

class NewAsuntosViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    weak var delegate: NewAsuntosViewControllerDelegate?
    
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_create: UIBarButtonItem!
    
    @IBOutlet
    weak var txtf_name: UITextField!
    
    @IBOutlet weak var txtf_participantes: UITextField!
    
    @IBOutlet weak var switch_autoasignar: UISwitch!
    // MARK: Responding to view events
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        txtf_name.becomeFirstResponder()
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
        if string.isEmpty {
            if textField.text!.startIndex.distanceTo(textField.text!.endIndex) - range.length == 0 {
                btn_create.enabled = true
            }
        } else if !btn_create.enabled {
            btn_create.enabled = true
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
        delegate?.newAsuntoControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        
        if     !((txtf_name.text?.isEmpty)!)
            && !((txtf_participantes.text?.isEmpty)! && switch_autoasignar.on == false){
            
            if let nombre = txtf_name.text{
                if let asignados = txtf_participantes.text{
                    let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
                    let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
                    let reunionId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.reunionId)
        
                    let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.subPendienteId)=\("null")&\(WebServiceRequestParameter.autoasignar)=\(switch_autoasignar.on)&\(WebServiceRequestParameter.reunionId)=\(reunionId)&\(WebServiceRequestParameter.nombreSubPendiente)=\(nombre)&\(WebServiceRequestParameter.usuariosAsignados)=\(asignados)"
        
                    if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                    let url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.asuntoNuevo)"
                    let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                        urlRequest.HTTPMethod = "POST"
            
                        NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
                   } else {
                        print("Error de codificación de caracteres.")
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
                            self.delegate?.newAsuntoControllerDidFinish()
                        }
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
    }
}
