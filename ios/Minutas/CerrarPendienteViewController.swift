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

class CerrarPendienteViewController: UIViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
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
    var archivo = 0
    
    var documentMenu = UIDocumentMenuViewController?()
    
    let requestBodyData = NSMutableData()
    
    var boundary = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boundary = generateBoundaryString()
        
        // https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
        documentMenu = UIDocumentMenuViewController(documentTypes: [
            "com.adobe.pdf",
            "com.microsoft.word.doc",
            "org.openxmlformats.wordprocessingml.document",
            "com.microsoft.excel.xls",
            "org.openxmlformats.spreadsheetml.sheet",
            "public.png",
            "public.rtf",
            "com.pkware.zip-archive",
            "com.compuserve.gif",
            "public.jpeg"
            ], inMode: UIDocumentPickerMode.Import)
        
        documentMenu!.delegate = self
        
        documentMenu!.popoverPresentationController?.sourceView = self.view
        
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
        archivo = 1
        
        self.presentViewController(documentMenu!, animated: true, completion: nil)
    }
    @IBAction func archivoDos(sender: AnyObject) {
        archivo = 2
        
        self.presentViewController(documentMenu!, animated: true, completion: nil)
    }
    @IBAction func archivoTres(sender: AnyObject) {
        archivo = 3
        
        self.presentViewController(documentMenu!, animated: true, completion: nil)
    }
    @IBAction func archivoCuatro(sender: AnyObject) {
        archivo = 4
        
        self.presentViewController(documentMenu!, animated: true, completion: nil)
    }
    @IBAction func archivoCinco(sender: AnyObject) {
        archivo = 5
        
        self.presentViewController(documentMenu!, animated: true, completion: nil)
    }
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        if controller.documentPickerMode == UIDocumentPickerMode.Import {
            
            MyFile.url = url
            
            var fileSize : UInt64 = 0
            let sizeMax : UInt64 = 10000000
            
            do {
                let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath( MyFile.Path )
                
                if let _attr = attr {
                    fileSize = _attr.fileSize();
                    
                    print("fileSize: \(fileSize)")
                    
                    if fileSize < sizeMax {
                        
                        switch archivo {
                        case 1:
                            nombreUno.text = MyFile.Name
                        case 2:
                            nombreDos.text = MyFile.Name
                        case 3:
                            nombreTres.text = MyFile.Name
                        case 4:
                            nombreCuatro.text = MyFile.Name
                        case 5:
                            nombreCinco.text = MyFile.Name
                        default: break
                            //
                        }
                    } else {
                        let vc_alert = UIAlertController(title: nil, message: "Su archivo pesa más de lo permitido", preferredStyle: .Alert)
                        
                        vc_alert.addAction(UIAlertAction(title: "OK",
                            style: UIAlertActionStyle.Default,
                            handler: nil))
                        self.presentViewController(vc_alert, animated: true, completion: nil)
                    }
                    
                }
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    // MARK: - UIDocumentMenuDelegate
    func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        presentViewController(documentPicker, animated: true, completion: nil)
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
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    @IBAction
    func ok(_: AnyObject) {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        if let acuerdo = textP.text {
            requestBodyData.appendString("--\(boundary)\r\n")
            requestBodyData.appendString("Content-Disposition: form-data; name=" + WebServiceRequestParameter.apiKey + "\r\n\r\n")
            requestBodyData.appendString("\( apiKey )\r\n")  // numero puede ser string o integer
            
            requestBodyData.appendString("--\(boundary)\r\n")
            requestBodyData.appendString("Content-Disposition: form-data; name=" + WebServiceRequestParameter.pendienteId + "\r\n\r\n")
            requestBodyData.appendString("\( pendienteJson! )\r\n")  // numero puede ser string o integer
            
            requestBodyData.appendString("--\(boundary)\r\n")
            requestBodyData.appendString("Content-Disposition: form-data; name=" + WebServiceRequestParameter.mensaje + "\r\n\r\n")
            requestBodyData.appendString("\( acuerdo )\r\n")  // numero puede ser string o integer
            
            requestBodyData.appendString("--\(boundary)\r\n")
            requestBodyData.appendString("Content-Disposition: form-data; name=" + WebServiceRequestParameter.userId + "\r\n\r\n")
            requestBodyData.appendString("\( userId )\r\n")  // numero puede ser string o integer
            
            let mimeType = "application/pdf"
            
            /*requestBodyData.appendString("--\(boundary)\r\n")
            requestBodyData.appendString("Content-Disposition: form-data; name=file; filename=" + ( MyFile.Name ) + "\r\n")
            requestBodyData.appendString("Content-Type: \(mimeType)\r\n\r\n")
            requestBodyData.appendData( NSData(contentsOfFile: MyFile.Path )! )
            requestBodyData.appendString("\r\n")
            requestBodyData.appendString("--\(boundary)--\r\n")*/
            
            
            //let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(pendienteJson!)&\(WebServiceRequestParameter.mensaje)=\(acuerdo)&\(WebServiceRequestParameter.fileClose)=\(data!)"
            
            //print(parameterString)
            
            //if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.closePendiente)")!)
            
                let contentType = "multipart/form-data; boundary=" + boundary
                urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
                urlRequest.HTTPMethod = "POST"
            
                urlRequest.HTTPBody = requestBodyData
            
            
            
            
                NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: parseJson).resume()
                
                //NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJson).resume()
            //} else {
            //    print("Error de codificación de caracteres.")
            //}
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
