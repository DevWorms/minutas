//
//  SignUpViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 05/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol SignUpControllerDelegate: NSObjectProtocol {
    
    func signUpControllerDidCancel()
    
    func signUpControllerDidFinishWithInfo(info: [String : String])
    
}

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    weak var delegate: SignUpControllerDelegate?
    
    var togglesInRealTimeSignUpButton = false
    
    var passwordEntered = false
    
    weak var v_currentTextFieldSeparator: UIView!
    
    weak var cnstr_currentTextFieldSeparatorHeight: NSLayoutConstraint!
    
    @IBOutlet
    weak var navigationBar: UINavigationBar!
    
    @IBOutlet
    weak var btn_signUp: UIBarButtonItem!
    
    @IBOutlet
    weak var txtf_name: UITextField!
    
    @IBOutlet
    weak var txtf_lastName: UITextField!
    
    @IBOutlet
    weak var txtf_username: UITextField!
    
    @IBOutlet
    weak var txtf_email: UITextField!
    
    @IBOutlet
    weak var txtf_phone: UITextField!
    
    @IBOutlet
    weak var txtf_password: UITextField!
    
    @IBOutlet
    var form: [UITextField]!
    
    // MARK: Managing the view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn_passwordVisibility = UIButton(type: .system)
        btn_passwordVisibility.addTarget(self, action: #selector(toggleSecureTextEntry(_:)), forControlEvents: .TouchUpInside)
        btn_passwordVisibility.setBackgroundImage(UIImage(named: "ic_eye_off_18pt"), for: .normal)
        btn_passwordVisibility.sizeToFit()
        btn_passwordVisibility.isOpaque = true
        txtf_password.rightView = btn_passwordVisibility
        txtf_password.rightViewMode = .always
    }
    
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField === txtf_password && UIScreen.main.sizeEqualTo3_5Inch() {
            UIView.animate(withDuration: 0.195, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseIn, animations: {
                let v_fullNameContainer = self.txtf_name.superview!.superview!
                v_fullNameContainer.isHidden = true
                v_fullNameContainer.superview!.layoutIfNeeded()
            }, completion: nil)
        }
        
        v_currentTextFieldSeparator = textField.superview!.viewWithTag(textField.tag + 1)!
        cnstr_currentTextFieldSeparatorHeight = v_currentTextFieldSeparator.constraints[0]
        v_currentTextFieldSeparator.backgroundColor = UIColor.white
        cnstr_currentTextFieldSeparatorHeight.constant = 2.0
        
        togglesInRealTimeSignUpButton = checkIfFormIsFullByExcludingField(fieldToExclude: textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if togglesInRealTimeSignUpButton {
            if textField === txtf_password && passwordEntered && txtf_password.secureTextEntry {
                btn_signUp.isEnabled = false
                passwordEntered = false
            }
            
            if string.isEmpty {
                if textField.text!.startIndex.distanceTo(textField.text!.endIndex) - range.length == 0 {
                    btn_signUp.isEnabled = false
                }
            } else if !btn_signUp.isEnabled {
                btn_signUp.isEnabled = true
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField === txtf_password {
            if UIScreen.main.sizeEqualTo3_5Inch() {
                UIView.animate(withDuration: 0.225, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
                    let v_fullNameContainer = self.txtf_name.superview!.superview!
                    v_fullNameContainer.isHidden = false
                    v_fullNameContainer.superview!.layoutIfNeeded()
                }, completion: nil)
            }
            
            if !textField.text!.isEmpty {
                passwordEntered = true
            }
        }
        
        if v_currentTextFieldSeparator != nil {
            v_currentTextFieldSeparator.backgroundColor = UIColor.placeholderColor()
            cnstr_currentTextFieldSeparatorHeight.constant = 1.0
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case txtf_name:
            txtf_lastName.becomeFirstResponder()
        case txtf_lastName:
            txtf_username.becomeFirstResponder()
        case txtf_username:
            txtf_email.becomeFirstResponder()
        case txtf_email:
            txtf_phone.becomeFirstResponder()
        case txtf_phone:
            txtf_password.becomeFirstResponder()
        default:
            txtf_password.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: Actions
    
    func toggleSecureTextEntry(sender: UIButton) {
        txtf_password.secureTextEntry = !txtf_password.secureTextEntry
        sender.setBackgroundImage(UIImage(named: txtf_password.secureTextEntry ? "ic_eye_off_18pt" : "ic_eye_18pt"), for: .Normal)
    }
    
    func checkIfFormIsFullByExcludingField(fieldToExclude: UITextField) -> Bool {
        return form.filter { $0 !== fieldToExclude && $0.text!.isEmpty }.count == 0
    }
    
    @IBAction
    func cancelAccountCreation() {
        delegate?.signUpControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createAccount() {
        let parameterString = "\(WebServiceRequestParameter.name)=\(txtf_name.text!)&\(WebServiceRequestParameter.phone)=\(txtf_phone.text!)&\(WebServiceRequestParameter.email)=\(txtf_email.text!)&\(WebServiceRequestParameter.username)=\(txtf_username.text!)&\(WebServiceRequestParameter.password)=\(txtf_password.text!)"
        
        if let httpBody = parameterString.data(using: String.Encoding.utf8) {
            let urlRequest = NSMutableURLRequest(url: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.signup)")! as URL)
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
            if (urlResponse as! HTTPURLResponse).statusCode == HttpStatusCode.OK {
                print("Registro exitoso.")
                DispatchQueue.main.asynchronously() {
                    self.delegate?.signUpControllerDidFinishWithInfo(info: [WebServiceRequestParameter.email : self.txtf_email.text!, WebServiceRequestParameter.password : self.txtf_password.text!])
                }
            } else {
                DispatchQueue.main.asynchronously() {
                    if let json = try? JSONSerialization.JSONObjectWithData(data! as Data, options: []) {
                        let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                        vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel , handler: nil))
                        self.presentViewController(vc_alert, animated: true, completion: nil)
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
}
