//
//  SignUpViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 05/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import TwitterKit
import FBSDKLoginKit

protocol SignUpControllerDelegate: NSObjectProtocol, NSURLSessionDelegate {
    func signUpControllerDidCancel()
    func signUpControllerDidFinishWithInfo(info: [String : String])
    func signUpWithSocialNetworkControllerDidFinishWithInfo(id:String, redSocial: String)
}

class SignUpViewController: UIViewController, UITextFieldDelegate, NSURLSessionDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    
    weak var delegate: SignUpControllerDelegate?
    
    var togglesInRealTimeSignUpButton = false
    
    var passwordEntered = false
    
    weak var v_currentTextFieldSeparator: UIView!
    
    weak var cnstr_currentTextFieldSeparatorHeight: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var btn_signUp: UIBarButtonItem!
    @IBOutlet weak var txtf_confirm_password: UITextField!
    @IBOutlet weak var txtf_name: UITextField!
    @IBOutlet weak var txtf_username: UITextField!
    @IBOutlet weak var txtf_email: UITextField!
    @IBOutlet weak var txtf_phone: UITextField!
    @IBOutlet weak var txtf_password: UITextField!
    
    @IBOutlet weak var pickEmpresas: UIPickerView!
    @IBOutlet weak var codeEmpresa: UITextField!
    @IBOutlet weak var swtEmpresa: UISwitch!
    
    @IBOutlet var form: [UITextField]!
    
    var nombre = ""
    var email = ""
    var nombreUsuario = ""
    
    var pickerData = ["Nombre de la empresa"]
    var pickerDataID = [Int]()
    var nopicke = 0
    
    
    // MARK: Managing the view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickEmpresas.delegate = self
        self.pickEmpresas.dataSource =  self
        
        loadEmp()
        
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
        
        txtf_name.text = nombre
        txtf_email.text = email
        txtf_username.text = nombreUsuario
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: Responding to view events
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //txtf_name.becomeFirstResponder()
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
        
        
       /* let tag = textField.tag
        v_currentTextFieldSeparator = textField.superview!.viewWithTag(tag)!
        cnstr_currentTextFieldSeparatorHeight = v_currentTextFieldSeparator.constraints[0]
        v_currentTextFieldSeparator.backgroundColor = UIColor.whiteColor()
        cnstr_currentTextFieldSeparatorHeight.constant = 2.0
        */
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
        case txtf_phone:
            txtf_email.becomeFirstResponder()
        case txtf_email:
            txtf_username.becomeFirstResponder()
        case txtf_username:
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
        cerrarSesion()
        delegate?.signUpControllerDidCancel()
    }
    
    // MARK: Networking
    
    @IBAction
    func createAccount() {
        
        if     !((txtf_password.text?.isEmpty)!)
            && !((txtf_confirm_password.text?.isEmpty)!)
            && txtf_password?.text == txtf_confirm_password?.text {
            
            
            let token = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.token)! as! String
           
            
            var parameterString = "\(WebServiceRequestParameter.name)=\(txtf_name.text!)&\(WebServiceRequestParameter.phone)=\(txtf_phone.text!)&\(WebServiceRequestParameter.email)=\(txtf_email.text!)&\(WebServiceRequestParameter.username)=\(txtf_username.text!)&\(WebServiceRequestParameter.password)=\(txtf_password.text!)"
            
            if token  != ""{
                parameterString = parameterString + "&\(WebServiceRequestParameter.token)=\(token)"
            }
            
            if self.swtEmpresa.on {
                
                self.nopicke = NSUserDefaults.standardUserDefaults().integerForKey("prioridadSelected")
                
                if !((self.codeEmpresa.text?.isEmpty)!) &&
                    (nopicke != 0) {
                    
                    parameterString = parameterString + "&\("id_empresa")=\(self.pickerDataID[nopicke - 1])&\("codigo_empresa")=\(self.codeEmpresa.text!)"
                    
                } else {
                    let vc_alert = UIAlertController(title: "Un momento", message: "Información de empresa incompleta", preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.Default,
                        handler: nil))
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                    
                    return
                }
            }
            
            print(parameterString)
            
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
        self.cerrarSesion()
        let readPermissions : [String]? = ["public_profile","email","user_friends"]
        
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(readPermissions) { (resultado, error) in
            
            if error != nil{
                print(error)
            }else{
                print(resultado.token)
                
                let fbloginresult : FBSDKLoginManagerLoginResult = resultado
                
                if(fbloginresult.isCancelled) {
                    //Show Cancel alert
                } else if(fbloginresult.grantedPermissions.contains("email")) {
                    self.returnUserData()
                    //fbLoginManager.logOut()
                }
                
            }
            
            
            
            
        }

    }
    
    func returnUserData(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    print(result)
                    result.valueForKey("email") as! String
                    let id = result.valueForKey("id") as! String
                    result.valueForKey("name") as! String
                    result.valueForKey("first_name") as! String
                    result.valueForKey("last_name") as! String
                    
                    self.nombre = result.valueForKey("name") as! String
                    self.email = result.valueForKey("email") as! String
                    NSUserDefaults.standardUserDefaults().setObject(id, forKey: WebServiceResponseKey.token)
                    NSUserDefaults.standardUserDefaults().setObject("fb", forKey: WebServiceResponseKey.redSocial)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.txtf_name.text = self.nombre
                        self.txtf_email.text = self.email
                        self.delegate?.signUpWithSocialNetworkControllerDidFinishWithInfo(id, redSocial: "fb")
                        
                    }
                    
                    
                }
            })
        }
    }
    

    @IBAction func twButton(sender: AnyObject) {
        self.cerrarSesion()
        
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                
                print("signed in as \(session!.userName)");
                
                self.getUserInfo((session?.userID)!)
                
            }
            else {
                print("error: \(error!.localizedDescription)");
            }
            
            
            
            
            
        }
        

    }
    
    func getUserInfo(id : String){
        
        
        // Swift
        let client = TWTRAPIClient(userID: id)
        let request = client.URLRequestWithMethod("GET",
                                                  URL: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                                  parameters: ["include_email": "true", "skip_status": "true"],
                                                  error: nil)
        
        client.sendTwitterRequest(request, completion: { (response, data, connectionError) in
            if connectionError == nil{
                print(data?.description)
                
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    self.nombre =  (json["name"] as? String)!
                    self.nombreUsuario =  (json["screen_name"] as? String)!
                    NSUserDefaults.standardUserDefaults().setObject(id, forKey: WebServiceResponseKey.token)
                    NSUserDefaults.standardUserDefaults().setObject("tw", forKey: WebServiceResponseKey.redSocial)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.txtf_name.text = self.nombre
                        self.txtf_username.text = self.nombreUsuario
                       
                        self.delegate?.signUpWithSocialNetworkControllerDidFinishWithInfo(id, redSocial: "tw")
                        
                    }
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSON de respuesta es inválido.")
                }
                
                
            }else{
                print(connectionError?.description)
            }
        })
        
        
    }

    
    @IBAction func inButton(sender: AnyObject) {
        self.cerrarSesion()
        LISDKSessionManager.createSessionWithAuth([LISDK_EMAILADDRESS_PERMISSION], state: nil, showGoToAppStoreDialog: true, successBlock: {
            (returnState) -> Void in
            print("success called!")
            print(LISDKSessionManager.sharedInstance().session)
            
            let url = "https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address)"
            
            if LISDKSessionManager.hasValidSession() {
                LISDKAPIHelper.sharedInstance().getRequest(url, success: { (response) -> Void in
                    print(response.data)
                    
                    
                    if let dataFromString = response.data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        if let json = try? NSJSONSerialization.JSONObjectWithData(dataFromString, options: []) {
                            print(json.description)
                            self.email =  (json["emailAddress"] as? String)!
                            self.nombre =  (json["firstName"] as? String)! + " " + (json["lastName"]
                                as? String)!
                            let id = (json["id"] as? String)!
                            
                            NSUserDefaults.standardUserDefaults().setObject(id, forKey: WebServiceResponseKey.token)
                            NSUserDefaults.standardUserDefaults().setObject("in", forKey: WebServiceResponseKey.redSocial)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                self.txtf_name.text = self.nombre
                                self.txtf_email.text = self.email
                                self.delegate?.signUpWithSocialNetworkControllerDidFinishWithInfo(id, redSocial:  "in")
                                
                            }
                        }
                        
                    }
                    
                    }, error: { (error) -> Void in
                        print(error!)
                })
            }
            
            }, errorBlock: { (error) -> Void in
                print("Error: \(error)")
        })
    }
    
    func cerrarSesion(){
        
        let redSocial = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.redSocial)! as! String
        
        //Cierra la sesion activa en caso de que exista para poder iniciar sesion con una red social diferente
        switch redSocial {
        case "fb":
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            print("Sesion Cerrada en FB")
            
        case "tw":
            Twitter.sharedInstance().logOut()
            print("Sesion Cerrada en TW")
        case "in":
            LISDKAPIHelper.sharedInstance().cancelCalls()
            LISDKSessionManager.clearSession()
            print("Sesion Cerrada en IN")
        default:
            print("No hay necesidad de cerrar sesión " +  redSocial)
        }
        
        self.nombre = ""
        self.email = ""
        dispatch_async(dispatch_get_main_queue()) {
            
            self.txtf_name.text = ""
            self.txtf_email.text = ""
            self.txtf_username.text = ""
            
        }
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.token)
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.redSocial)
        
    }

    // picker
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSUserDefaults.standardUserDefaults().setObject(row, forKey: "prioridadSelected")
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Arial", size: 12)
            pickerLabel?.textColor = UIColor.whiteColor()
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        pickerLabel?.text = pickerData[row]
        
        return pickerLabel!;
        
    }
    
    func loadEmp() {
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\("empresas/sample/")")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonEmp).resume()
    }
    
    func parseJsonEmp(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    //print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.pickerDataID.count > 0 {
                            self.pickerData.removeAll()
                            self.pickerDataID.removeAll()
                        }
                        
                        if let variable = json["empresas"] as? [[String : AnyObject]] {
                            for empresa in variable {
                                
                                if let nombreEmp = empresa["nombre_empresa"] as? String  {
                                    
                                    self.pickerData.append(nombreEmp)
                                }
                                
                                if let idEmp = empresa["id_empresa"] as? Int  {
                                    
                                    self.pickerDataID.append(idEmp)
                                }
                                
                                
                            }
                        }
                        
                        
                        
                        
                        self.pickEmpresas?.reloadAllComponents()
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
                        NSUserDefaults.standardUserDefaults().setObject("false", forKey: "login")
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
}
