//
//  LogInViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 04/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate, SignUpControllerDelegate {
    
    // MARK: Properties
    
    var togglesInRealTimeLogInButton = false
    
    var passwordEntered = false
    
    @IBOutlet
    weak var txtf_user: UITextField!
    
    @IBOutlet
    weak var txtf_password: UITextField!
    
    @IBOutlet
    weak var btn_logIn: UIButton!
    
    @IBOutlet
    weak var btn_signUp: UIButton!
    
    // MARK: Managing the view

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imgv_account = UIImageView(image: UIImage(named: "ic_account_18pt"))
        imgv_account.contentMode = .ScaleAspectFit
        imgv_account.bounds.size.width += 8.0
        imgv_account.opaque = true
        txtf_user.leftView = imgv_account
        txtf_user.leftViewMode = .Always
        
        let imgv_lock = UIImageView(image: UIImage(named: "ic_lock_18pt"))
        imgv_lock.contentMode = .ScaleAspectFit
        imgv_lock.bounds.size.width += 8.0
        imgv_lock.opaque = true
        txtf_password.leftView = imgv_lock
        txtf_password.leftViewMode = .Always
        
        let btn_passwordVisibility = UIButton(type: .System)
        btn_passwordVisibility.addTarget(self, action: #selector(toggleSecureTextEntry(_:)), forControlEvents: .TouchUpInside)
        btn_passwordVisibility.setBackgroundImage(UIImage(named: "ic_eye_off_18pt"), forState: .Normal)
        btn_passwordVisibility.sizeToFit()
        btn_passwordVisibility.opaque = true
        txtf_password.rightView = btn_passwordVisibility
        txtf_password.rightViewMode = .Always
        
        btn_logIn.drawRoundedBorder()
        btn_signUp.drawRoundedBorder()
    }
    
    // MARK: Managing the status bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toSignUp" {
            (segue.destinationViewController as! SignUpViewController).delegate = self
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField === txtf_user {
            togglesInRealTimeLogInButton = !txtf_password.text!.isEmpty
        } else {
            togglesInRealTimeLogInButton = !txtf_user.text!.isEmpty
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if togglesInRealTimeLogInButton {
            if textField === txtf_password && passwordEntered && txtf_password.secureTextEntry {
                btn_logIn.enabled = false
                passwordEntered = false
            }
            
            if string.isEmpty {
                if textField.text!.startIndex.distanceTo(textField.text!.endIndex) - range.length == 0 {
                    btn_logIn.enabled = false
                }
            } else if !btn_logIn.enabled {
                btn_logIn.enabled = true
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === txtf_user {
            txtf_password.becomeFirstResponder()
        } else {
            txtf_password.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField === txtf_password && !textField.text!.isEmpty {
            passwordEntered = true
        }
    }
    
    // SignUpControllerDelegate
    
    func signUpControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpControllerDidFinishWithInfo(info: [String : String]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        txtf_user.text = info[WebServiceRequestParameter.email]
        txtf_password.text = info[WebServiceRequestParameter.password]
        logIn()
    }
    
    // MARK: Actions
    
    func toggleSecureTextEntry(sender: UIButton) {
        txtf_password.secureTextEntry = !txtf_password.secureTextEntry
        sender.setBackgroundImage(UIImage(named: txtf_password.secureTextEntry ? "ic_eye_off_18pt" : "ic_eye_18pt"), forState: .Normal)
    }
    
    // MARK: Networking
    
    @IBAction
    func logIn() {
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.login)\(txtf_user.text!)/\(txtf_password.text!)")!
       
        httpGet(NSMutableURLRequest(URL: url))
       /* var session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()*/
    }
    
    func httpGet(request: NSMutableURLRequest!) {
        let configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue:NSOperationQueue.mainQueue())
        
        let task = session.dataTaskWithRequest(request){
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                let result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                
                self.parseJson(data, urlResponse: response, error: error)
                NSLog("result %@", result)
            }
        }
        task.resume()
    }
    
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didReceiveChallenge challenge: NSURLAuthenticationChallenge,
                                        completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?)
        -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    NSUserDefaults.standardUserDefaults().setValue(json[WebServiceResponseKey.apiKey] as! String, forKey: WebServiceResponseKey.apiKey)
                    NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.userId] as! Int, forKey: WebServiceResponseKey.userId)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("toCategories", sender: nil)
                    }
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSON de respuesta es inválido.")
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
    
}
