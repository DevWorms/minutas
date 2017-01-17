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

class CalendarioTableViewController: UITableViewController, FSCalendarDataSource, FSCalendarDelegate{
    
    private weak var calendar: FSCalendar!
    var agenda = [[String : AnyObject]]()
    var agendiaEvento = [String]()
    var tareas = [[String : AnyObject]]()
    var celdaActiv = CalendarioCell()
    var actividad = [String]()
    var idActividad = [Int]()
    var rowCell = Int()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        loadCalendario()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.tabBarController = tabBarController
        
        let currentIndex = appDelegate.tabBarController.selectedIndex
        if currentIndex < appDelegate.tabBarController.tabBar.items?.count{
            appDelegate.tabBarController.tabBar.items?[currentIndex].badgeValue = nil
        }
        
        // In loadView or viewDidLoad
        let calendar = FSCalendar(frame: CGRect(x: 30, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
        
        //self.gregorian = NSCalendar(calendarIdentifier: "NSCalendarIdentifierGregorian")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "pend" {
            /*
            print("tareasSegue>>>>>")
            
            let json = tareas[self.rowCell]
            print(self.rowCell)
            print(json)
            let destino = segue.destinationViewController as! PendViewController
            destino.pendienteJson = json*/
        }
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
    
    
    
}
