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

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    
    
}
