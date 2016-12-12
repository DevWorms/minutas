//
//  LlamadaAPI.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 01/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

class LlamadaAPI{
    
    
    func llamarApi() -> Void{
        
     
        let headers = [
            "content-type": "multipart/form-data; boundary=---011000010111000001101001",
            "cache-control": "no-cache",
            "postman-token": "3254a25c-f960-93ea-cf27-d5736267acfb"
        ]
        let parameters = [
            [
                "name": "nombre",
                "value": "Sergio"
            ],
            [
                "name": "telefono",
                "value": "5521450009"
            ],
            [
                "name": "correo",
                "value": "sergioivan155@gmail.com"
            ],
            [
                "name": "apodo",
                "value": "sergioivan154"
            ],
            [
                "name": "contrasena",
                "value": "Dascac123"
            ],
            [
                "name": "tipo_miembro",
                "value": "1"
            ]
        ]
        
        let boundary = "---011000010111000001101001"
        
        var body = ""
        var error: NSError? = nil
        for param in parameters {
            let paramName = param["name"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let filename = param["fileName"] {
                let contentType = param["content-type"]!
                
                
                do{
                    let fileContent = try String(contentsOfFile: filename, encoding: NSUTF8StringEncoding)
                    body += "; filename=\"\(filename)\"\r\n"
                    body += "Content-Type: \(contentType)\r\n\r\n"
                    body += fileContent
                    
                    var request = NSMutableURLRequest(URL: NSURL(string: "https://dev.minute.mx/api/user/register")!,
                                                      cachePolicy: .UseProtocolCachePolicy,
                                                      timeoutInterval: 10.0)
                    request.HTTPMethod = "POST"
                    request.allHTTPHeaderFields = headers
                   // request.HTTPBody = postData
                    
                    let session = URLSession.sharedSession()
                    let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                        if (error != nil) {
                            print(error)
                        } else {
                            let httpResponse = response as? NSHTTPURLResponse
                            print(httpResponse)
                        }
                    })
                    
                    dataTask.resume()

                }
                catch{
                    
                }
            } else if let paramValue = param["value"] {
                body += "\r\n\r\n\(paramValue)"
            }
        }
        

    }

    
}
