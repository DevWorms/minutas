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
    

    var usuarios = [String]()
    var searchActive : Bool = false
    var anadirUsuarioSolamente = false
    
    lazy var visibleResults: [String] = self.usuarios
    
    @IBOutlet weak var txtf_titulo: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtf_responsable: UISearchBar!
    override func viewDidLoad() {
        self.loadUsuarios("@")
        txtf_responsable.delegate = self

            txtf_titulo.hidden = anadirUsuarioSolamente
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SearchUsuarioCell
        
        cell.txtNombreUsuario.text = visibleResults[indexPath.item]
        print(cell.txtNombreUsuario.text)
        return cell
        
    }
    
    
    @IBAction func ok(sender: AnyObject) {
       
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        var mensajeStr = ""
        
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
                        
                        
                        if anadirUsuarioSolamente == false{
                            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.usuarios)=\(usuarios)&\(WebServiceRequestParameter.titulo)=\(titulo)"
                            url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversacion)"
                        }else{
                            
                            let conversacionId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.conversacionId)
                          
                            parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.conversacionId)=\(conversacionId)&\(WebServiceRequestParameter.users)=\(usuarios)"
                            url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.conversacionAddUser)"
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
        
        let urlStr = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.find)\(userId)/\(apiKey)/\(strUsuario)/"
        print(urlStr)
        let url = NSURL(string: urlStr)!
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJsonUsuarios).resume()
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
