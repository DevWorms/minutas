//
//  CalendarioTableViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 12/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar
import FBSDKLoginKit
import TwitterKit

class CalendarioTableViewController: UITableViewController, FSCalendarDataSource, FSCalendarDelegate, NewPendienteControllerDelegate, NewReunionViewControllerDelegate {
    
    private weak var calendar: FSCalendar!
    var agenda = [[String : AnyObject]]()
    var agendiaEvento = [String]()
    var tareas = [[String : AnyObject]]()
    var celdaActiv = CalendarioCell()
    var actividad = [String]()
    var idActividad = [Int]()
    var rowCell = Int()
    var barButton:BBBadgeBarButtonItem!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        loadCalendario()
        
        // In loadView or viewDidLoad
        let calendar = FSCalendar(frame: CGRect(x: 30, y: 0, width: (self.view.frame.size.width - 50) , height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
        
        //self.gregorian = NSCalendar(calendarIdentifier: "NSCalendarIdentifierGregorian")

        
        
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
    
    func newPendienteControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newPendienteControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadCalendario()
    }
    
    func newReunionControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newReunionControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadCalendario()
    }
    
    func revisarNotificaciones(){
        barButton.badgeValue = ""
        let activity = "NotificacionViewController"
        let vc = storyboard!.instantiateViewControllerWithIdentifier(activity) as! NotificacionesTableViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAdd(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "¿Qué deseas crear?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Crear Pendiente", style: .Default, handler: {(alert :UIAlertAction!) in
            
            self.performSegueWithIdentifier("nuevoPendiente", sender: nil)
        })
        alertController.addAction(deleteAction)
        
        let okAction = UIAlertAction(title: "Crear Junta", style: .Default, handler: {(alert :UIAlertAction!) in
            self.performSegueWithIdentifier("nuevaReunion", sender: nil)
        })
        alertController.addAction(okAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = sender.frame
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Make the background color show through
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            
           let cell = tableView.dequeueReusableCellWithIdentifier("CalendarioCell", forIndexPath: indexPath)
            return cell
            
        case 1:
            
            self.celdaActiv = tableView.dequeueReusableCellWithIdentifier("TareasCell", forIndexPath: indexPath) as! CalendarioCell
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.stringFromDate( self.calendar.today! )
            
            self.actividades(dateString)
            
            self.celdaActiv.setUpTable( idActividad, items: actividad, tvc: self )
            
            return self.celdaActiv
            
        default:
            return UITableViewCell()
        }       
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2//self.asuntos.count
    }
    
    func loadCalendario() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.calendarioMensual)\(userId)/\(apiKey)")!
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
    }
    
    func parseJson(data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        if error != nil {
            print(error!)
        } else if urlResponse != nil {
            if (urlResponse as! NSHTTPURLResponse).statusCode == HttpStatusCode.OK {
                if let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) {
                    print(json)
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.agenda.count > 0 {
                            self.agenda.removeAll()
                        }
                        
                        self.agenda.appendContentsOf(json[WebServiceResponseKey.pendientes] as! [[String : AnyObject]])
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
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
    // para cuadrar las imagenes
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 300
    }

    // MARK - Calendar
    
    func calendar(calendar: FSCalendar, subtitleForDate date: NSDate) -> String? {
        return nil
    }

    var num = 0
    
    func calendar(calendar: FSCalendar, hasEventForDate date: NSDate) -> Bool {
        
        var buleano = false
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate( date )
        
        for item in agendiaEvento {
            if item == dateString {
                buleano = true
            }
        }
        
        return buleano
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(date)
        print(dateString)
        
        self.actividades(dateString)
        
        self.celdaActiv.setUpTable( idActividad, items: actividad, tvc: self )
        
    }
    
    func actividades(fecha: String?) {
        
        actividad = [String]()
        idActividad = [Int]()
        agendiaEvento = [String]()
        tareas = [[String : AnyObject]]()
        
        for dia in agenda {
            if (dia[WebServiceResponseKey.fechaInicio] as? String) == fecha {
                actividad.append((dia[WebServiceResponseKey.nombrePendiente] as? String)!)
                idActividad.append((dia[WebServiceResponseKey.pendienteId] as? Int)!)
                tareas.append(dia)
            }
            
            agendiaEvento.append( (dia[WebServiceResponseKey.fechaInicio] as? String)! )
        }
        
        print("tareas>>>")
        print(tareas)
        
        self.calendar.reloadData()
    }
    
    @IBAction func cerrarSesion(sender: AnyObject) {
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevoPendiente" {
            
            (segue.destinationViewController as! NewPendienteViewController).idRequest = ""
            (segue.destinationViewController as! NewPendienteViewController).idRequested = 0
            (segue.destinationViewController as! NewPendienteViewController).endPointPendiente = WebServiceEndpoint.newPendiente
            (segue.destinationViewController as! NewPendienteViewController).delegate = self
            
        } else if segue.identifier ==  "nuevaReunion" {
            (segue.destinationViewController as! NewReunionViewController).delegate = self
            
        }
    }
    
    
}
