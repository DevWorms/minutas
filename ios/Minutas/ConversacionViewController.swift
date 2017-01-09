//
//  ConversacionViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 08/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//
import UIKit

class ConversacionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    @IBOutlet weak var bottonConstrintButton: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtfmensaje: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var conversacion = [[String : AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadConversacion()
        self.hideKeyboardWhenTappedAround()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height - 40
            self.bottonConstrintButton.constant = keyboardFrame.size.height - 40
            
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = 5
            self.bottonConstrintButton.constant = 5
            
        })
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadFile(sender: AnyObject) {
        
        
    }
    
    
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ConversacionCell
        
        let json = conversacion[indexPath.item]
        
        let jsonMiembro = json[WebServiceResponseKey.miembro] as? [String : AnyObject]
        
        print(jsonMiembro?.description)
       
        cell.usuarios.text = jsonMiembro![WebServiceResponseKey.apodo] as? String
        
        
        cell.fechaChat.text = json[WebServiceResponseKey.elaborado] as? String
        
        cell.conversacion.text = json[WebServiceResponseKey.texto] as? String
        
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        if let idDeUsuarioQueMandaElMensaje = jsonMiembro![WebServiceResponseKey.id] as? Int {
            if idDeUsuarioQueMandaElMensaje != userId
            {
                let str = "Id del usuario que mensajea: " + "\(idDeUsuarioQueMandaElMensaje)" + " Id del usuario    acutual: " + "\(userId)" + " el mensaje es: "
                
                print(str + cell.conversacion.text!)
                
                cell.imagenDeUsuarioConstraint.constant = 5
                cell.usuarios.textAlignment = .Left
                cell.fechaChat.textAlignment = .Left
                cell.conversacion.textAlignment = .Left
                
                return cell
            }else{
                print("Id del usuario que mensajea: " + "\(idDeUsuarioQueMandaElMensaje)" + " Id del usuario    acutual: " + "\(userId)")
                
                return cell
            }
        }else{
            print("El idDeUsuarioQueMandaElMensaje fue nil")
            return cell
        }
        
        
    }
    
    func newTareaControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newTareaControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadConversacion()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversacion.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevoTarea"{
            
        }
    }
    
    
    func loadConversacion() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        let conversacionId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.conversacionId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversaciones)\(userId)/\(apiKey)/\(conversacionId)/")!
        print(url)
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.conversacion.count > 0 {
                            self.conversacion.removeAll()
                        }
                        
                        self.conversacion.appendContentsOf(json[WebServiceResponseKey.mensajes] as! [[String : AnyObject]])
                        self.tableView?.reloadData()
                    }
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSON de respuesta es inválido.")
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if let _ = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                        self.txtfmensaje.text = ""
                        self.loadConversacion()
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
    
    
    
    // para cuadrar las imagenes
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 86
    }
    
    
    //Mandar un mensaje
    
    @IBAction func btnSendButton(sender: AnyObject) {
        
        if let texto = txtfmensaje.text {
            
            let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
            let conversacionId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.conversacionId)
                    
            let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.texto)=\(texto)"
            
            print(parameterString)
                    
            if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                let url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversaciones)\(conversacionId)\(WebServiceEndpoint.mensajes)"
                
                print(url)
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                urlRequest.HTTPMethod = "POST"
                        
                NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
            } else {
                print("Error de codificación de caracteres.")
            }
            
        }
        

        
    }
    
    
    
    
    
    
    
}
