//
//  CategoryController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 03/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class PendienteTableViewController: UITableViewController, NewPendienteControllerDelegate, CerrarPendienteViewControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var pendientes = [[String : AnyObject]]()
    var pendienteJson = [String : AnyObject]()
    var noCellReunionPend : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        loadPendiente()
    }
    
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonClicked(sender:UIButton) {
        
        self.noCellReunionPend = sender.tag
        performSegueWithIdentifier("cerrarPendiente", sender: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PendienteCell
        
        let json = pendientes[indexPath.item]
        
        cell.tituloPendiente.text = json[WebServiceResponseKey.nombrePendiente] as? String
        
        let isChecked = json[WebServiceResponseKey.statusPendiente] as? Int //
        
        if isChecked == 1 {
            cell.checkBox.setImage(cell.checkedImage, forState: .Normal)
            cell.viewStatusCerrado.hidden = false
        } else {
            cell.checkBox.setImage(cell.uncheckedImage, forState: .Normal)
            cell.viewStatusCerrado.hidden = true
        }
        
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(self, action: #selector(PendienteTableViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
       
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendientes.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let json = pendientes[indexPath.item]
        self.pendienteJson = json
        
        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.pendienteId] as! Int, forKey: WebServiceResponseKey.pendienteId)
        
        self.performSegueWithIdentifier("tareas", sender: nil)
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
        loadPendiente()
    }
    
    
    func cerrarPendienteDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadPendiente()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevoPendiente" {
            (segue.destinationViewController as! NewPendienteViewController).delegate = self
            (segue.destinationViewController as! NewPendienteViewController).idRequest = WebServiceRequestParameter.categoryId
            (segue.destinationViewController as! NewPendienteViewController).idRequested = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.categoryId)
            (segue.destinationViewController as! NewPendienteViewController).endPointPendiente = WebServiceEndpoint.newPendiente
        }
        
        else if segue.identifier == "tareas"{
            (segue.destinationViewController as! TareasTableViewController).pendienteJson = self.pendienteJson
            
        } else if segue.identifier == "cerrarPendiente" {
            
            let json = pendientes[noCellReunionPend]
            let rID = (json[WebServiceResponseKey.pendienteId] as? Int)!
            
            (segue.destinationViewController as! CerrarPendienteViewController).delegate = self
            (segue.destinationViewController as! CerrarPendienteViewController).pendienteJson = rID
        }
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
                        
                        self.pendientes.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
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
    
    
    
}
