//
//  ConfiguracionViewController.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 12/01/17.
//  Copyright © 2017 Uriel Mestas Estrada. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import TwitterKit

class ConfiguracionViewController: UIViewController{
    
    @IBOutlet weak var opcionCadaSegundo: UISwitch!
    
    @IBOutlet weak var opcionCadaDiezMinutos: UISwitch!
    
    @IBOutlet weak var opcionCadaTreintaMinutos: UISwitch!
    
    @IBOutlet weak var opcionCadaHora: UISwitch!
    var barButton:BBBadgeBarButtonItem!
    override func viewDidLoad() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        /*
        appDelegate.tabBarController = tabBarController
        
        let currentIndex = appDelegate.tabBarController.selectedIndex
        if currentIndex < appDelegate.tabBarController.tabBar.items?.count{
            appDelegate.tabBarController.tabBar.items?[currentIndex].badgeValue = nil
        }*/
        
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
            
            appDelegate.updateTimer?.invalidate()
            
            appDelegate.updateTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: appDelegate, selector: #selector(appDelegate.loadNotificaciones), userInfo: nil, repeats: true)
            
            appDelegate.mostrarNotificacion = false
            appDelegate.registerBackgroundTask()

            
        }
        
        
        
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
        
        
        // Se agrega el boton con las badges pero se comparte para compartir el boton en memoria
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let imagenButton = UIImage(named: "ic_notifications_none_white_24pt")
        let btnNotificacion = UIButton(type: .Custom)
        btnNotificacion.frame = CGRectMake(0,0,imagenButton!.size.width, imagenButton!.size.height);
        
        btnNotificacion.addTarget(self, action: #selector(revisarNotificaciones), forControlEvents: UIControlEvents.TouchDown)
        btnNotificacion.setBackgroundImage(imagenButton, forState: UIControlState.Normal)
        
        
        let barButton = BBBadgeBarButtonItem(customUIButton: btnNotificacion)
        appDelegate.buttonBarController = barButton
        self.navigationItem.leftBarButtonItem = barButton
        
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
    
    @IBAction func configuracion(sender: AnyObject) {
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
}
