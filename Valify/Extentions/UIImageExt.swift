//
//  UIImageExt.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation
import UIKit

public enum ImageFormat {
    case png
    case jpeg(CGFloat)
}

extension UIImage{
    func base64(format: ImageFormat) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = self.pngData()
        case .jpeg(let compression): imageData = self.jpegData(compressionQuality: compression)
        }
        return imageData?.base64EncodedString()
    }
    
    enum JPEGQuality: CGFloat {
            case lowest  = 0
            case low     = 0.25
            case medium  = 0.5
            case high    = 0.75
            case highest = 1
        }

        
    func compress(_ quality: JPEGQuality) -> UIImage? {
        return  UIImage(data: self.jpegData(compressionQuality: quality.rawValue) ?? Data())
    }
    
    func rotate(radians: CGFloat) -> UIImage {
         let rotatedSize = CGRect(origin: .zero, size: size)
             .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
             .integral.size
         UIGraphicsBeginImageContext(rotatedSize)
         if let context = UIGraphicsGetCurrentContext() {
             let origin = CGPoint(x: rotatedSize.width / 2.0,
                                  y: rotatedSize.height / 2.0)
             context.translateBy(x: origin.x, y: origin.y)
             context.rotate(by: radians)
             draw(in: CGRect(x: -origin.y, y: -origin.x,
                             width: size.width, height: size.height))
             let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
             UIGraphicsEndImageContext()

             return rotatedImage ?? self
         }

         return self
     }
    
        func rotate(radians: Float) -> UIImage? {
            var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
            // Trim off the extremely small float value to prevent core graphics from rounding it up
            newSize.width = floor(newSize.width)
            newSize.height = floor(newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
            guard let context = UIGraphicsGetCurrentContext() else {return nil}
            
            // Move origin to middle
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            // Rotate around middle
            context.rotate(by: CGFloat(radians))
            // Draw the image at its center
            self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        }
}
