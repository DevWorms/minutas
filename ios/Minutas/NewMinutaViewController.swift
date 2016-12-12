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
    
    
    @IBOutlet weak var txtfAsuntoMinuta: UITextField!
    
    @IBOutlet weak var txtfAcuerdoMinuta: UITextField!
    
    // MARK: Responding to view events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtfAcuerdoMinuta.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
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
            // if textField.text!.distance(from: textField.text!.startIndex, to: textField.text!.endIndex) - range.length == 0 {
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
        delegate?.newMinutaControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
        let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
        
        let parameterString = "\(WebServiceRequestParameter.categoryName)=\(txtfAcuerdoMinuta.text!)&\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)"
        
        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
            let urlRequest = NSMutableURLRequest(url: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.newCategory)")! as URL)
            urlRequest.httpMethod = "POST"
            
            URLSession.shared.uploadTask(with: urlRequest as URLRequest, from: httpBody, completionHandler: {(data, urlResponse, error) in
                    if error != nil {
                        print(error!)
                    } else if urlResponse != nil {
                        DispatchQueue.main.async( execute:  {
                            
                            do{
                            if let json = try JSonSerialization.jsonObject(with: data!, options:.allowFragments) as? [String:AnyObject]{
                                
                                let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .alert)
                                vc_alert.addAction(UIAlertAction(title: "OK", style: .cancel) { action in
                                    if (urlResponse as! HTTPURLResponse).statusCode == HttpStatusCode.OK {
                                        self.delegate?.newMinutaControllerDidFinish()
                                    }
                                })
                                self.present(vc_alert, animated: true, completion: nil)

                            }else {
                                print("El JSon de respuesta es inválido.")
                            }
                            }catch{
                                print("El JSon de respuesta es inválido.")
                            }
                           
                        })
                    }

            
            }).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
    }
    
   /* func parseJson(data: NSData?, urlResponse: URLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_get_main_queue().asynchronously() {
                if let json = try? JSonSerialization.JSonObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.delegate?.newMinutaControllerDidFinish()
                        }
                        })
                    self.present(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSon de respuesta es inválido.")
                }
            }
        }
    }*/
}
