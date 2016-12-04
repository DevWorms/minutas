
//  CategoryCollectionViewController.swift
//  Minutas
//
//  Created by Uriel Mestas Estrada on 13/11/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController, NewCategoryControllerDelegate {
    
    var categories = [[String : AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width / 2.0 - 4.0, height: view.frame.width / 2.0 - 4.0)
        
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
        
        
        performSegueWithIdentifier("categoria", sender: self)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let json = categories[indexPath.item]
        
        cell.backgroundColor = UIColor.whiteColor()
        
        let label = cell.contentView.viewWithTag(100) as? UILabel ?? UILabel()
        label.tag = 100
        label.font = UIFont.systemFontOfSize(14.0)
        cell.contentView.addSubview(label)
        label.text = json[WebServiceResponseKey.created] as? String
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraintEqualToAnchor(cell.contentView.topAnchor).active = true
        label.leadingAnchor.constraintEqualToAnchor(cell.contentView.leadingAnchor).active = true
        label.trailingAnchor.constraintEqualToAnchor(cell.contentView.trailingAnchor).active = true
        
        let nombre = cell.contentView.viewWithTag(200) as? UILabel ?? UILabel()
        nombre.numberOfLines = 0
        nombre.tag = 200
        nombre.textAlignment = .Center
        cell.contentView.addSubview(nombre)
        nombre.text = json[WebServiceResponseKey.categoryName] as? String
        nombre.translatesAutoresizingMaskIntoConstraints = false
        nombre.centerXAnchor.constraintEqualToAnchor(cell.contentView.centerXAnchor).active = true
        nombre.centerYAnchor.constraintEqualToAnchor(cell.contentView.centerYAnchor).active = true
        
        let progress = cell.contentView.viewWithTag(100) as? UIProgressView ?? UIProgressView(progressViewStyle: .Default)
        progress.tag = 300
        progress.progress = 0.5
        progress.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(progress)
        progress.leadingAnchor.constraintEqualToAnchor(cell.contentView.leadingAnchor).active = true
        progress.trailingAnchor.constraintEqualToAnchor(cell.contentView.trailingAnchor).active = true
        progress.bottomAnchor.constraintEqualToAnchor(cell.contentView.bottomAnchor).active = true
        
        return cell
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
        
        if segue.identifier == "recetarios"{
            (segue.destinationViewController as! NewCategoryViewController).delegate = self
        }
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
                    } else {
                        print("HTTP Status Code: 400 o 500")
                        print("El JSON de respuesta es inválido.")
                    }
                }
            }
        }
    }

}
