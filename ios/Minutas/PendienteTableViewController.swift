//
//  CategoryController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 03/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit

class PendienteTableViewController: UITableViewController, NewPendienteControllerDelegate, CerrarPendienteViewControllerDelegate, PendViewControllerDelegate, CerrarTareaViewControllerDelegate {
    
    @IBOutlet weak var buttonOk: UIBarButtonItem!
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var pendientes = [[String : AnyObject]]()
    var pendienteJson = [String : AnyObject]()
    var initial = true
    var idPendiente: Int = 0
    
    var rNombrePend = String()
    var rIdPend = Int()
    
    var barButton:BBBadgeBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        if initial {
            loadPendienteInit()
            
            buttonOk.tintColor = UIColor.clearColor()
            buttonOk.enabled = false
        } else {
            loadPendiente()
        }
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let imagenButton = UIImage(named: "ic_notifications_none_white_24pt")
        let btnNotificacion = UIButton(type: .Custom)
        btnNotificacion.frame = CGRectMake(0,0,imagenButton!.size.width, imagenButton!.size.height);
        
        btnNotificacion.addTarget(self, action: #selector(revisarNotificaciones), forControlEvents: UIControlEvents.TouchDown)
        btnNotificacion.setBackgroundImage(imagenButton, forState: UIControlState.Normal)
        
        
        barButton = BBBadgeBarButtonItem(customUIButton: btnNotificacion)
        appDelegate.buttonBarController = barButton
        self.navigationItem.leftBarButtonItem = barButton
        
    }
    
    func revisarNotificaciones(){
        barButton.badgeValue = ""
        let activity = "NotificacionViewController"
        let vc = storyboard!.instantiateViewControllerWithIdentifier(activity) as! NotificacionesTableViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
        
        
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonClicked(sender:UIButton) {
        
        let json = pendientes[sender.tag]
        
        var idProvisional = Int()
        var nameProvisional = String()
        
        let isChecked = json[WebServiceResponseKey.statusPendiente] as? Int
        
        if isChecked == 1 {
            
            let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
            
            if let provisional = json[WebServiceResponseKey.nombreSubPendientes] {
                nameProvisional = (provisional as? String)!
                idProvisional = (json[WebServiceResponseKey.subPendienteId] as? Int)!
                
                let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.subPendienteId)=\(idProvisional)"
                let url = "\(WebServiceEndpoint.baseUrl)\("tasks/set/reabrir")"
                
                if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                    
                    let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                    urlRequest.HTTPMethod = "POST"
                    NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJsonReAbrir).resume()
                    
                } else {
                    
                    print("Error de codificación de caracteres.")
                }
            }else {
                let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(json[WebServiceResponseKey.pendienteId] as! Int)"
                
                print(parameterString)
                
                if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                    let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.reabrirPend)")!)
                    urlRequest.HTTPMethod = "POST"
                    
                    NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJsonReAbrir).resume()
                } else {
                    print("Error de codificación de caracteres.")
                }
            }
            
        } else {
            
            if let provisional = json[WebServiceResponseKey.nombreSubPendientes] {
                nameProvisional = (provisional as? String)!
                idProvisional = (json[WebServiceResponseKey.subPendienteId] as? Int)!
                
                self.rIdPend = idProvisional
                self.rNombrePend = nameProvisional
                performSegueWithIdentifier("cerrarTarea", sender: nil)
            }else {
                idProvisional = (json[WebServiceResponseKey.pendienteId] as? Int)!
                nameProvisional = (json[WebServiceResponseKey.nombrePendiente] as? String)!
                
                self.rIdPend = idProvisional
                self.rNombrePend = nameProvisional
                performSegueWithIdentifier("cerrarPendiente", sender: nil)
            }
        }
    }
    
    func parseJsonReAbrir(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_async(dispatch_get_main_queue()) {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            
                            if self.initial {
                                self.loadPendienteInit()
                            } else {
                                self.loadPendiente()
                            }
                        }
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
    }
    
    func buttonClickedTareas(sender:UIButton) {
        if initial {
            print("mm")
        } else {
            let json = pendientes[sender.tag]
            self.pendienteJson = json
            
            NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.pendienteId] as! Int, forKey: WebServiceResponseKey.pendienteId)
            
            self.performSegueWithIdentifier("tareas", sender: nil)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PendienteCell
        
        let json = pendientes[indexPath.item]
        
        if let sub_pend = json[WebServiceResponseKey.nombreSubPendientes] {
            cell.tituloPendiente.text = sub_pend as? String
        } else {
            cell.tituloPendiente.text = json[WebServiceResponseKey.nombrePendiente] as? String
        }
        
        let isChecked = json[WebServiceResponseKey.statusPendiente] as? Int //
        
        if isChecked == 1 {
            cell.checkBox.setImage(cell.checkedImage, forState: .Normal)
            cell.viewStatusCerrado.hidden = false
        } else {
            cell.checkBox.setImage(cell.uncheckedImage, forState: .Normal)
            cell.viewStatusCerrado.hidden = true
        }
        
        let statVis = json[WebServiceResponseKey.pendienteStatusVisible] as? String
        
        if statVis == "Vencido" {
            cell.status.hidden = false
        } else {
            cell.status.hidden = true
        }
        
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(self, action: #selector(PendienteTableViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        if !self.initial {
            cell.btnTareas.hidden = false
            cell.btnTareas.tag = indexPath.row
            cell.btnTareas.addTarget(self, action: #selector(PendienteTableViewController.buttonClickedTareas(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cell.btnTareas.hidden = true
        }
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendientes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if initial {
            print("mm")
        } else {
            let json = pendientes[indexPath.item]
            self.pendienteJson = json
            
            NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.pendienteId] as! Int, forKey: WebServiceResponseKey.pendienteId)
            
            self.performSegueWithIdentifier("pend", sender: nil)
        }
        
    }
    
    func newPendienteControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newPendienteControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadPendiente()
    }
    
    func cerrarPendienteDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func cerrarPendienteDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        if initial {
            loadPendienteInit()
            print("mm")
        } else {
            loadPendiente()
        }
    }
    
    func cerrarTareaDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cerrarTareaDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        if initial {
            loadPendienteInit()
            print("mm")
        } else {
            loadPendiente()
        }
    }
    
    func pendienteDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pendienteDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadPendiente()
    }
    
    func loadPendienteInit() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\("search/mispendientes/")\(userId)/\(apiKey)")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }
    
    func loadPendiente() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        let categoryId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.categoryId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.pendientes)\(userId)/\(apiKey)/\(categoryId)")!
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
                        if self.pendientes.count > 0 {
                            self.pendientes.removeAll()
                        }
                        
                        //Cuando el pendiente es buscado por medio de la lupa del menu se debe mostrar unicamente el pendiente cuyo idPendiente sea diferente de 0
                        if self.idPendiente > 0 {
                            
                            for pend in json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]]{
                                if self.idPendiente == pend[WebServiceResponseKey.pendienteId] as! Int{
                                    self.pendientes.append(pend)
                                }
                                
                            }
                            
                            
                        }
                        else{
                            self.pendientes.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
                        }
                        
                        self.tableView?.reloadData()
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
    
    // para cuadrar las imagenes
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevoPendiente" {
            (segue.destinationViewController as! NewPendienteViewController).delegate = self
            (segue.destinationViewController as! NewPendienteViewController).idRequest = WebServiceRequestParameter.categoryId
            (segue.destinationViewController as! NewPendienteViewController).idRequested = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.categoryId)
            (segue.destinationViewController as! NewPendienteViewController).endPointPendiente = WebServiceEndpoint.newPendiente
        }
            
        else if segue.identifier == "pend"{
            (segue.destinationViewController as! PendViewController).pendienteJson = self.pendienteJson
            (segue.destinationViewController as! PendViewController).delegate = self
        } else if segue.identifier == "cerrarPendiente" {
            
            (segue.destinationViewController as! CerrarPendienteViewController).delegate = self
            (segue.destinationViewController as! CerrarPendienteViewController).pendienteJson = self.rIdPend
            (segue.destinationViewController as! CerrarPendienteViewController).nombrePendiente = self.rNombrePend
        }else if segue.identifier == "cerrarTarea"{
            (segue.destinationViewController as! CerrarTareaViewController).delegate = self
            (segue.destinationViewController as! CerrarTareaViewController).idTarea = self.rIdPend
            (segue.destinationViewController as! CerrarTareaViewController).nameTarea = self.rNombrePend
        }
    }
    
    
    
    
}
