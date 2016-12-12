//
//  TareasTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 04/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

class TareasTableViewController: UITableViewController, NewTareaViewControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    //Esta variable viene desde menu principal y hace referencia a los menus que deben de comprarse
    
    var tareas = [[String : AnyObject]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        loadTareas()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadFile(sender: AnyObject) {
       

    }
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            
            MyFile.url = url as NSURL
            
            var fileSize : UInt64 = 0
            
            do {
                let attr : NSDictionary? = try FileManager.default.attributesOfItem( atPath: MyFile.Path ) as NSDictionary?
                
                if let _attr = attr {
                    fileSize = _attr.fileSize();
                    
                    print("fileSize: \(fileSize)")
                }
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
/*
 requestBodyData.appendString("--\(boundary)\r\n")
 requestBodyData.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=" + ( MyFile.Name ) + "\r\n")
 requestBodyData.appendString("Content-Type: \(mimeType)\r\n\r\n")
 requestBodyData.appendData( NSData(contentsOfFile: MyFile.Path )! ) //ya esta como extension
 requestBodyData.appendString("\r\n")
 requestBodyData.appendString("--\(boundary)--\r\n")
     
 */
 
    // MARK: - UIDocumentMenuDelegate
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! TareasCell
        
        let json = tareas[indexPath.item]
        
        cell.tituloTarea.text = json[WebServiceResponseKey.nombreSubPendientes] as? String
        cell.tareaCompletaSwitch.isOn = json[WebServiceResponseKey.pendienteStatus] as! Bool
       // cell.documentosAttachados.text = json[WebServiceResponseKey.fechaInicio] as? String
        
        return cell
        
    }
    
    func newTareaControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func newTareaControllerDidFinish() {
        dismiss(animated: true, completion: nil)
        loadTareas()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tareas.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        // https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
        let documentMenu = UIDocumentMenuViewController(documentTypes: [
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
            ], in: UIDocumentPickerMode.import)
        
        documentMenu.delegate = self
        
        //ipad
        documentMenu.popoverPresentationController?.sourceView = self.view
        
        self.present(documentMenu, animated: true, completion: nil)
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "nuevoTarea"{
            (segue.destination as! NewTareaViewController).delegate = self
        }
    }
    
    
    func loadTareas() {
        let apiKey = UserDefaults.standard.value(forKey: WebServiceResponseKey.apiKey)!
        let userId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.userId)
        let pendienteId = UserDefaults.standard.integer(forKey: WebServiceResponseKey.pendienteId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.tareas)\(userId)/\(apiKey)/\(pendienteId)")!
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
                        if self.tareas.count > 0 {
                            self.tareas.removeAll()
                        }
                        
                        do{
                            let json = try JSonSerialization.jsonObject(with: data! as Data, options:.allowFragments) as? [String:AnyObject]
                            self.tareas.append(contentsOf: json?[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
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
        return 100
    }
}
