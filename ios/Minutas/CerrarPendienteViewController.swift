//
//  CerrarPendienteViewController.swift
//  Minutas
//
//  Created by Emmanuel Valentín Granados López on 10/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

protocol CerrarPendienteViewControllerDelegate: NSObjectProtocol  {
    func cerrarPendienteDidCancel()
    func cerrarPendienteDidFinish()
}

class CerrarPendienteViewController: UIViewController {
    
    weak var delegate: CerrarPendienteViewControllerDelegate?

    @IBOutlet weak var titlePend: UILabel!
    @IBOutlet weak var textP: UITextView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var nombreUno: UILabel!
    @IBOutlet weak var nombreDos: UILabel!
    @IBOutlet weak var nombreTres: UILabel!
    @IBOutlet weak var nombreCuatro: UILabel!
    @IBOutlet weak var nombreCinco: UILabel!
    
    @IBOutlet weak var adjuntarUno: UIButton!
    @IBOutlet weak var adjuntarDos: UIButton!
    @IBOutlet weak var adjuntarTres: UIButton!
    @IBOutlet weak var adjuntarCuatro: UIButton!
    @IBOutlet weak var adjuntarCinco: UIButton!
    
    var pendienteJson = Int?()
    var nombrePendiente = String?()
    var anadidos = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titlePend.text = nombrePendiente

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func archivoExtra(sender: AnyObject) {
        
        switch anadidos {
        case 0:
            nombreDos.hidden = false
            adjuntarDos.hidden = false
            anadidos = anadidos + 1
        case 1:
            nombreTres.hidden = false
            adjuntarTres.hidden = false
            anadidos = anadidos + 1
        case 2:
            nombreCuatro.hidden = false
            adjuntarCuatro.hidden = false
            anadidos = anadidos + 1
        case 3:
            nombreCinco.hidden = false
            adjuntarCinco.hidden = false
            anadidos = anadidos + 1
        default: break
            //
        }
        
    }
    
    @IBAction func archivoUno(sender: AnyObject) {
    }
    @IBAction func archivoDos(sender: AnyObject) {
    }
    @IBAction func archivoTres(sender: AnyObject) {
    }
    @IBAction func archivoCuatro(sender: AnyObject) {
    }
    @IBAction func archivoCinco(sender: AnyObject) {
    }
    
    
    // MARK: Configuring the view's layout behavior
    
    override func viewDidLayoutSubviews() {
        navigationBar.subviews[0].frame = CGRect(x: 0.0, y: -20.0, width: view.bounds.width, height: 64.0)
    }
    
    // MARK: Managing the status bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction
    func cancelar(_: AnyObject) {
        delegate?.cerrarPendienteDidCancel()
    }
    
    @IBAction
    func ok(_: AnyObject) {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        if let acuerdo = textP.text {
            
            let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(pendienteJson!)&\(WebServiceRequestParameter.mensaje)=\(acuerdo)&\(WebServiceRequestParameter.fileClose)=\("---")"
            
            print(parameterString)
            
            if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.closePendiente)")!)
                urlRequest.HTTPMethod = "POST"
                
                NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
            } else {
                print("Error de codificación de caracteres.")
            }
        }
        else{
            let vc_alert = UIAlertController(title: "Un momento", message: "Debe llenar todos los campos", preferredStyle: .Alert)
            
            vc_alert.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Default,
                handler: nil))
            self.presentViewController(vc_alert, animated: true, completion: nil)
            
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
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.delegate?.cerrarPendienteDidFinish()
                        }
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
