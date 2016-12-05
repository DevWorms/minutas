//
//  AsuntosTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class AsuntosTableViewController: UITableViewController, NewAsuntosViewControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var asuntos = [[String : AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        loadAsuntos()
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TareasCell
        
        let json = asuntos[indexPath.item]
        
        cell.tituloTarea.text = json[WebServiceResponseKey.nombreSubPendientes] as? String
        cell.tareaCompletaSwitch.on = json[WebServiceResponseKey.pendienteStatus] as! Bool
        // cell.documentosAttachados.text = json[WebServiceResponseKey.fechaInicio] as? String
        
        return cell
        
    }
    
    func newAsuntoControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newAsuntoControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadAsuntos()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.asuntos.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let json = asuntos[indexPath.item]
        
        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.pendienteId] as! Int, forKey: WebServiceResponseKey.pendienteId)
        
        
        
        
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevAsunto"{
            (segue.destinationViewController as! NewAsuntosViewController).delegate = self
        }
    }
    
    
    func loadAsuntos() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        let reunionId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.reunionId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.asuntos)\(userId)/\(apiKey)/\(reunionId)")!
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
                        if self.asuntos.count > 0 {
                            self.asuntos.removeAll()
                        }
                        
                        self.asuntos.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
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
        return 100
    }
    
    
    
}
