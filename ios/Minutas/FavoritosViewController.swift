//
//  FavoritosViewController.swift
//  Minutas
//
//  Created by Maria Sanchez on 1/10/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import TwitterKit

class FavoritosViewController:  UITableViewController, NewSearchViewControllerDelegate {

    @IBOutlet weak var tableV: UITableView!
     var favoritos = [[String : AnyObject]]()
    var barButton:BBBadgeBarButtonItem!
    
    func newConversacionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newConversacionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadFavoritos()
    }
    
    // Make the background color show through
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        loadFavoritos()
        
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "pantallaFavoritos"{
            (segue.destinationViewController as! SearchUserViewController).caminoFavorito = true
            (segue.destinationViewController as! SearchUserViewController).delegate = self
            
        }
    }
    
    /// llena cada celda
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SearchUsuarioCell
        
        let json = favoritos[indexPath.item]
        
        cell.txtNombreUsuario.text = json[WebServiceResponseKey.nombreFavorito] as? String
       
        return cell
        
        
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SearchUsuarioCell

        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.favoritos.count
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    // para cuadrar las imagenes
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
    }
    
    func loadFavoritos() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
         let parameterString = "\(WebServiceRequestParameter.userIdFavoritos)=\(userId)&\(WebServiceRequestParameter.apiKeyFavoritos)=\(apiKey)"
        
        print(apiKey, userId)
       
      
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.favoritos)")!)
            urlRequest.HTTPMethod = "POST"
            print(urlRequest)
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody,  completionHandler: parseJson).resume()
            
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
                        if self.favoritos.count > 0 {
                            self.favoritos.removeAll()
                        }
                        
                        self.favoritos.appendContentsOf(json[WebServiceResponseKey.favoritosList] as! [[String : AnyObject]])
                        self.tableView?.reloadData()
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
    
    @IBAction func cerrarSesion(sender: AnyObject) {
        
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
    



