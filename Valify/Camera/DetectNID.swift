//
//  DetectNID.swift
//  Valify
//
//  Created by Mina Atef on 08/11/2021.
//

import Foundation
import Vision
import UIKit
import AVFoundation

class DetectNID{
    static var doFocus = true
    var yPoint: CGFloat = 0.0
    var firstImageDone: Bool = false
    var secondImageDone: Bool = false
    
    /// detect rectangle
    /// - Parameters:
    ///   - image: image we need to detect the rectangle in it
    ///   - complition: return if rectangle found and the rectanle data with data type rectangle observation
    private func detectRectangle(in image: CGImage,quadratureTolerance:Bool = false,complition: @escaping (Bool,VNRectangleObservation?) -> Void) {
        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                guard let results = request.results as? [VNRectangleObservation] else { return }
                if let _ = results.first{
                    complition(true,results.first!)
                    
                } else{
                    complition(false,nil)
                }
            }
        })
        //Set the value for the detected rectangle
        request.minimumAspectRatio = VNAspectRatio(0.3)
        request.maximumAspectRatio = VNAspectRatio(0.8)
        if quadratureTolerance{
            request.quadratureTolerance = VNDegrees(3)
        }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    /// detect all rectangles in the frame
    /// - Parameters:
    ///   - image: the whole image of the frame
    ///   - complition: return  array of rectangle observations
    private func detectAllRectangles(in image: CGImage,complition: @escaping ([VNRectangleObservation]) -> Void) {
        let request = VNDetectRectanglesRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                guard let results = request.results as? [VNRectangleObservation] else { return }
                complition(results)
            }
        })
        //Set the value for the detected rectangle
        request.minimumAspectRatio = VNAspectRatio(0.3)
        request.maximumAspectRatio = VNAspectRatio(0.8)
        request.minimumSize = Float(0.3)
        request.maximumObservations = 2
        //        request.quadratureTolerance = 45
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    /// detect face using vision
    /// - Parameters:
    ///   - image: image we need to detect the face in it
    ///   - complition: return if face found or not
    private func detectFace(in image: CGImage,complition: @escaping (Bool) -> Void) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    
                    complition(true)
                } else {
                    complition(false)
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    
    
    /// detect NID
    /// - Parameters:
    ///   - previewLayer: frame preview layer
    ///   - idImage: idimage is the UIImage frame that the user place the NID in it
    ///   - image: image we need to detect in it 
    ///   - complition: return if NID found or not
    func detectNID(previewLayer:AVCaptureVideoPreviewLayer,idImage:UIImageView,image:CGImage,watermarkType:WatermarkType?,complition: @escaping (Bool,String?) -> Void){
        DispatchQueue.main.async { [unowned self] in
            detectRectangle(in: image) { foundRect, rect in // first will check if recrangel found under the idImage
                if foundRect{
                    if DetectNID.doFocus{ // if found rectangle focus on it to see face clearly
                        let point = previewLayer.captureDevicePointConverted(fromLayerPoint: CGPoint(x: idImage.center.x, y: idImage.center.y))
                        CameraFocus.setFocusPoint(focusPoint: point)
                        DetectNID.doFocus = false
                    }
                    isTheIdFitTheScreen(rect, from: CIImage(cgImage: image), idImage: idImage ) { isFit in
//                        && isThereOrientation(observation: rect,from: CIImage(cgImage: image))
                        if isFit {
                            detectRectangle(in: image, quadratureTolerance: true) { foundrectwithNoTollerance, rect in
                                if foundrectwithNoTollerance{
                                    if watermarkType == .frontCapture{
                                        self.detectFace(in: image) { foundface in // check if face found
                                            complition(foundface,nil)
                                        }
                                    }else{
                                        complition(true,nil)
                                    }
                                    print("Is Fit")
                                }else{
                                    complition(false,"Do not tilt your ID")
                                }
                            }
                            
                        }else{
                            complition(false,"Move your ID closer to fit the frame.")
                            print("Not Fit")
                        }
                    }
                    
                                        
                }else{
                    DetectNID.doFocus = true
                    complition(false,"Place your ID within the frame")
                }
            }
        }
    }
    
    

    
    /// detect number of Nids i the frame
    /// - Parameters:
    ///   - buffer: frame buffer
    ///   - image: the whole frame image
    ///   - complition: return number of Nids
    func detectNumberOfNids(buffer:CVImageBuffer,image:CGImage,complition: @escaping (Int) -> Void){
        var firstImageDone = false
        var secondImageDone = false
        var rect1 : VNRectangleObservation!
        var rect2 : VNRectangleObservation!
        detectAllRectangles(in: image) { [self] rects in // detection rectangles
            if rects.count == 2{
                imageExtraction(rects[0], from: buffer) { croppedImage in // extracting first image
                    detectFace(in: croppedImage.cgImage!) { faceDetected in
                        if faceDetected{ // check if is has face or not
                            firstImageDone = true
                            rect1 = rects[0]
                            done()
                        }
                    }
                }
                imageExtraction(rects[1], from: buffer) { croppedImage in // extraction second image
                    detectFace(in: croppedImage.cgImage!) { faceDetected in
                        if faceDetected{ // check if is has face or not
                            secondImageDone = true
                            rect2 = rects[1]
                            done()
                        }
                    }
                }
            }else if rects.count == 0{
                complition(0)
                
            }else if rects.count == 1{
                imageExtraction(rects.first!, from: buffer) { croppedImage in // extracting image
                    detectFace(in: croppedImage.cgImage!) { faceDetected in
                        if faceDetected{ // check if is has face or not
                            complition(1)
                        }else{
                            
                            if isIdRatio(image:croppedImage){ // in some frames the face will not clear enough so we check if the ratio is the same as the NID
                                complition(1)
                            }else{
                                complition(0)
                            }
                        }
                    }
                }
            }
            
        }
        func done(){
            if firstImageDone && secondImageDone {
                let rectX = abs(rect1.topLeft.x - rect2.topLeft.x)
                let rectY = abs(rect1.topLeft.y - rect2.topLeft.y)
//                print("rectX: ",rectX)
//                print("rectY: ",rectY)
                if rectX > 0.25 || rectY > 0.25{
                    complition(2)
                }else{
                    complition(1)
                }
            }
        }
    }
    
    
    /// extract rectangles in new UIimage
    /// - Parameters:
    ///   - observation: rectangle found in the image
    ///   - buffer: frame buffer
    ///   - complition: return image of the rectangle
    func imageExtraction(_ observation: VNRectangleObservation,
                         from buffer: CVImageBuffer,complition: @escaping (UIImage) -> Void)  {
        var ciImage = CIImage(cvImageBuffer: buffer)
        
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        // pass filters to extract/rectify the image
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection",
                                         parameters: [
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight),
                                         ])
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        var  output = UIImage(cgImage: cgImage!)
        output = output.rotate(radians: CGFloat.pi / 2)
        complition(output)
    }
    
    func imageExtraction(_ observation: VNRectangleObservation,
                         from ciImage: CIImage,complition: @escaping (UIImage) -> Void)  {
        var ciImage = ciImage
        
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        // pass filters to extract/rectify the image
        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection",
                                         parameters: [
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight),
                                         ])
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        var  output = UIImage(cgImage: cgImage!)
        output = output.rotate(radians: CGFloat.pi / 2)
        complition(output)
    }
    
    
    /// check id the image is as the aspect ratio of the NID
    /// - Parameter image: rectangle image
    /// - Returns: true if in range of NID of and false if not
    func isIdRatio(image:UIImage) -> Bool{
        let height = image.size.height
        let width = image.size.width
        let ratio = width / height
        if ratio > 1.3 && ratio < 1.9 {
            return true
        }else{
            return false
        }
    }
    
    func isTheIdFitTheScreen(_ observation: VNRectangleObservation?,
                             from ciImage: CIImage,idImage:UIImageView,complition: @escaping (Bool) -> Void){
        guard let observation = observation , let image = idImage.image else{
            return
        }

        let rect = observationToRect(box: observation, imageView: idImage)
        let rectHeight = rect.height
        let idimageHeight = idImage.frame.height
        if ValifyInit.shared.watermarkType == . frontCapture{
            if idimageHeight  - rectHeight < 60 {
                complition(true)
            }else{
                complition(false)
            }
        }else{
            if idimageHeight  - rectHeight < 60 {
                complition(true)
            }else{
                complition(false)
            }
        }
    }
    

    
    func observationToRect(box:VNRectangleObservation,imageView:UIImageView)->CGRect
    {
        let bbBox = box.boundingBox
        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let rect = bbBox.applying(bottomToTopTransform)
        return VNImageRectForNormalizedRect(rect, Int(imageView.frame.width), Int(imageView.frame.height))
    }
    


    
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width,y: self.y * size.height)
    }
}
