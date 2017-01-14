//
//  AppDelegate.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 25/10/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import FBSDKCoreKit
import FBSDKLoginKit

// TODO: use the brand new API for networking
// TODO: remove all boiler-plate code
// TODO: implement design-patterns
// TODO: load the code released in minutes-dev

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var notificaciones = [[String : AnyObject]]()
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var updateTimer: NSTimer?
    var mostrarNotificacion: Bool!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Twitter.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
       
        let apiKeyHurry: String? = NSUserDefaults.standardUserDefaults().stringForKey("ApiKey")
        
        print("hello \( apiKeyHurry ) " )
        
        //FBSDKAccessToken.currentAccessToken() == nil
        if ( apiKeyHurry == "" || apiKeyHurry == nil ){
            print("Not logged in..")
            if FBSDKProfile.currentProfile() != nil {
                FBSDKLoginManager().logOut()
            }
            
        }else{
            print("Logged in..")
            //print("current key: \( NSUserDefaults.standardUserDefaults().stringForKey("ApiKey")!)")
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Principal") as! UITabBarController
            vc.selectedIndex = 0 //optional
            
            self.window?.rootViewController = vc
            
            /*
             let vc = storyboard.instantiateViewControllerWithIdentifier("someViewController") as! UIViewController
             self.presentViewController(vc, animated: true, completion: nil)
             */
        }

        
        // mandar notificaciones
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
      
        var tiempoPush = NSUserDefaults.standardUserDefaults().doubleForKey(ApplicationConstants.ritmoNotificaciones
        )
        
        if tiempoPush <= 1 {
            tiempoPush = ApplicationConstants.tiempoParaConsultarServicioWeb
            
            NSUserDefaults.standardUserDefaults().setObject("5.0", forKey: ApplicationConstants.ritmoNotificaciones)
            
        }
        
        
        
        
        print(tiempoPush)
        
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(tiempoPush, target: self, selector: #selector(loadNotificaciones), userInfo: nil, repeats: true)
        
        mostrarNotificacion = false
        registerBackgroundTask()

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        registerBackgroundTask()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if LISDKCallbackHandler.shouldHandleUrl(url as NSURL!) {
            return LISDKCallbackHandler.application(application, openURL: url as NSURL!, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        print("nameFile: " + url.lastPathComponent!)
        print("sourceApplication: " + sourceApplication!)
        
        var boolean: Bool = true
        
        if sourceApplication == "com.facebook.Facebook" ||      // entra a la app por FB
            (url.path == "/" &&  url.lastPathComponent == "/") {
            boolean = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return boolean
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reinstateBackgroundTask() {
        if backgroundTask == UIBackgroundTaskInvalid {
            
            loadNotificaciones()
            
            registerBackgroundTask()
        }
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            
            self.endBackgroundTask()
            
        })
        
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    
    func loadNotificaciones() {
        
        if let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey){
        
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
            //print(apiKey, userId)
            
            let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.notificaciones)\(userId)/\(apiKey)/")!
            
            //print(url)
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: parseJson).resume()
        }
        
        
        
       
    }
    
    
    func leerNotificaciones(idNotificacion:Int!) {
        
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        
        let parameterString = "\(WebServiceRequestParameter.userId)=\(userId)&\(WebServiceRequestParameter.apiKey)=\(apiKey)&\(WebServiceRequestParameter.notificaciones)=\(idNotificacion)"
        
        print(parameterString)
        
        if let httpBody = parameterString.dataUsingEncoding(NSUTF8StringEncoding) {
            let url = "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.notificacionesLeidas)"
            
            print(url)
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
            urlRequest.HTTPMethod = "POST"
            
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
                    //print(json)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        
                        if self.notificaciones.count > 0 {
                            self.notificaciones.removeAll()
                        }
                        
                        if let mensajesArray = json[WebServiceResponseKey.notificaciones] {
                            
                            //print(mensajesArray?.description)
                            if mensajesArray?.description != nil{
                                self.notificaciones.appendContentsOf(mensajesArray as! [[String : AnyObject]])
                                
                                switch UIApplication.sharedApplication().applicationState {
                                case .Active:
                                    
                                    if (self.mostrarNotificacion != nil) {
                                        print("App esta en otra pantalla")
                                        
                                    }
                                case .Background:
                                    self.mandarNotificacion()
                                    
                                    print("App is backgrounded.")
                                    print("Background notifications = \(self.notificaciones.count) seconds")
                                case .Inactive:
                                    print("App is inactive.")
                                    
                                    self.mandarNotificacion()
                                    break
                                }
                            }
                            
                            
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
                        //self.presentViewController(vc_alert, animated: true, completion: nil)
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }
    
    func mandarNotificacion(){
        
        for notificacion in self.notificaciones {
            
            if (notificacion[WebServiceResponseKey.notificacionLeida] as! Bool) == false {
                
                let txt = (notificacion[WebServiceResponseKey.notificacionText] as? String)!
                let attrStr = try! NSAttributedString(
                    data: txt.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                    documentAttributes: nil)
                
                
                
                let label = UILabel()
                label.attributedText = attrStr
                
                
                
                // create a corresponding local notification
                let notification = UILocalNotification()
                notification.alertBody = label.text // text that will be displayed in the notification
                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                
                notification.userInfo = ["title": notificacion[WebServiceResponseKey.notificacionText]!, "UUID": notificacion[WebServiceResponseKey.notificacionText]!] // assign a unique identifier to the notification so that we can retrieve it later
                
                
                self.leerNotificaciones(notificacion[WebServiceResponseKey.notificacionId] as! Int)
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
            
        }
        
    }


    

    
}
