//
//  PasswordRecoveryViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 14/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class PasswordRecoveryViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_recoverPassword: UIBarButtonItem!
    
    @IBOutlet
    weak var txtf_user: UITextField!
    
    // MARK: Responding to view events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtf_user.becomeFirstResponder()
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
                btn_recoverPassword.enabled = false
            }
        } else if !btn_recoverPassword.enabled {
            btn_recoverPassword.enabled = true
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Networking
    
    @IBAction
    func recoverPassword() {
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.recoverPassword)\(txtf_user.text!)")!
        URLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }
    
    func parseJson(data: NSData?, urlResponse: URLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_async(dispatch_get_main_queue()) {
                if let json = try? NSJSonSerialization.JSonObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.dismissViewControllerAnimated(true, completion: nil)
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
