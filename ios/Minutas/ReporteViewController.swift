//
//  ReporteViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 12/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class ReporteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var indice = [String : AnyObject]()
    
    @IBOutlet weak var fechaInicio: UIDatePicker!
    @IBOutlet weak var consultarPorFecha: UIButton!
    @IBOutlet weak var fechafinal: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        loadIndice()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.indice.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! IndiceEficienciaTopCell
        
        let json = indice
        
        print(json.description)
        
        cell.nombreLabel.text = json[WebServiceResponseKey.nombre] as? String
        if let numeroPendientes = json[WebServiceResponseKey.numeroPendientes] as? Int{
            if let numeroDiasAtraso =  json[WebServiceResponseKey.diasAtraso] as? Int {
                if let numeroIndice = json[WebServiceResponseKey.indice] as? Int{
                    cell.numeroPendientesLabel.text = "\(numeroPendientes)"
                    cell.numeroDiasAtrasoLabel.text = "\(numeroDiasAtraso)"
                    cell.incumplimiento.text = "\(numeroIndice)"
                }
            }
        }
        
        
        
        return cell
        
    }
    
    @IBAction func consultarIndice(sender: AnyObject) {
        
        loadIndice()
    }

    
    func loadIndice() {
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let parameterString = "\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.fecha1)=\(formatter.stringFromDate(fechaInicio.date))&\(WebServiceRequestParameter.fecha2)=\(formatter.stringFromDate(fechafinal.date))"
        
        let strUrl = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.reportesMe)"
        print(parameterString, strUrl)
        
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: strUrl)!)
            
            urlRequest.HTTPMethod = "POST"
            
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
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
                        if self.indice.count > 0 {
                            self.indice.removeAll()
                        }
                        
                        self.indice = json[WebServiceResponseKey.indice] as! [String : AnyObject]
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
}
