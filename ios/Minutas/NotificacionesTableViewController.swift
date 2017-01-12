//
//  NotificacionesTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 09/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit

class NotificacionesTableViewController: UITableViewController {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var notificaciones = [[String : AnyObject]]()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var updateTimer: NSTimer?
    var mostrarNotificacion:Bool!
    
    override func viewDidDisappear(animated: Bool) {
        mostrarNotificacion = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reinstateBackgroundTask), name: UIApplicationDidBecomeActiveNotification, object: nil)
    
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(ApplicationConstants.tiempoParaConsultarServicioWeb, target: self, selector: #selector(loadNotificaciones), userInfo: nil, repeats: true)
        
        mostrarNotificacion = false
        registerBackgroundTask()

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
        
    func reinstateBackgroundTask() {
        if backgroundTask == UIBackgroundTaskInvalid {
            
            loadNotificaciones()
            
            registerBackgroundTask()
        }
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ 
            
            self.endBackgroundTask()
            
        })
        
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NotificacionCell
        
        let json = notificaciones[indexPath.item]
        print(json.description)
        
        let txt = "<font color=\"white\">" + (json[WebServiceResponseKey.notificacionText] as? String)! + " </font>"
        var attrStr = try! NSAttributedString(
            data: txt.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        
        
        cell.textoNotificacion.attributedText = attrStr
        
        
        
        print(attrStr)
        cell.notificacionIconNew.hidden = ((json[WebServiceResponseKey.notificacionLeida] as? Bool)!)
        
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificaciones.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
    }
    
    
    func loadNotificaciones() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.notificaciones)\(userId)/\(apiKey)/")!
        
        print(url)
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }

    
    func leerNotificaciones(idNotificacion:Int!) {
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        
        let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.notificaciones)=\(idNotificacion)"
        
        print(parameterString)
        
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.notificacionesLeidas)"
            
            print(url)
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
            urlRequest.HTTPMethod = "POST"
            
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
    

    }


    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        
                        if self.notificaciones.count > 0 {
                            self.notificaciones.removeAll()
                        }
                        
                        if let mensajesArray = json[WebServiceResponseKey.notificaciones] {
                        
                            print(mensajesArray?.description)
                            if mensajesArray?.description != nil{
                                self.notificaciones.appendContentsOf(mensajesArray as! [[String : AnyObject]])
                                
                                switch UIApplication.sharedApplication().applicationState {
                                case .Active:
                                    self.tableView?.reloadData()
                                    
                                    if (self.mostrarNotificacion != nil) {
                                        print("App esta en otra pantalla")
                                        
                                    }
                                case .Background:
                                    self.mandarNotificacion()
                                    
                                    print("App is backgrounded.")
                                    print("Background notifications = \(self.notificaciones.count) seconds")
                                case .Inactive:
                                    print("App is inactive.")
                                    
                                    self.mandarNotificacion()
                                    break
                                }
                            }
                            
                           
                        }
                        
                        
                        
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
    
    func mandarNotificacion(){
        
        for notificacion in self.notificaciones {
            
            if (notificacion[WebServiceResponseKey.notificacionLeida] as! Bool) == false {
                
                let txt = (notificacion[WebServiceResponseKey.notificacionText] as? String)!
                let attrStr = try! NSAttributedString(
                    data: txt.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                    documentAttributes: nil)
                
                
                
                let label = UILabel()
                label.attributedText = attrStr
                
                
                
                // create a corresponding local notification
                let notification = UILocalNotification()
                notification.alertBody = label.text // text that will be displayed in the notification
                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            
                notification.userInfo = ["title": notificacion[WebServiceResponseKey.notificacionText]!, "UUID": notificacion[WebServiceResponseKey.notificacionText]!] // assign a unique identifier to the notification so that we can retrieve it later
                
                
                self.leerNotificaciones(notificacion[WebServiceResponseKey.notificacionId] as! Int)
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
            
        }

    }
    
    // para cuadrar las imagenes
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 64
    }
    
    @IBAction func usuario(sender: AnyObject) {
        let apodo = NSUserDefaults.standardUserDefaults().stringForKey(WebServiceResponseKey.apodo)
        
        
        let alertController = UIAlertController(title: "Apodo", message: apodo, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Cerrar sesión", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            self.cerrarSesion()
            
            //self.performSegueWithIdentifier("login", sender: nil)
        })
        alertController.addAction(deleteAction)
        
        let okAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            print("OK button tapped")
        })
        alertController.addAction(okAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = sender.frame
        
        presentViewController(alertController, animated: true, completion: nil)
        
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
        
        
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.apodo)
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.token)
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.redSocial)
        
        let vc = storyboard!.instantiateViewControllerWithIdentifier("LogInViewController")
        self.presentViewController( vc , animated: true, completion: nil)
        
    }
    
    
}
