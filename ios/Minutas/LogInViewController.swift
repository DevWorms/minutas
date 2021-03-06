//
//  LogInViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 04/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import TwitterKit
import FBSDKLoginKit


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
    
    var registrandose = false
    var nombre = ""
    var email = ""
    var nombreUsuario = ""
    // MARK: Managing the view

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apodo = NSUserDefaults.standardUserDefaults().stringForKey(WebServiceResponseKey.apodo)
        
        // Do something with savedValue
        if(apodo != nil && apodo != ""){
            dispatch_async(dispatch_get_main_queue()) {
                
                self.performSegueWithIdentifier("toCategories", sender: nil)
            }
        }else{
        
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
            
            NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.token)
            NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.redSocial)
            
            self.nombre = ""
            self.email = ""
            self.registrandose = false
            
            /*let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.tabBarController = tabBarController
            */
            
            
        }
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
            let destino = (segue.destinationViewController as! SignUpViewController)
            destino.nombre = self.nombre
            destino.email = self.email
            destino.nombreUsuario = self.nombreUsuario
            destino.delegate = self
            
            self.nombre = ""
            self.email = ""
            self.nombreUsuario = ""
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
    
    func signUpWithSocialNetworkControllerDidFinishWithInfo(id:String, redSocial: String) {
        self.registrandose = true
        consultarInicioSesionRedesSociales(id, redSocial: redSocial)
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
    }
    
    @IBAction func loginFb(sender: AnyObject) {
        self.registrandose = false
        let readPermissions : [String]? = ["public_profile","email","user_friends"]
        
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(readPermissions) { (resultado, error) in
           
            if error != nil{
                print(error)
            }else{
                print(resultado.token.tokenString)
                
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
                    let id = FBSDKAccessToken.currentAccessToken().tokenString
                    
                    result.valueForKey("name") as! String
                    result.valueForKey("first_name") as! String
                    result.valueForKey("last_name") as! String
                    
                    self.nombre = result.valueForKey("name") as! String
                    self.email = result.valueForKey("email") as! String
                    NSUserDefaults.standardUserDefaults().setObject(id, forKey: WebServiceResponseKey.token)
                    NSUserDefaults.standardUserDefaults().setObject("fb", forKey: WebServiceResponseKey.redSocial)
                   
                    
                    self.consultarInicioSesionRedesSociales(id, redSocial: "fb")

                }
            })
        }
    }
    
    @IBAction func loginTw(sender: AnyObject) {
        // Swift
        
        self.registrandose = false
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
                    
                    self.consultarInicioSesionRedesSociales(id, redSocial: "tw")
                    
                   
                    
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSON de respuesta es inválido.")
                }

                
            }else{
                print(connectionError?.description)
            }
        })
        
        
    }

    
    @IBAction func logInLinkedIn(sender: AnyObject) {
        //http://stackoverflow.com/questions/28491280/ios-linkedin-authentication
       self.registrandose = false
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
                                self.nombre =  (json["firstName"] as? String)! + " " + (json["lastName"] as? String)!
                                let id = (json["id"] as? String)!
                                NSUserDefaults.standardUserDefaults().setObject(id, forKey: WebServiceResponseKey.token)
                                NSUserDefaults.standardUserDefaults().setObject("in", forKey: WebServiceResponseKey.redSocial)
                            
                                self.consultarInicioSesionRedesSociales(id, redSocial: "in")
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
    
    /**********
     Consumo de apis
    ***/
    
    func consultarInicioSesionRedesSociales(id:String, redSocial: String) {
      
        var apuntarAMetodoWeb  = ""
        switch redSocial {
        case "fb":
            apuntarAMetodoWeb = WebServiceEndpoint.loginWithFb
        case "tw":
            apuntarAMetodoWeb = WebServiceEndpoint.loginWithTw
        case "in":
            apuntarAMetodoWeb = WebServiceEndpoint.loginWithIn
        default:
            apuntarAMetodoWeb = WebServiceEndpoint.loginWithFb
            
        }
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(apuntarAMetodoWeb)\(id)/")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonRedesSociales).resume()
    }
    
    func parseJsonRedesSociales(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let apiKey = json[WebServiceResponseKey.apiKey] as! String
                        
                        NSUserDefaults.standardUserDefaults().setObject(apiKey, forKey: WebServiceResponseKey.apiKey)
                        
                        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.userId] as! Int, forKey: WebServiceResponseKey.userId)
                        
                        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.userId] as! Int, forKey: WebServiceResponseKey.userId)
                        self.loadCargarPerfilUsuario()
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            if self.registrandose {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                            
                            self.registrandose = false
                            self.performSegueWithIdentifier("toCategories", sender: nil)
                            NSUserDefaults.standardUserDefaults().setObject("true", forKey: "login")
                        }
                        
                    }
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSON de respuesta es inválido.")
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                       
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.registrandose == false{
                                self.registrandose = true
                                self.performSegueWithIdentifier("toSignUp", sender: nil)
                                
                            }
                            
                        }
                        
                        NSUserDefaults.standardUserDefaults().setObject("false", forKey: "login")
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    

    
    func loadCargarPerfilUsuario() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.perfil)\(userId)/\(apiKey)")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonPerfilUsuario).resume()
    }
    
    func parseJsonPerfilUsuario(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        let usuario = json[WebServiceResponseKey.user] as! [String : AnyObject]
                        
                        NSUserDefaults.standardUserDefaults().setObject(usuario[WebServiceResponseKey.apodo] as? String, forKey: WebServiceResponseKey.apodo)
                        
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
                        
                        self.loadCargarPerfilUsuario()
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
