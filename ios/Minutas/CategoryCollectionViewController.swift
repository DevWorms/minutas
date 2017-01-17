
//  CategoryCollectionViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 13/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit

private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController, NewCategoryControllerDelegate {
    
    var categories = [[String : AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

       
        // Do any additional setup after loading the view.
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width / 2.0 - 4.0, height: view.frame.width / 2.0 - 4.0)
     
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.tabBarController = tabBarController
        
        let currentIndex = appDelegate.tabBarController.selectedIndex
        appDelegate.tabBarController.tabBar.items?[currentIndex].badgeValue = nil
        
        loadCategories()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let json = categories[indexPath.item]
        
        NSUserDefaults.standardUserDefaults().setInteger(json[WebServiceResponseKey.categoryId] as! Int, forKey: WebServiceResponseKey.categoryId)
        
        self.performSegueWithIdentifier("categoria", sender: nil)
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? CategoriaCell
        
        
        let json = categories[indexPath.item]
        
        cell!.fecha.text = json[WebServiceResponseKey.created] as? String
        
        if cell!.fecha.text != nil{
            cell!.fecha.text = "Creado: " + cell!.fecha.text!
        }
        
        cell!.nombre.text = json[WebServiceResponseKey.categoryName] as? String
        
        let idReunion = json[WebServiceResponseKey.reunionIdCategoria] as? String
        
        if (idReunion == nil){
            cell?.reunion.hidden = true
            cell?.pendientes.hidden = true
            cell!.fecha.hidden = false
            
        }else{
            cell?.reunion.hidden = false
            cell?.pendientes.hidden = false
            
            cell!.pendientes.tag = Int(idReunion!)!
            cell!.pendientes.tag = json[WebServiceResponseKey.categoryId] as! Int
            
            cell!.pendientes.addTarget(self, action: #selector(CategoryCollectionViewController.pendientes(_:)), forControlEvents: .TouchUpInside)
            cell!.reunion.addTarget(self, action: #selector(CategoryCollectionViewController.reunion(_:)), forControlEvents: .TouchUpInside)
            
            
            cell!.fecha.hidden = true
        }
        
        
        
        return cell!
    }
    
    func pendientes(sender:UIButton) {
       
        let idCategoria = sender.tag
        NSUserDefaults.standardUserDefaults().setInteger(idCategoria, forKey: WebServiceResponseKey.categoryId)
        self.performSegueWithIdentifier("categoria", sender: nil)
        
    }
    
    func reunion(sender:UIButton){
        let idCategoria = sender.tag
        NSUserDefaults.standardUserDefaults().setInteger(idCategoria, forKey: WebServiceResponseKey.categoryId)
        self.performSegueWithIdentifier("reunion", sender: nil)
        
    }
    
    func newCategoryControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func newCategoryControllerDidFinish() {
        dismissViewControllerAnimated(true, completion: nil)
        loadCategories()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the spec ified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "nuevaCategoria" {
            (segue.destinationViewController as! NewCategoryViewController).delegate = self
        } else if segue.identifier == "categoria" {
            (segue.destinationViewController as! PendienteTableViewController).initial = false
        }
    }
    
  
    
    @IBAction func usuario(sender: AnyObject) {
        
        let apodo = NSUserDefaults.standardUserDefaults().stringForKey(WebServiceResponseKey.apodo)
        
        let alertController = UIAlertController(title: "Apodo", message: apodo, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Cerrar sesión", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            self.cerrarSesion()
            
            //self.performSegueWithIdentifier("login", sender: nil)
        })
        alertController.addAction(deleteAction)
        
        let okAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            print("OK button tapped")
        })
        alertController.addAction(okAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = sender.frame
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func loadCategories() {
        let apiKey = NSUserDefaults.standardUserDefaults().valueForKey(WebServiceResponseKey.apiKey)!
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(WebServiceResponseKey.userId)
        
        print(apiKey, userId)
        
        let url = NSURL(string: "\(WebServiceEndpoint.baseUrl)\(WebServiceEndpoint.categories)\(userId)/\(apiKey)")!
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
                        if self.categories.count > 0 {
                            self.categories.removeAll()
                        }
                        
                        self.categories.appendContentsOf(json[WebServiceResponseKey.categories] as! [[String : AnyObject]])
                        self.collectionView?.reloadData()
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
                         NSUserDefaults.standardUserDefaults().setObject("false", forKey: "login")
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }

    
    func cerrarSesion(){
        
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
