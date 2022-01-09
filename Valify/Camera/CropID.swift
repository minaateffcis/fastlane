//
//  CropID.swift
//  Valify
//
//  Created by Mina Atef on 07/11/2021.
//

import Foundation
import UIKit
import AVFoundation

class CropID{

    static func cropToPreviewLayer(idImage:UIImageView,videoPreviewLayer:AVCaptureVideoPreviewLayer,originalImage: UIImage,complition : @escaping (UIImage) -> Void)  {
        DispatchQueue.main.async {
            let scanRect = CGRect(x: idImage.frame.origin.x, y: idImage.frame.origin.y, width: idImage.bounds.width, height: idImage.bounds.height )
            let outputRect = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
            var cgImage = originalImage.cgImage!
            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            let cropRect = CGRect(x: (outputRect.origin.x * width) - 40 , y: (outputRect.origin.y * height) - 40, width: (outputRect.size.width * width) + 80, height: (outputRect.size.height * height) + 80 )
            
            if let cgImage = cgImage.cropping(to: cropRect){
                let croppedUIImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
                complition(croppedUIImage)
            }
            
        }
        
    }
}

