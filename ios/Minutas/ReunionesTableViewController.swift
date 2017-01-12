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

class ReunionesTableViewController: UITableViewController, NewReunionViewControllerDelegate, NewMinutaViewControllerDelegate, NewPendienteControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var reuniones = [[String : AnyObject]]()
    var noCellReunion : Int = 0
    var noCellReunionPend : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        loadReuniones()
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
    
    func switchChanged(mySwitch: UISwitch) {
        print(mySwitch.tag)
        
        self.noCellReunion = mySwitch.tag
        
        if !mySwitch.on {
            mySwitch.setOn(true, animated: true)
            
        } else {
            performSegueWithIdentifier("capturarMinutas", sender: nil)
            
        }
    }
    
    func buttonClicked(sender:UIButton) {
        
        self.noCellReunionPend = sender.tag
        performSegueWithIdentifier("nuevoPendiente", sender: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ReunionCell
        
        let json = reuniones[indexPath.item]
        
        cell.tituloReunion.text = json[WebServiceResponseKey.nombreReunion] as? String
        cell.reunionComplete.on = json[WebServiceResponseKey.pendienteStatus] as! Bool
        
        cell.reunionComplete.tag = indexPath.row
        cell.reunionComplete.addTarget(self, action: #selector(ReunionesTableViewController.switchChanged(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.btnPendiente.tag = indexPath.row
        cell.btnPendiente.addTarget(self, action: #selector(ReunionesTableViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        let str = (json[WebServiceResponseKey.horaReunion] as? String)!
        
        let startIndex = str[str.startIndex.advancedBy(0)...str.startIndex.advancedBy(4)]
        
        cell.fechaReunion.text = "El " + (json[WebServiceResponseKey.diaReunion] as? String)! + " a las " + startIndex;
        cell.invitados.text = json[WebServiceResponseKey.participantes] as? String
        
        return cell
 
    }
 
    func newPendienteControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
 
 
    func newPendienteControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadReuniones()
    }
 
    func newReunionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
 
 
    func newReunionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadReuniones()
    }
 
    func newMinutaControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newMinutaControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadReuniones()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reuniones.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let json = reuniones[indexPath.item]
        
        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.reunionId] as! Int, forKey: WebServiceResponseKey.reunionId)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "capturarMinutas"{
            
            let json = reuniones[noCellReunion]
            
            (segue.destinationViewController as! NewMinutaViewController).delegate = self
            (segue.destinationViewController as! NewMinutaViewController).temaMinuta = (json[WebServiceResponseKey.nombreReunion] as? String)!
            (segue.destinationViewController as! NewMinutaViewController).fechaMinuta = (json[WebServiceResponseKey.diaReunion] as? String)!
            (segue.destinationViewController as! NewMinutaViewController).horaMinuta = (json[WebServiceResponseKey.horaReunion] as? String)!
            (segue.destinationViewController as! NewMinutaViewController).objMinuta = (json[WebServiceResponseKey.objetivoReunion] as? String)!
            (segue.destinationViewController as! NewMinutaViewController).reunionID = String((json[WebServiceResponseKey.reunionId] as? Int)!)
            
        }else if segue.identifier ==  "nuevaReunion"{
            (segue.destinationViewController as! NewReunionViewController).delegate = self
        }else if segue.identifier == "nuevoPendiente" {
            
            let json = reuniones[noCellReunionPend]
            let rID = (json[WebServiceResponseKey.reunionId] as? Int)!
            
            (segue.destinationViewController as! NewPendienteViewController).delegate = self
            (segue.destinationViewController as! NewPendienteViewController).idRequest = WebServiceRequestParameter.reunionId
            (segue.destinationViewController as! NewPendienteViewController).idRequested = rID
            (segue.destinationViewController as! NewPendienteViewController).endPointPendiente = WebServiceEndpoint.newPendienteReunion
        }else if segue.identifier == "pendientes" {
            (segue.destinationViewController as! PendienteTableViewController).initial = false
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "pendientes" {
        
        
            if let cell = sender as? UITableViewCell, let indexPath = self.tableView.indexPathForCell(cell) {
            
                let json = reuniones[indexPath.item]
                let json1 = json[WebServiceResponseKey.categoria] as? [String : AnyObject]
                let categoria = json1?[WebServiceResponseKey.categoryId] as? Int
            
                if categoria != nil {
                    NSUserDefaults.standardUserDefaults().setInteger(categoria!, forKey: WebServiceResponseKey.categoryId)
                } else {
                    return false
                }
            }
        }
            
        return true
    }
    
    
    func loadReuniones() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.reuniones)\(userId)/\(apiKey)/")!
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
                        if self.reuniones.count > 0 {
                            self.reuniones.removeAll()
                        }
                        
                        self.reuniones.appendContentsOf(json[WebServiceResponseKey.reuniones] as! [[String : AnyObject]])
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
        return 122
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
