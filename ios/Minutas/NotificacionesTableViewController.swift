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

class NotificacionesTableViewController: UITableViewController,NewSearchViewControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var notificaciones = [[String : AnyObject]]()
    var idTarea = Int()
    
    // idOperacion = 5 delegar subpendiente
    // idOperacion = 6 delegar pendiente
    // idOperacion = 7 aceptar pendiente
    // idOperacion = 8 aceptar subpendiente
    
    
    var idOperacion = Int()
    
    var tick = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        loadNotificaciones()
       /* let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.tabBarController = tabBarController
        
        let currentIndex = appDelegate.tabBarController.selectedIndex
        if currentIndex < appDelegate.tabBarController.tabBar.items?.count{
            appDelegate.tabBarController.tabBar.items?[currentIndex].badgeValue = nil
        }*/
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificacionesTableViewController.loadNotificaciones), name:UIApplicationDidBecomeActiveNotification, object: nil);
        
       /* var timer = NSTimer.scheduledTimerWithTimeInterval(ApplicationConstants.tiempoParaConsultarServicioWeb, target: self, selector: #selector(consultaElServicioWeb), userInfo: nil, repeats: true)
        */
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.buttonBarController.badgeValue = ""
        
        
    }
    
    
    func consultaElServicioWeb() {
        //if peticiones <= 10{
        loadNotificaciones()
        //sleep(4)
        //        }
        
        print("tick \(tick++)")
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! GenericCell
        
        cell.aparecio = false
        
    }
    
    
    
    func newConversacionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newConversacionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        leerNotificaciones(idTarea)
        
        
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
        //print(json.description)
        
        let txt = "<font color=\"white\">" + (json[WebServiceResponseKey.notificacionText] as? String)! + " </font>"
        let attrStr = try! NSAttributedString(
            data: txt.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        cell.textoNotificacion.attributedText = attrStr
        //print(attrStr)
        
        
        var obligatorio = json[WebServiceResponseKey.notificacionObligatoria] as? Bool
        
        
        let notificacionesSubPendientes = json[WebServiceResponseKey.subPendienteIdNotificaciones]  as? Int
        
        let pendienteId = json[WebServiceResponseKey.pendienteId] as? Int
        
        if  notificacionesSubPendientes != nil && notificacionesSubPendientes > 0 {
            print(notificacionesSubPendientes)
         
        }
        else{
            if pendienteId != nil && pendienteId > 0 {
                print(pendienteId)
            }else{
                obligatorio = true
                let idNotificacion = json[WebServiceResponseKey.notificacionId] as? Int
                print(idNotificacion)
                leerNotificaciones(idNotificacion)
            }
        }
        
        if obligatorio == false {
            cell.btnAceptar.hidden = false
            cell.btnDelegar.hidden = false
            cell.btnRechazar.hidden = false
            
            cell.btnAceptar.addTarget(self, action: #selector(self.buttonAceptar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnAceptar.tag = indexPath.row
        
        
            cell.btnDelegar.addTarget(self, action: #selector(self.buttonDelegar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnDelegar.tag = indexPath.row
            
            cell.btnRechazar.addTarget(self, action: #selector(self.buttonRechazar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnRechazar.tag = indexPath.row
            
        }
        else{
            cell.btnAceptar.hidden = true
            cell.btnDelegar.hidden = true
            cell.btnRechazar.hidden = true
        }
        
       /*
        cell.notificacionIconNew.hidden = ((json[WebServiceResponseKey.notificacionLeida] as? Bool)!)
        */
        
        return cell
        
    }
    
    func buttonDelegar(sender:UIButton) {
        let json = notificaciones[sender.tag]
        
        let notificacionesSubPendientes = json[WebServiceResponseKey.subPendienteIdNotificaciones]  as? Int
        let pendienteId = json[WebServiceResponseKey.pendienteId] as? Int
        
        
        if  notificacionesSubPendientes != nil && notificacionesSubPendientes > 0 {
            print(notificacionesSubPendientes)
            
            idOperacion = 5
            idTarea = notificacionesSubPendientes!
        }
        else{
            if pendienteId != nil && pendienteId > 0 {
                print(pendienteId)
                
                idOperacion = 6
                idTarea = pendienteId!
                
            }else{
                
                let idNotificacion = json[WebServiceResponseKey.notificacionId] as? Int
                print(idNotificacion)
                leerNotificaciones(idNotificacion)
            }
        }

        
        
        self.performSegueWithIdentifier("delegarTarea", sender: nil)
    }
    
    func buttonAceptar(sender:UIButton) {
        let json = notificaciones[sender.tag]
        
        print(json)
        
        
        let notificacionesSubPendientes = json[WebServiceResponseKey.subPendienteIdNotificaciones]  as? Int
        let pendienteId = json[WebServiceResponseKey.pendienteId] as? Int
        
        
        if  notificacionesSubPendientes != nil && notificacionesSubPendientes > 0 {
            print(notificacionesSubPendientes)
            
            idTarea = (json[WebServiceResponseKey.subPendienteIdNotificaciones] as? Int)!
            manejarNotificaciones(idTarea, opcion: 4)
            
        }
        else{
            if pendienteId != nil && pendienteId > 0 {
                print(pendienteId)
                
                idTarea = (json[WebServiceResponseKey.pendienteId] as? Int)!
                manejarNotificaciones(idTarea, opcion: 3)
                
            }else{
                
                let idNotificacion = json[WebServiceResponseKey.notificacionId] as? Int
                print(idNotificacion)
                leerNotificaciones(idNotificacion)
            }
        }
        
        
       // leerNotificaciones(json[WebServiceResponseKey.notificacionId] as? Int)
        
    }
  
    func buttonRechazar(sender:UIButton) {
        
        let json = notificaciones[sender.tag]
        
        print(json)
        
        let notificacionesSubPendientes = json[WebServiceResponseKey.subPendienteIdNotificaciones]  as? Int
        let pendienteId = json[WebServiceResponseKey.pendienteId] as? Int
        
        
        if  notificacionesSubPendientes != nil && notificacionesSubPendientes > 0 {
            print(notificacionesSubPendientes)
            
            idTarea = (json[WebServiceResponseKey.subPendienteIdNotificaciones] as? Int)!
            manejarNotificaciones(idTarea, opcion: 1)
            
        }
        else{
            if pendienteId != nil && pendienteId > 0 {
                print(pendienteId)
                
                idTarea = (json[WebServiceResponseKey.pendienteId] as? Int)!
                manejarNotificaciones(idTarea, opcion: 2)
                
            }else{
                
                let idNotificacion = json[WebServiceResponseKey.notificacionId] as? Int
                print(idNotificacion)
                leerNotificaciones(idNotificacion)
            }
        }
        
        
        
        
        
      //  leerNotificaciones(json[WebServiceResponseKey.notificacionId] as? Int)
    }
  
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificaciones.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "delegarTarea" {
            (segue.destinationViewController as! SearchUserViewController).anadirUsuarioSolamente = idOperacion
            (segue.destinationViewController as! SearchUserViewController).delegate = self
            (segue.destinationViewController as! SearchUserViewController).idAsignar = self.idTarea
            
        }
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
            
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJsonNotificacion).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
        
        
    }

    func manejarNotificaciones(pendienteId:Int, opcion: Int) {
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        
        var parameterString = ""
        var url = ""
        
        switch opcion {
        case 1:// rechazar sub pendiente
            
            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.subPendienteId)=\(pendienteId)"
            
            url =  "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.rechazartarea)"
            
            break
        case 2: // rechazar pendiente
            
            
            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(pendienteId)"
            
            url =  "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.rechazarpendiente)"
            break
        case 3: // aceptar pendiente
            
            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(pendienteId)"
                url =  "\(WebServiceEndpoint.baseUrl)\("pendientes/aceptar")"
            
            break
        case 4: // aceptar subpendiente
            
            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.subPendienteId)=\(pendienteId)"
            url =  "\(WebServiceEndpoint.baseUrl)\("tasks/aceptar")"
            
            break
        default:
            break
            
        }
        
        print(parameterString)
        
        print(url)
        
        //return
        
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            
            print(url)
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
            urlRequest.HTTPMethod = "POST"
            
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJsonNotificacion).resume()
        } else {
            print("Error de codificación de caracteres.")
        }
        
        
    }
    
    
    func loadNotificaciones() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.notificaciones)\(userId)/\(apiKey)/\(false)")!
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }
    
    func parseJsonNotificacion(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                print(data)
                
                if data != nil{
                    if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                        
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                            vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                                if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                                    self.loadNotificaciones()
                                }
                                })
                            self.presentViewController(vc_alert, animated: true, completion: nil)
                        }
                    } else {
                        print("HTTP Status Code: 200")
                        print("El JSON de respuesta es inválido.")
                    }
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
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                print(data)
                
                if data != nil {
                    if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    
                    //print(json)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if self.notificaciones.count > 0 {
                                self.notificaciones.removeAll()
                            }
                        
                            
                                self.notificaciones.appendContentsOf(json[WebServiceResponseKey.notificaciones] as! [[String : AnyObject]])
                                self.tableView?.reloadData()
                            
                        }
                    } else {
                        print("HTTP Status Code: 200")
                        print("El JSON de respuesta es inválido.")
                    }
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
