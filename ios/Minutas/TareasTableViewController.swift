//
//  TareasTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit

class TareasTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewTareaViewControllerDelegate, NewSearchViewControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    @IBOutlet weak var tableView: UITableView!
    
    var tareas = [[String : AnyObject]]()
    var idTarea = Int()
    
    func newConversacionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newConversacionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadTareas()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTareas()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Make the background color show through
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func buttonAsignar(sender:UIButton) {
        let json = tareas[sender.tag]
        
        idTarea = json[WebServiceResponseKey.subPendienteId] as! Int
        
        self.performSegueWithIdentifier("asignarTarea", sender: nil)
    }
    
    func buttonReAsignar(sender:UIButton) {
        let json = tareas[sender.tag]
        
        idTarea = json[WebServiceResponseKey.subPendienteId] as! Int
        
        self.performSegueWithIdentifier("reasignarTarea", sender: nil)
    }
    
    func buttonDelegar(sender:UIButton) {
        let json = tareas[sender.tag]
        
        idTarea = json[WebServiceResponseKey.subPendienteId] as! Int
        
        self.performSegueWithIdentifier("delegarTarea", sender: nil)
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TareasCell
        
        let json = tareas[indexPath.item]
        
        cell.tituloTarea.text = json[WebServiceResponseKey.nombreSubPendientes] as? String
        cell.tareaCompletaSwitch.on = json[WebServiceResponseKey.pendienteStatus] as! Bool
        cell.responsableTarea.text = json[WebServiceResponseKey.responsable] as? String
        
        cell.tareaCompletaSwitch.tag = indexPath.row
        //cell.tareaCompletaSwitch.addTarget(self, action: #selector(.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.asignarBtn.tag = indexPath.row
        cell.asignarBtn.addTarget(self, action: #selector(self.buttonAsignar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.reasignarBtn.tag = indexPath.row
        cell.reasignarBtn.addTarget(self, action: #selector(self.buttonReAsignar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.delegarBtn.tag = indexPath.row
        cell.delegarBtn.addTarget(self, action: #selector(self.buttonDelegar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
    }
    
    func newTareaControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newTareaControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadTareas()
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tareas.count
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func loadTareas() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        let pendienteId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.pendienteId)
        
        print("jum")
        print(pendienteId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.tareas)\(userId)/\(apiKey)/\(pendienteId)")!
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
                        if self.tareas.count > 0 {
                            self.tareas.removeAll()
                        }
                        
                        
                        //if self.idTarea > 0 {
                            
                            for tarea in json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]] {
                                //if self.idTarea == tarea[WebServiceResponseKey.subPendienteId] as! Int{
                                    self.tareas.append(tarea)
                                //}
                                
                            }
                        
                        //let t = self.tareas[0]
                        //let ta = t[WebServiceResponseKey.subPendienteId]
                        //print(ta)
                            
                            
                        //}
                        //else{
                        //    self.tareas.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
                        //}

                        
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
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100
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
        
        if segue.identifier == "nuevoTarea"{
            (segue.destinationViewController as! NewTareaViewController).delegate = self
            
        }else if segue.identifier == "asignarTarea" {
            (segue.destinationViewController as! SearchUserViewController).anadirUsuarioSolamente = 3
            (segue.destinationViewController as! SearchUserViewController).delegate = self
            (segue.destinationViewController as! SearchUserViewController).idAsignar = self.idTarea
            
        }else if segue.identifier == "reasignarTarea" {
            (segue.destinationViewController as! SearchUserViewController).anadirUsuarioSolamente = 4
            (segue.destinationViewController as! SearchUserViewController).delegate = self
            (segue.destinationViewController as! SearchUserViewController).idAsignar = self.idTarea
            
        }else if segue.identifier == "delegarTarea" {
            (segue.destinationViewController as! SearchUserViewController).anadirUsuarioSolamente = 5
            (segue.destinationViewController as! SearchUserViewController).delegate = self
            (segue.destinationViewController as! SearchUserViewController).idAsignar = self.idTarea
        }
        
        
    }
    
}
