//
//  AddCommentViewController.swift
//  Minutas
//
//  Created by Emmanuel Valentín Granados López on 17/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController {
    
    var idPaComentarios = Int()
    var endpoint = String() //
    var endpointDos = String()
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        var parameterString = ""
        var url = ""
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(self.endpointDos)=\(self.idPaComentarios)&\("comment")=\(self.textView.text)"
        url = "\(WebServiceEndpoint.baseUrl)\(self.endpoint)"
        
        
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

    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_async(dispatch_get_main_queue()) {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
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
