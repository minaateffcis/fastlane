//
//  UIViewControllerExt.swift
//  Valify
//
//  Created by Mina Atef on 21/08/2021.
//

import Foundation
import UIKit

extension UIViewController{
    func makeAlert(title:String,message:String,preferedStyle:UIAlertController.Style,buttonTitle:String){
        let alert = UIAlertController(title: title , message: message, preferredStyle: preferedStyle)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            @unknown default:
                print("unknown")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
