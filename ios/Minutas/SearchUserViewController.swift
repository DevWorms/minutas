//
//  SearchUserViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 09/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

protocol NewSearchViewControllerDelegate: NSObjectProtocol {
    func newConversacionControllerDidCancel()
    func newConversacionControllerDidFinish()
}

class SearchUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    
    weak var delegate: NewSearchViewControllerDelegate?
    
    @IBOutlet weak var buttonOk: UIBarButtonItem!

    var usuarios = [String]()
    var idUsuarios = [Int]()
    var isFav = [Int]()
    var searchActive : Bool = false
    var anadirUsuarioSolamente = 0
    // 0 conversacion
    // 1 añadir usuario conversacion
    // 2 asignar usuario a pendiente
    // 3 asignar usuario tarea
    // 4 reasignar usuario tarea
    // 5 delegar tarea
    
    var caminoFavorito = false
    var idAsignar = Int()
    
    lazy var visibleResults: [String] = self.usuarios
    
    @IBOutlet weak var txtf_titulo: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtf_responsable: UISearchBar!
    
    override func viewDidLoad() {
        
        self.loadUsuarios("@")
        txtf_responsable.delegate = self
        
        if anadirUsuarioSolamente != 0 {
            txtf_titulo.hidden = true
        }
        
        if caminoFavorito == true {
            
            txtf_titulo.hidden = caminoFavorito
            buttonOk.tintColor = UIColor.clearColor()
            buttonOk.enabled = false
            
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        visibleResults = usuarios.filter({ (text) -> Bool in
            let tmp: NSString = text
            var arrayResponsables = self.txtf_responsable.text!.componentsSeparatedByString("@")
            let texto = arrayResponsables[arrayResponsables.count-1]
            let range = tmp.rangeOfString(texto, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(visibleResults.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func parseFav(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            dispatch_async(dispatch_get_main_queue()) {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .Alert)
                    vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { action in
                        if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                            self.delegate?.newConversacionControllerDidFinish()
                        }
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
    }
    
    func buttonClicked(sender:UIButton) {
        
        print(idUsuarios)
        print(sender.tag)
        
        let idU = idUsuarios[sender.tag]
        
        let isChecked = isFav[sender.tag]
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        let parameterString = "\(WebServiceRequestParameter.userIdFavoritos)=\(userId)&\(WebServiceRequestParameter.apiKeyFavoritos)=\(apiKey)&\(WebServiceRequestParameter.idFavoritos)=\(idU)"
        
        print(parameterString)
        
        var endP = ""
        
        if isChecked == 1 {
            endP = "favoritos/del"
        } else {
            endP = "favoritos/add"
        }
        
        //  self.noCellReunionPend = sender.tag
        // performSegueWithIdentifier("nuevoPendiente", sender: nil)
        
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(endP)")!)
            urlRequest.HTTPMethod = "POST"
            
            NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseFav).resume()
        } else {
            print("Error de codificación de caracteres.")
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SearchUsuarioCell
        
        cell.a.tag = indexPath.row
        cell.a.addTarget(self, action: #selector(SearchUserViewController.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        if caminoFavorito == false{
            cell.a.hidden = true
        } else {
            if isFav[indexPath.item] == 0 {
                cell.a.setImage(cell.checkedImage, forState: .Normal)
            } else {
                cell.a.setImage(cell.uncheckedImage, forState: .Normal)
            }
        }
       
        cell.txtNombreUsuario.text = visibleResults[indexPath.item]
        print(cell.txtNombreUsuario.text)
        return cell
        
    }
    
    @IBAction func ok(sender: AnyObject) {
       
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        var mensajeStr = ""
        
        if caminoFavorito == false {
        
            if let usuarios = txtf_responsable.text{
            
                if let titulo = txtf_titulo.text{
                   
                    if titulo == "" && txtf_titulo.hidden == false{
                        mensajeStr = "Debes asignar un titulo a la conversación"
                    }
                    else if usuarios == ""{
                        mensajeStr = "Debes asignar por lo menos un usuario a la conversación"
                    }
                    
                    if mensajeStr != ""{
                        let vc_alert = UIAlertController(title: "Un momento", message: mensajeStr, preferredStyle: .Alert)
                        
                        vc_alert.addAction(UIAlertAction(title: "OK",
                            style: UIAlertActionStyle.Default,
                            handler: nil))
                        self.presentViewController(vc_alert, animated: true, completion: nil)
                        

                    }else{
                        
                        var parameterString = ""
                        print(parameterString)
                        var url = ""
                        print(url)
                        
                        
                        if anadirUsuarioSolamente == 0{
                            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.usuarios)=\(usuarios)&\(WebServiceRequestParameter.titulo)=\(titulo)"
                            url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversacion)"
                        }else if anadirUsuarioSolamente == 1{
                            
                            let conversacionId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.conversacionId)
                          
                            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.conversacionId)=\(conversacionId)&\(WebServiceRequestParameter.users)=\(usuarios)"
                            url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversacionAddUser)"
                        }else if anadirUsuarioSolamente == 2{
                            
                           parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.pendienteId)=\(idAsignar)&\(WebServiceRequestParameter.usuariosAsignados)=\(usuarios)"
                            url = "\(WebServiceEndpoint.baseUrl)\("pendientes/asignar")"
                        }else if anadirUsuarioSolamente == 3{
                            
                            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.subPendienteId)=\(idAsignar)&\("user")=\(usuarios)"
                            url = "\(WebServiceEndpoint.baseUrl)\("tasks/asignar")"
                        }
                        
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
                        
                            self.delegate?.newConversacionControllerDidFinish()
                        
                        })
                    self.presentViewController(vc_alert, animated: true, completion: nil)
                } else {
                    print("El JSON de respuesta es inválido.")
                }
            }
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        delegate?.newConversacionControllerDidCancel()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return visibleResults.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var arrayResponsables = self.txtf_responsable.text!.componentsSeparatedByString("@")
        print("texto basura " + arrayResponsables.popLast()!)
        
        var responsables = ""
        print(arrayResponsables.description)
        for str in arrayResponsables {
            if(str != ""){
                responsables = responsables +  "@" + str
                print(responsables)
            }
        }
        
        let responsable =  visibleResults[indexPath.item] + ", "
        
        self.txtf_responsable.text =  responsables + responsable
        
        dismissKeyboard()
        
    }
    
    // para cuadrar las imagenes
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 81
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! GenericCell
        
        cell.aparecio = false
        
    }
    
    
    func loadUsuarios(strUsuario:String) {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        
        if caminoFavorito == true{
             var parameterString = ""
                 parameterString = "\(WebServiceRequestParameter.userIdFavoritos)=\(userId)&\(WebServiceRequestParameter.apiKeyFavoritos)=\(apiKey)&\(WebServiceRequestParameter.paramBuscar)="
            
                     
            if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
                
                let urlRequest = NSMutableURLRequest(URL: NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.buscadorTodo)")!)
                urlRequest.HTTPMethod = "POST"
                print(urlRequest)
         
                
                NSURLSession.sharedSession().uploadTaskWithRequest(urlRequest, fromData: httpBody, completionHandler: parseJsonFavo).resume()
                
            } else {
                
                print("Error de codificación de caracteres.")
            }
        }else{
            let urlStr = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.find)\(userId)/\(apiKey)/\(strUsuario)/"
            print(urlStr)
            let url = NSURL(string: urlStr)!
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonUsuarios).resume()
        }
    }
    
    func parseJsonFavo(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    //print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.usuarios.count > 0 {
                            self.usuarios.removeAll()
                            self.idUsuarios.removeAll()
                            self.isFav.removeAll()
                        }
                        print("Aqui")
                        
                        
                        let j=json[WebServiceResponseKey.buscarResult] as! [AnyObject]
                        /*
                        print(j)
                        print(j.count)
                        
                        let js = j[0]
                        print(js)
                        
                        let jss = js[3] as! [String:AnyObject]
                        print(jss)
                        */
                        print("empieza for:")
                        
                        for iUser in j {
                            
                            if iUser[0] as! String == "Usuario" {
                                if let strApodo = iUser[3][WebServiceResponseKey.apodo] as? String{
                                    self.usuarios.append(strApodo)
                                }
                                
                                if let id = iUser[3]["user_id"] as? Int {
                                    self.idUsuarios.append(id)
                                }
                                
                                if let iFav = iUser[3]["is_favorite"] as? Int {
                                    self.isFav.append(iFav)
                                }
                            }
                        }
                        
                        print("Termina")
                        //print(jsonArray[0])
                                              
                        self.visibleResults = self.usuarios
                       
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
                        NSUserDefaults.standardUserDefaults().setObject("false", forKey: "login")
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
    func parseJsonUsuarios(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.usuarios.count > 0 {
                            self.usuarios.removeAll()
                        }
                        
                        let jsonArray = json[WebServiceResponseKey.usuarios] as! [[String : AnyObject]]
                        
                        for jsonItem in jsonArray{
                            
                            if let strApodo = jsonItem[WebServiceResponseKey.apodo] as? String{
                                self.usuarios.append(strApodo)
                            }
                            
                        }
                        
                        self.visibleResults = self.usuarios
                        print(self.usuarios.description)
                        
                        
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
                        NSUserDefaults.standardUserDefaults().setObject("false", forKey: "login")
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    

}
