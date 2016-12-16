//
//  PopVerComentarios.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 16/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//


import UIKit
import QuartzCore


@objc public class PopVerComentarios : UIViewController{
    
    var mainViewController: UIView!
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var nombrePendiente: UILabel!
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.popUpView.layer.borderWidth = 1.0
        self.popUpView.layer.masksToBounds = true
        
        self.popUpView.layer.cornerRadius = 10
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.view.backgroundColor = UIColor.clearColor()
        
        
        
        
        
    }
    
    
    
    public func showInView(aView: UIView!, nombre: String){
        
        self.mainViewController = UIView.init(frame:  CGRectMake(0.0, 0.0, aView.bounds.height, aView.bounds.maxY) )//aView.bounds)
        self.mainViewController.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        
        self.view.center = CGPointMake(aView.bounds.width/2, aView.bounds.midY)
        
        aView.addSubview( self.mainViewController )
        aView.addSubview( self.view )
        
        
        
        
        nombrePendiente.text = nombre
        
        
        self.showAnimate()
        
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.mainViewController.removeFromSuperview()
                    self.view.removeFromSuperview()
                }
        });
    }
    
    
    @IBAction func agragarComentario(sender: AnyObject) {
    }
    
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        self.removeAnimate()
    }
    
    
}
