

//
//  ReunionesTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit

class ConversacionesTableViewController: UITableViewController, NewSearchViewControllerDelegate{
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    var peticiones = 1
    
    func newConversacionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newConversacionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadConversaciones()
    }

    
    var conversaciones = [[String : AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        loadConversaciones()
        var timer = NSTimer.scheduledTimerWithTimeInterval(ApplicationConstants.tiempoParaConsultarServicioWeb, target: self, selector: #selector(consultaElServicioWeb), userInfo: nil, repeats: true)
        
        //let thread = NSThread(target:self, selector:#selector(actualizacion), object:nil)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.tabBarController = tabBarController
        
        let currentIndex = appDelegate.tabBarController.selectedIndex
        if currentIndex < appDelegate.tabBarController.tabBar.items?.count{
            appDelegate.tabBarController.tabBar.items?[currentIndex].badgeValue = nil
        }
        
        
    }
    
    
    
    // must be internal or public.
    func consultaElServicioWeb() {
        
        loadConversaciones()
        
        print("tick \(peticiones++)")
      /*
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "Todo ItIs Overdue" // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        UIApplication.sharedApplication().scheduleLocalNotification(notification)*/
        
    }

   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Make the background color show through
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ConversacionCell
        
        let json = conversaciones[indexPath.item]
        
        cell.tituloChat.text = json[WebServiceResponseKey.tituloChat] as? String
        let miembros = json[WebServiceResponseKey.miembros] as! [[String : AnyObject]]
        cell.usuarios.text = ""
        for jsonMiembros in miembros{
            
            if !((cell.usuarios.text?.isEmpty)!){
                cell.usuarios.text = cell.usuarios.text! + ", " + (jsonMiembros[WebServiceResponseKey.apodo] as? String)!
            }else{
            
                cell.usuarios.text = jsonMiembros[WebServiceResponseKey.apodo] as? String
            }
            
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ConversacionCell
        
        cell.aparecio = false
        
    }
    
   
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversaciones.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let json = conversaciones[indexPath.item]
        
        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.conversacionId] as! Int, forKey: WebServiceResponseKey.conversacionId)
        
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevaconversacion"{
            (segue.destinationViewController as! SearchUserViewController).delegate = self
        }
    }
    
    
    func loadConversaciones() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        let str = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversaciones)\(userId)/\(apiKey)/"
        let url = NSURL(string: str)!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    //print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.conversaciones.count > 0 {
                            self.conversaciones.removeAll()
                        }
                        
                        self.conversaciones.appendContentsOf(json[WebServiceResponseKey.conversaciones] as! [[String : AnyObject]])
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
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
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
