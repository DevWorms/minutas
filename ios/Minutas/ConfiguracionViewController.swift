//
//  ConfiguracionViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 12/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit

class ConfiguracionViewController: UIViewController{
    
    @IBOutlet weak var opcionCadaSegundo: UISwitch!
    
    @IBOutlet weak var opcionCadaDiezMinutos: UISwitch!
    
    @IBOutlet weak var opcionCadaTreintaMinutos: UISwitch!
    
    @IBOutlet weak var opcionCadaHora: UISwitch!
    
    override func viewDidLoad() {
        let tiempoPush = NSUserDefaults.standardUserDefaults().doubleForKey(ApplicationConstants.ritmoNotificaciones)
        
        switch tiempoPush {
        case 5.0:
            opcionCadaSegundo.on = true
            opcionCadaDiezMinutos.on = false
            opcionCadaTreintaMinutos.on = false
            opcionCadaHora.on = false
            
        case 600.0:
            opcionCadaSegundo.on = false
            opcionCadaDiezMinutos.on = true
            opcionCadaTreintaMinutos.on = false
            opcionCadaHora.on = false
        case 1800.0:
            opcionCadaSegundo.on = false
            opcionCadaDiezMinutos.on = false
            opcionCadaTreintaMinutos.on = true
            opcionCadaHora.on = false
        case 3600.0:
            opcionCadaSegundo.on = false
            opcionCadaDiezMinutos.on = false
            opcionCadaTreintaMinutos.on = false
            opcionCadaHora.on = true
        default:
            opcionCadaSegundo.on = true
            opcionCadaDiezMinutos.on = false
            opcionCadaTreintaMinutos.on = false
            opcionCadaHora.on = false
            NSUserDefaults.standardUserDefaults().setObject("5.0", forKey: ApplicationConstants.ritmoNotificaciones)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.updateTimer?.invalidate()
            
            appDelegate.updateTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: appDelegate, selector: #selector(appDelegate.loadNotificaciones), userInfo: nil, repeats: true)
            
            appDelegate.mostrarNotificacion = false
            appDelegate.registerBackgroundTask()

            
        }
        
    }
    
    
    @IBAction func opSeg(sender: AnyObject) {
        if opcionCadaSegundo.on {
            opcionCadaDiezMinutos.on = false
            opcionCadaTreintaMinutos.on = false
            opcionCadaHora.on = false
        }
        else{
            if opcionCadaDiezMinutos.on == false &&
                opcionCadaTreintaMinutos.on == false &&
                opcionCadaHora.on == false{
                opcionCadaSegundo.on = true
            }
        }
        
        NSUserDefaults.standardUserDefaults().setObject("5.0", forKey: ApplicationConstants.ritmoNotificaciones)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateTimer?.invalidate()
        appDelegate.updateTimer = nil
        
        appDelegate.updateTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: appDelegate, selector: #selector(appDelegate.loadNotificaciones), userInfo: nil, repeats: true)
        
        appDelegate.mostrarNotificacion = false
        appDelegate.registerBackgroundTask()
        
    }
    
    @IBAction func opDiezM(sender: AnyObject) {
        
        if opcionCadaDiezMinutos.on {
            opcionCadaSegundo.on = false
            opcionCadaTreintaMinutos.on = false
            opcionCadaHora.on = false
        }
        else{
            if opcionCadaSegundo.on == false &&
                opcionCadaTreintaMinutos.on == false &&
                opcionCadaHora.on == false{
                opcionCadaDiezMinutos.on = true
            }
        }
        
        NSUserDefaults.standardUserDefaults().setObject("600.0", forKey: ApplicationConstants.ritmoNotificaciones)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateTimer?.invalidate()
        
        appDelegate.updateTimer = NSTimer.scheduledTimerWithTimeInterval(600.0, target: appDelegate, selector: #selector(appDelegate.loadNotificaciones), userInfo: nil, repeats: true)
        
        appDelegate.mostrarNotificacion = false
        appDelegate.registerBackgroundTask()
    }
    
    @IBAction func opTreintaM(sender: AnyObject) {
        
        if opcionCadaTreintaMinutos.on {
            opcionCadaSegundo.on = false
            opcionCadaDiezMinutos.on = false
            opcionCadaHora.on = false
        }
        else{
            if opcionCadaSegundo.on == false &&
                opcionCadaDiezMinutos.on == false &&
                opcionCadaHora.on == false{
                opcionCadaTreintaMinutos.on = true
            }
        }
        
        NSUserDefaults.standardUserDefaults().setObject("1800.0", forKey: ApplicationConstants.ritmoNotificaciones)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateTimer?.invalidate()
        
        appDelegate.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1800.0, target: appDelegate, selector: #selector(appDelegate.loadNotificaciones), userInfo: nil, repeats: true)
        
        appDelegate.mostrarNotificacion = false
        appDelegate.registerBackgroundTask()
        
    }
    
    @IBAction func opUnaHora(sender: AnyObject) {
        
        if opcionCadaHora.on {
            opcionCadaSegundo.on = false
            opcionCadaDiezMinutos.on = false
            opcionCadaTreintaMinutos.on = false
        }
        else{
            if opcionCadaSegundo.on == false &&
                opcionCadaDiezMinutos.on == false &&
                opcionCadaTreintaMinutos.on == false{
                opcionCadaHora.on = true
            }
        }
        
        NSUserDefaults.standardUserDefaults().setObject("3600.0", forKey: ApplicationConstants.ritmoNotificaciones)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateTimer?.invalidate()
        
        appDelegate.updateTimer = NSTimer.scheduledTimerWithTimeInterval(3600.0, target: appDelegate, selector: #selector(appDelegate.loadNotificaciones), userInfo: nil, repeats: true)
        
        appDelegate.mostrarNotificacion = false
        appDelegate.registerBackgroundTask()

    }
}
