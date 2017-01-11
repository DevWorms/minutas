//
//  FavoritosViewController.swift
//  Minutas
//
//  Created by Maria Sanchez on 1/10/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class FavoritosViewController:  UITableViewController, NewSearchViewControllerDelegate {

    @IBOutlet weak var tableV: UITableView!
     var favoritos = [[String : AnyObject]]()
    
    func newConversacionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newConversacionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        
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
    }
    



