//
//  BuscadorViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 13/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import TwitterKit

class BuscadorViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    
    var resultados = NSArray()
    var searchActive : Bool = false
    
    lazy var visibleResults: NSArray! = self.resultados
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtf_busqueda: UISearchBar!
    var barButton: BBBadgeBarButtonItem!
    override func viewDidLoad() {
        
        
        self.loadBusqueda("")
        txtf_busqueda.delegate = self
        
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let imagenButton = UIImage(named: "ic_notifications_none_white_24pt")
        let btnNotificacion = UIButton(type: .Custom)
        btnNotificacion.frame = CGRectMake(0,0,imagenButton!.size.width, imagenButton!.size.height);
        
        btnNotificacion.addTarget(self, action: #selector(revisarNotificaciones), forControlEvents: UIControlEvents.TouchDown)
        btnNotificacion.setBackgroundImage(imagenButton, forState: UIControlState.Normal)
        
        
        barButton = BBBadgeBarButtonItem(customUIButton: btnNotificacion)
        appDelegate.buttonBarController = barButton
        self.navigationItem.leftBarButtonItem = barButton
        
    }
    
    func revisarNotificaciones(){
        
        barButton.badgeValue = ""
        let activity = "NotificacionViewController"
        let vc = storyboard!.instantiateViewControllerWithIdentifier(activity) as! NotificacionesTableViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
        
        
    }
    
    @IBAction func cerrarSesion(sender: AnyObject) {
        
        let apodo = NSUserDefaults.standardUserDefaults().stringForKey(WebServiceResponseKey.apodo)
        
        let alertController = UIAlertController(title: "Apodo", message: apodo, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Cerrar sesión", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            self.cerrarSesion()
            
            //self.performSegueWithIdentifier("login", sender: nil)
        })
        alertController.addAction(deleteAction)
        
        let okAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            print("OK button tapped")
        })
        alertController.addAction(okAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = sender.frame
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func cerrarSesion(){
        
        let redSocial = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.redSocial)! as! String
        
        //Cierra la sesion activa en caso de que exista para poder iniciar sesion con una red social diferente
        switch redSocial {
        case "fb":
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            print("Sesion Cerrada en FB")
            
        case "tw":
            Twitter.sharedInstance().logOut()
            print("Sesion Cerrada en TW")
        case "in":
            LISDKAPIHelper.sharedInstance().cancelCalls()
            LISDKSessionManager.clearSession()
            print("Sesion Cerrada en IN")
        default:
            print("No hay necesidad de cerrar sesión " +  redSocial)
        }
        
        
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.apodo)
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.token)
        NSUserDefaults.standardUserDefaults().setObject("", forKey: WebServiceResponseKey.redSocial)
        
        let vc = storyboard!.instantiateViewControllerWithIdentifier("LogInViewController")
        self.presentViewController( vc , animated: true, completion: nil)
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
        if let textoBusqueda = txtf_busqueda.text{
                self.loadBusqueda(textoBusqueda)
        }
        
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
        if let opcion = tipo{
            switch opcion {
                case "pendiente":
                    cell.selectionStyle = .Default
                break
                case "tarea":
                    cell.selectionStyle = .Default
                break
                case "reunion":
                    cell.selectionStyle = .Default
                break
                default:
                    cell.selectionStyle = .None
                break
            }
        }
        
        
    
    
    

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

        
        let json = resultados[indexPath.item] as! NSArray
       
        if let tipo = (json[0] as? String)?.lowercaseString {
            if let texto = (json[1] as? String)?.lowercaseString {
                if let url = (json[2] as? String)?.lowercaseString {
                    let jsonArray = json[3] as? [String : AnyObject]
                    var activity = ""
                    print(tipo, texto, url, jsonArray?.description)
                    
                    var categoria = ""
                    var pendienteIdBuscado = jsonArray![WebServiceResponseKey.userIdMin] as? Int
                    if pendienteIdBuscado == nil || pendienteIdBuscado <= 0 {
                        pendienteIdBuscado = jsonArray!["id_user"] as? Int
                    }
                    
                    let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
                    print(pendienteIdBuscado, userId)
                    if url != "" && url != "#"{
                        var arrayUrl = url.componentsSeparatedByString("#")
                        
                        if arrayUrl.count > 1{
                            print("texto basura " + arrayUrl.popLast()!)
                        }
                        
                        var arrayUrlStr = arrayUrl.popLast()!.componentsSeparatedByString("/")
                        
                        categoria = arrayUrlStr.popLast()!
                        print("categoria " + categoria)
                        
                    }
                    
                    if userId == pendienteIdBuscado{
                        
                        switch tipo {
                            case "pendiente":
                                activity = "PenientesViewController"
                                /* var pendienteJson = [String : AnyObject]()
                        
                                pendienteJson[WebServiceResponseKey.pendienteId] = jsonArray![WebServiceResponseKey.pendienteId] as! Int
                                 
                                 pendienteJson[WebServiceResponseKey.fechaFin] = jsonArray![WebServiceResponseKey.fechaFin] as! String
                                 
                                 pendienteJson[WebServiceResponseKey.pendienteStatus] = jsonArray![WebServiceResponseKey.pendienteStatus] as! Bool
                                 
                                 pendienteJson[WebServiceResponseKey.prioridad] = jsonArray![WebServiceResponseKey.prioridad] as! Int
                                 
                                 pendienteJson[WebServiceResponseKey.descripcion] = jsonArray![WebServiceResponseKey.descripcion] as! String
                                 
                                 pendienteJson[WebServiceResponseKey.usuariosAsignados] = ""
                                 //jsonArray![WebServiceResponseKey.usuariosAsignados]
                                 
                                 print(pendienteJson.description)*/
                                
                                let categoriaId = jsonArray![WebServiceResponseKey.categoryIdMin]
                                if categoriaId != nil{
                                    NSUserDefaults.standardUserDefaults().setObject(categoriaId, forKey: WebServiceResponseKey.categoryId)
                                }else{
                                    NSUserDefaults.standardUserDefaults().setObject(categoria, forKey: WebServiceResponseKey.categoryId)
                                    
                                }
                                
                                let vc = storyboard!.instantiateViewControllerWithIdentifier(activity) as! PendienteTableViewController
                                vc.initial = false
                                
                                vc.idPendiente = jsonArray![WebServiceResponseKey.pendienteId] as! Int
                                print(vc.idPendiente, categoriaId)
                                self.navigationController!.pushViewController(vc, animated: true)
                            break
                        case "tarea":
                            activity = "TareasViewController"
                            let vc = storyboard!.instantiateViewControllerWithIdentifier(activity) as! TareasTableViewController
                            vc.idTarea = jsonArray![WebServiceResponseKey.subPendienteId] as! Int
                            
                            self.navigationController!.pushViewController(vc, animated: true)
                            break
                        case "reunion":
                            activity = "ReunionesViewController"
                            let vc = storyboard!.instantiateViewControllerWithIdentifier(activity) as! ReunionesTableViewController

                            
                            print(jsonArray)
                            var json =  [[String : AnyObject]]()
                            json.append(jsonArray!)
                            vc.reuniones = json
                            
                            self.navigationController!.pushViewController(vc, animated: true)
                            break
                        default:
                            
                            break
                        }
                    
                    
                    
                    }

                   // self.presentViewController( vc , animated: true, completion: nil)

                }
            }
        }
        
        
        
        
        
        
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
                        if jsonResultados?.count > 0 {
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
