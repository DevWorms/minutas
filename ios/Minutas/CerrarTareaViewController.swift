//
//  CerrarTareaViewController.swift
//  Minutas
//
//  Created by Emmanuel Valentín Granados López on 15/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol CerrarTareaViewControllerDelegate: NSObjectProtocol  {
    func cerrarTareaDidCancel()
    func cerrarTareaDidFinish()
}

class CerrarTareaViewController: UIViewController {
    
    weak var delegate: CerrarTareaViewControllerDelegate?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tarea: UILabel!
    @IBOutlet weak var solucion: UITextView!
    
    var idTarea = Int()
    var nameTarea = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tarea.text = self.nameTarea

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelar(sender: AnyObject) {
        delegate?.cerrarTareaDidCancel()
    }

    @IBAction func ok(sender: AnyObject) {
        
        if let titulo = tarea.text{
            
            if titulo == "" {
                let vc_alert = UIAlertController(title: "Un momento", message: "Agrega solución", preferredStyle: .Alert)
                
                vc_alert.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: nil))
                self.presentViewController(vc_alert, animated: true, completion: nil)
                
                
            }else{
                
                var parameterString = ""
                var url = ""
                
                let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
                let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
                
                parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.subPendienteId)=\(idTarea)&\("mensaje")=\(titulo)"
                url = "\(WebServiceEndpoint.baseUrl)\("tasks/set/cerrado")"
                
                
                print(url)
                print(parameterString)
                
                if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                    
                    
                    let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
                    urlRequest.HTTPMethod = "POST"
                    NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
                    
                } else {
                    
                    print("Error de codificación de caracteres.")
                }
            }
            
        }

    }
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_async(dispatch_get_main_queue()) {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        
                        self.delegate?.cerrarTareaDidFinish()
                        
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
