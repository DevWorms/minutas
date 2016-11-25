//
//  NewCategoryViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 14/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol NewCategoryControllerDelegate: NSObjectProtocol {
    func newCategoryControllerDidCancel()
    func newCategoryControllerDidFinish()
}

class NewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    weak var delegate: NewCategoryControllerDelegate?
    
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_create: UIBarButtonItem!
    
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
            
            if textField.text!.distance(from: textField.text!.startIndex, to:textField.text!.endIndex) - range.length == 0 {
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
        delegate?.newCategoryControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createCategory() {
        let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
        let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
        
        let parameterString = "\(WebServiceRequestParameter.categoryName)=\(txtf_name.text!)&\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)"
        
        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
            let urlRequest = NSMutableURLRequest(url: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.newCategory)")! as URL)
            urlRequest.httpMethod = "POST"
            
            URLSession.sharedSession.uploadTaskWithRequest(urlRequest as URLRequest, fromData: httpBody, completionHandler: parseJson).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
    }
    
    func parseJson(data: NSData?, urlResponse: URLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_get_main_queue().asynchronously() {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.delegate?.newCategoryControllerDidFinish()
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
