//
//  HUDHelper.swift
//  Valify
//
//  Created by Mina Atef on 24/10/2021.
//

import UIKit
import PKHUD

class Hud: NSObject {
    
    class func show(on controller : UIViewController)  {
        let bluredView:UIVisualEffectView=PKHUD.sharedHUD.contentView.superview?.superview as! UIVisualEffectView
        bluredView.backgroundColor = .red
        bluredView.effect=nil
        if let top = controller.navigationController {
            HUD.show(.rotatingImage(#imageLiteral(resourceName: "loadingImage")), onView: top.view)
        } else if let top = controller.tabBarController  {
            HUD.show(.rotatingImage(#imageLiteral(resourceName: "loadingImage")), onView: top.view)
        } else {
            HUD.show(.rotatingImage(#imageLiteral(resourceName: "loadingImage")), onView: controller.view)
        }
    }
    class func showLoading()  {
        HUD.show(.progress)
    }
    
    class func hideLoading()  {
        PKHUD.sharedHUD.hide()
    }
    
    class func hide(from controller : UIViewController)  {
        PKHUD.sharedHUD.hide()
    }
    class func flashMessage(message:String,delay:TimeInterval = 1.2)  {
        HUD.flash(.label(message), delay: delay)
        if let label : UILabel = PKHUD.sharedHUD.contentView.subviews[0] as? UILabel {
            label.textColor = .blue
            label.font = UIFont.init(name: "Asap-Regular", size: 12)
        }
        let gesture = UITapGestureRecognizer(target: self, action:#selector(self.someAction (_:)))
        PKHUD.sharedHUD.contentView.addGestureRecognizer(gesture)
    }
    
    @objc class func someAction(_ sender:UITapGestureRecognizer){
        PKHUD.sharedHUD.hide()
    }
}

