

//
//  ReunionesTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

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
        
        
    }
    
    
    // must be internal or public.
    func consultaElServicioWeb() {
        
        loadConversaciones()
        
        print("tick \(peticiones++)")
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
        
        print(apiKey, userId)
        let str = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversaciones)\(userId)/\(apiKey)/"
        print(str)
        let url = NSURL(string: str)!
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
    
    
    
    
    
}
