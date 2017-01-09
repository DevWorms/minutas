//
//  NewMinutaViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol NewMinutaViewControllerDelegate: NSObjectProtocol  {
    func newMinutaControllerDidCancel()
    func newMinutaControllerDidFinish()
}

class NewMinutaViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    weak var delegate: NewMinutaViewControllerDelegate?
    
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_create: UIBarButtonItem!
    
    @IBOutlet weak var temalbl: UILabel!
    @IBOutlet weak var fechalbl: UILabel!
    @IBOutlet weak var horalbl: UILabel!
    @IBOutlet weak var objlbl: UILabel!
    @IBOutlet weak var txtfAcuerdoMinuta: UITextField!
    
    var temaMinuta = ""
    var horaMinuta = ""
    var fechaMinuta = ""
    var objMinuta = ""
    var reunionID = ""
    
    // MARK: Responding to view events
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        txtfAcuerdoMinuta.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        temalbl.text = temaMinuta
        fechalbl.text = fechaMinuta
        horalbl.text = horaMinuta
        objlbl.text = objMinuta
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
                btn_create.enabled = false
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
        delegate?.newMinutaControllerDidFinish()
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        if let acuerdo = txtfAcuerdoMinuta.text {
        
            let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.reunionIDq)=\(reunionID)&\(WebServiceRequestParameter.obj_Reunion)=\(objMinuta)&\(WebServiceRequestParameter.acuerdoMinuta)=\(acuerdo)&\(WebServiceRequestParameter.asunto_Minuta)=\(temaMinuta)"
        
            print(parameterString)
        
            if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.newMinute)")!)
                urlRequest.HTTPMethod = "POST"
            
                NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
            } else {
                print("Error de codificación de caracteres.")
            }
        }
        else{
            let vc_alert = UIAlertController(title: "Un momento", message: "Debe llenar todos los campos", preferredStyle: .Alert)
            
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
                            self.delegate?.newMinutaControllerDidFinish()
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
