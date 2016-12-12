//
//  SignUpViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 05/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol SignUpControllerDelegate: NSObjectProtocol, NSURLSessionDelegate {
    
    func signUpControllerDidCancel()
    
    func signUpControllerDidFinishWithInfo(info: [String : String])
    
}

class SignUpViewController: UIViewController, UITextFieldDelegate, NSURLSessionDelegate {
    
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
    
    @IBOutlet weak var txtf_confirm_password: UITextField!
    @IBOutlet weak var txtf_name: UITextField!
    
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
        
        let btn_passwordVisibility = UIButton(type: .System)
        btn_passwordVisibility.addTarget(self, action: #selector(toggleSecureTextEntry(_:)), forControlEvents: .TouchUpInside)
        btn_passwordVisibility.setBackgroundImage(UIImage(named: "ic_eye_off_18pt"), forState: .Normal)
        btn_passwordVisibility.sizeToFit()
        btn_passwordVisibility.opaque = true
        
        let btn_passwordVisibility2 = UIButton(type: .System)
        btn_passwordVisibility2.addTarget(self, action: #selector(toggleSecureTextEntry2(_:)), forControlEvents: .TouchUpInside)
        btn_passwordVisibility2.setBackgroundImage(UIImage(named: "ic_eye_off_18pt"), forState: .Normal)
        btn_passwordVisibility2.sizeToFit()
        btn_passwordVisibility2.opaque = true
        
        txtf_password.rightView = btn_passwordVisibility
        txtf_password.rightViewMode = .Always
        txtf_confirm_password.rightView = btn_passwordVisibility2
        txtf_confirm_password.rightViewMode = .Always
    }
    
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField === txtf_confirm_password && UIScreen.mainScreen().sizeEqualTo3_5Inch() {
            UIView.animateWithDuration(0.195, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseIn, animations: {
                let v_fullNameContainer = self.txtf_phone.superview!.superview!
                v_fullNameContainer.hidden = true
                v_fullNameContainer.superview!.layoutIfNeeded()
            }, completion: nil)
        }
        
        v_currentTextFieldSeparator = textField.superview!.viewWithTag(textField.tag + 1)!
        cnstr_currentTextFieldSeparatorHeight = v_currentTextFieldSeparator.constraints[0]
        v_currentTextFieldSeparator.backgroundColor = UIColor.whiteColor()
        cnstr_currentTextFieldSeparatorHeight.constant = 2.0
        
        togglesInRealTimeSignUpButton = checkIfFormIsFullByExcludingField(textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        if togglesInRealTimeSignUpButton {
            
            
            if textField === txtf_password && passwordEntered && txtf_password.secureTextEntry && txtf_confirm_password.secureTextEntry {
                
                btn_signUp.enabled = false
                passwordEntered = false
            }
            
            if string.isEmpty {
                if textField.text!.startIndex.distanceTo(textField.text!.endIndex) - range.length == 0 {
                    btn_signUp.enabled = false
                }
            } else if !btn_signUp.enabled {
                btn_signUp.enabled = true
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField === txtf_confirm_password {
            if UIScreen.mainScreen().sizeEqualTo3_5Inch() {
                UIView.animateWithDuration(0.225, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: {
                    let v_fullNameContainer = self.txtf_phone.superview!.superview!
                    v_fullNameContainer.hidden = false
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
            txtf_phone.becomeFirstResponder()
        case txtf_username:
            txtf_email.becomeFirstResponder()
        case txtf_email:
            txtf_phone.becomeFirstResponder()
        case txtf_phone:
            txtf_password.becomeFirstResponder()
        case txtf_password:
            txtf_confirm_password.becomeFirstResponder()
        default:
            txtf_password.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: Actions
    
    func toggleSecureTextEntry(sender: UIButton) {
        txtf_password.secureTextEntry = !txtf_password.secureTextEntry
        sender.setBackgroundImage(UIImage(named: txtf_password.secureTextEntry ? "ic_eye_off_18pt" : "ic_eye_18pt"), forState: .Normal)
        
    }
    
    func toggleSecureTextEntry2(sender: UIButton) {
        txtf_confirm_password.secureTextEntry = !txtf_confirm_password.secureTextEntry
        sender.setBackgroundImage(UIImage(named: txtf_confirm_password.secureTextEntry ? "ic_eye_off_18pt" : "ic_eye_18pt"), forState: .Normal)
        
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
        
        if     !((txtf_password.text?.isEmpty)!)
            && !((txtf_confirm_password.text?.isEmpty)!)
            && txtf_password?.text == txtf_confirm_password?.text {
            
            
            let parameterString = "\(WebServiceRequestParameter.name)=\(txtf_name.text!)&\(WebServiceRequestParameter.phone)=\(txtf_phone.text!)&\(WebServiceRequestParameter.email)=\(txtf_email.text!)&\(WebServiceRequestParameter.username)=\(txtf_username.text!)&\(WebServiceRequestParameter.password)=\(txtf_password.text!)"
        
            let strUrl = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.signup)"
            if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: strUrl)!)
            urlRequest.HTTPMethod = "POST"
            
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
            } else {
                print("Error de codificación de caracteres.")
            }
            
        }
        else{
            let vc_alert = UIAlertController(title: "Un momento", message: "Las contraseñas no coinciden", preferredStyle: .Alert)
            
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
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                print("Registro exitoso.")
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.signUpControllerDidFinishWithInfo([WebServiceRequestParameter.email : self.txtf_email.text!, WebServiceRequestParameter.password : self.txtf_password.text!])
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
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
    
    
    @IBAction func fbButton(sender: AnyObject) {
    
    }
    
    @IBAction func twButton(sender: AnyObject) {
        
    }
    
    @IBAction func inButton(sender: AnyObject) {
        
    }
    
}
