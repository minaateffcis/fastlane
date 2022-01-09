//
//  ViewHandler.swift

//
//  Created by Mina Atef on 5/1/20.
//  Copyright © 2020 Mina Atef. All rights reserved.
//

import UIKit

class viewDesignHandler: UIView {
    
    @IBInspectable var viewBorderColor:  UIColor = .darkGray {
        didSet {
            self.layer.borderColor = viewBorderColor.cgColor
            self.layer.borderWidth = 1.0
        }
    }
    
    @IBInspectable var cornerR:  CGFloat = 0 {
        didSet {
            
             self.layer.cornerRadius = cornerR
        }
    }
    
    @IBInspectable var shadow:  CGFloat = 0 {
        didSet {
            
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 1, height: shadow)
            layer.shadowOpacity = 0.2
            layer.shadowRadius = shadow
        }
    }
    
    
    
    

    

}
