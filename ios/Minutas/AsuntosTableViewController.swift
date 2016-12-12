//
//  AsuntosTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class AsuntosTableViewController: UITableViewController, NewAsuntosViewControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var asuntos = [[String : AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        loadAsuntos()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! TareasCell
        
        let json = asuntos[indexPath.item]
        
        cell.tituloTarea.text = json[WebServiceResponseKey.nombreSubPendientes] as? String
        cell.tareaCompletaSwitch.isOn = json[WebServiceResponseKey.pendienteStatus] as! Bool
        // cell.documentosAttachados.text = json[WebServiceResponseKey.fechaInicio] as? String
        
        return cell
        
    }
    
    func newAsuntoControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func newAsuntoControllerDidFinish() {
        dismiss(animated: true, completion: nil)
        loadAsuntos()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.asuntos.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "crearAsunto"{
            (segue.destination as! NewAsuntosViewController).delegate = self
        }
    }
    
    
    func loadAsuntos() {
        let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
        let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
        let reunionId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.reunionId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.asuntos)\(userId)/\(apiKey)/\(reunionId)")!
        URLSession.shared.dataTask(with: url as URL, completionHandler: {(data, urlResponse, error) in
            parseJson(data: data, urlResponse: urlResponse, error: error)
        })
    }
    
    func parseJson(data: NSData?, urlResponse: URLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! HTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? JSonSerialization.jsonObject(with: data! as Data, options: []) {
                    print(json)
                    dispatch_get_main_queue().asynchronously() {
                        if self.asuntos.count > 0 {
                            self.asuntos.removeAll()
                        }
                        
                        self.asuntos.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
                        self.tableView?.reloadData()
                    }
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSon de respuesta es inválido.")
                }
            } else {
                dispatch_get_main_queue().asynchronously() {
                    if let json = try? JSonSerialization.JSonObjectWithData(data!, options: []) {
                        let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .alert)
                        vc_alert.addAction(UIAlertAction(title: "OK", style: .Cancel , handler: nil))
                        self.present(vc_alert, animated: true, completion: nil)
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSon de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
    // para cuadrar las imagenes
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 100
    }
    
    
    
}
