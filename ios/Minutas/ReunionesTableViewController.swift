//
//  ReunionesTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class ReunionesTableViewController: UITableViewController, NewReunionViewControllerDelegate, NewMinutaViewControllerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var reuniones = [[String : AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        loadReuniones()
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
        
        let json = reuniones[indexPath.item]
        
        cell.tituloTarea.text = json[WebServiceResponseKey.nombreReunion] as? String
        cell.tareaCompletaSwitch.isOn = json[WebServiceResponseKey.pendienteStatus] as! Bool
        // cell.documentosAttachados.text = json[WebServiceResponseKey.fechaInicio] as? String
        
        return cell
        
    }
    
    func newReunionControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func newReunionControllerDidFinish() {
        dismiss(animated: true, completion: nil)
        loadReuniones()
    }
    
    func newMinutaControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func newMinutaControllerDidFinish() {
        dismiss(animated: true, completion: nil)
        loadReuniones()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reuniones.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let json = reuniones[indexPath.item]
        
        UserDefaults.standard.set(json[WebServiceResponseKey.reunionId] as! Int, forKey: WebServiceResponseKey.reunionId)
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "capturarMinutas"{
            (segue.destination as! NewMinutaViewController).delegate = self
        }else if segue.identifier ==  "nuevaReunion"{
            (segue.destination as! NewReunionViewController).delegate = self
        }
    }
    
    
    func loadReuniones() {
        let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
        let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.reuniones)\(userId)/\(apiKey)/")!
        URLSession.shared.dataTask(with: url as URL, completionHandler: {(data, urlResponse, error) in
            
            self.parseJson(data: data as NSData?, urlResponse: urlResponse, error: error as NSError?)
        }).resume()
    }
    
    func parseJson(data: NSData?, urlResponse: URLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! HTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? JSonSerialization.jsonObject(with: data! as Data, options: []) {
                    print(json)
                    
                    
                    DispatchQueue.main.async( execute:  {
                        if self.reuniones.count > 0 {
                            self.reuniones.removeAll()
                        }
                        
                        
                        do{
                            let json = try JSonSerialization.jsonObject(with: data! as Data, options:.allowFragments) as? [String:AnyObject]
                            self.reuniones.append(contentsOf: json?[WebServiceResponseKey.reuniones] as! [[String : AnyObject]])
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
    }
    
    // para cuadrar las imagenes
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 70
    }
    
    
    
}
