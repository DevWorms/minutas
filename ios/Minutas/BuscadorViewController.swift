//
//  BuscadorViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 13/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation

class BuscadorViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    
    var resultados = NSArray()
    var searchActive : Bool = false
    
    lazy var visibleResults: NSArray! = self.resultados
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtf_busqueda: UISearchBar!
    
    override func viewDidLoad() {
        
        self.loadBusqueda("")
        //txtf_busqueda.delegate = self
        
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
    
   /* func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        visibleResults = resultados.filter({ (text) -> Bool in
            let tmp: NSString = text[0]
            var arrayResponsables = self.txtf_busqueda.text!.componentsSeparatedByString("@")
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
    }*/
    
    // Make the background color show through
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
      
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! BuscadorCell
        
        
        
        let json = resultados[indexPath.item] as! NSArray
        print(json[0])
        
        
        
        
        let tipo = json[0] as? String
        let texto = json[1] as? String
        let url = json[2] as? String
        //let informacionArray = json[3] as? [String]
 
        
        cell.nombreBusqueda.text = texto
        cell.tipoBusqueda.text = tipo
        print(json.description)
        print(cell.nombreBusqueda.text)
        return cell
        
    }
    
    
        
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return visibleResults.count
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        let vc = storyboard!.instantiateViewControllerWithIdentifier("LogInViewController")
        self.presentViewController( vc , animated: true, completion: nil)

        
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
    
    @IBAction func buscar(sender: AnyObject) {
        if let busqueda = self.txtf_busqueda.text{
            self.loadBusqueda(busqueda)
        }
        dismissKeyboard()
    }
    
    func loadBusqueda(strUsuario:String) {
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        var busquedaStr = ""
        if strUsuario != ""{
            busquedaStr = "&\(WebServiceRequestParameter.busqueda)=\(strUsuario)"
        }
        
        let parameterString = "\(WebServiceRequestParameter.userIdmin)=\(userId)&\(WebServiceRequestParameter.apiKeymin)=\(apiKey)" + busquedaStr
        
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.buscadorTodo)"
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
            urlRequest.HTTPMethod = "POST"
            print(url, parameterString)
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
                        if self.resultados.count > 0 {
                            self.resultados = NSArray()
                            self.visibleResults = NSArray()
                        }
                        
                         let jsonResultados = json[WebServiceResponseKey.resultados] as? NSArray
                        print(jsonResultados![0])
                        /* let tipo = jsonResultados![0]
                         let texto = jsonResultados![1]
                         let url = jsonResultados![2]
                         //let informacionArray = jsonResultados![3] as? [String]*/
                        
                        self.resultados = (json[WebServiceResponseKey.resultados] as? NSArray)!
                        
                        self.visibleResults = self.resultados
                        print(self.visibleResults.count)
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
