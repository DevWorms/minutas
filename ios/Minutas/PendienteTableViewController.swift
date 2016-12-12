//
//  CategoryController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 03/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class PendienteTableViewController: UITableViewController, NewPendienteControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var pendientes = [[String : AnyObject]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        
        loadPendiente()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CategoryCell
        
        let json = pendientes[indexPath.item]
        
        cell.tituloPendiente.text = json[WebServiceResponseKey.nombrePendiente] as? String
        cell.descripcionLabel.text = json[WebServiceResponseKey.descripcion] as? String
        cell.fechaInicio.text = json[WebServiceResponseKey.fechaInicio] as? String
        cell.fechaFin.text = json[WebServiceResponseKey.fechaFin] as? String
        cell.autopostergarSwictch.isOn = json[WebServiceResponseKey.autoPostergar] as! Bool
        switch json[WebServiceResponseKey.prioridad] as! Int {
            case 1:
                cell.prioridadLabel.text = "Baja"
            case 2:
                cell.prioridadLabel.text = "Media"
            case 3:
                cell.prioridadLabel.text = "Alta"
            default:
                cell.prioridadLabel.text = "Media"
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendientes.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let json = pendientes[indexPath.item]
        
        UserDefaults.standard.set(json[WebServiceResponseKey.pendienteId] as! Int, forKey: WebServiceResponseKey.pendienteId)
    }
    
    func newPendienteControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func newPendienteControllerDidFinish() {
        dismiss(animated: true, completion: nil)
        loadPendiente()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "nuevoPendiente"{
            (segue.destination as! NewPendienteViewController).delegate = self
        }
    }

    
    func loadPendiente() {
        let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
        let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
        let categoryId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.categoryId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.pendientes)\(userId)/\(apiKey)/\(categoryId)")!
        
        URLSession.shared.dataTask(with: url as URL, completionHandler: {(data, urlResponse, error) in
            
            self.parseJson(data: data as NSData?, urlResponse: urlResponse, error: error as NSError?)
        }).resume()
    }
    
    func parseJson(data: NSData?, urlResponse: URLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! HTTPURLResponse
                ).statusCode == HttpStatusCode.OK {
                if let json = try? JSonSerialization.jsonObject(with: data! as Data, options: []) {
                    print(json)
                    DispatchQueue.main.async( execute:  {
                        if self.pendientes.count > 0 {
                            self.pendientes.removeAll()
                        }
                        
                        do{
                            let json = try JSonSerialization.jsonObject(with: data! as Data, options:.allowFragments) as? [String:AnyObject]
                            self.pendientes.append(contentsOf: json?[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
                            self.tableView?.reloadData()
                        }catch{
                            print("El JSon de respuesta es inválido.")
                        }
                        
                    })

                    
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSon de respuesta es inválido.")
                }
                } else {
                    print("HTTP Status Code: 200")
                    print("El JSon de respuesta es inválido.")
                }
            } else {
                DispatchQueue.main.async( execute:  {
                
                    do{
                        
                        if let json = try JSonSerialization.jsonObject(with: data! as Data, options:.allowFragments) as? [String:AnyObject]{
                            let vc_alert = UIAlertController(title: nil, message: json[WebServiceResponseKey.message] as? String, preferredStyle: .alert)
                            vc_alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: nil))
                            self.present(vc_alert, animated: true, completion: nil)
                        } else {
                            print("HTTP Status Code: 400 o 500")
                            print("El JSon de respuesta es inválido.")
                        }
                    }catch{
                        print("El JSon de respuesta es inválido.")
                    }
                })
            }
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    
    
}
