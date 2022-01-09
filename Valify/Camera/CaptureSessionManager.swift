//
//  CaptureManager.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import CoreMotion
import AVFoundation
import UIKit
import RxSwift

/// A set of functions that inform the delegate object of the state of the detection.
protocol RectangleDetectionDelegateProtocol: NSObjectProtocol {
    
    
    
    /// this delegate will fire in every frame we use (after we skip some frames )
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, image: UIImage?)
    
    /// will fire with TRUE when Nid found and FALSE if not found
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, isNidFound: Bool,message:String?)
    
    /// will fire if tow Nids found
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, towNidsFound: Bool)
    
    /// will fire if Nid removed
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, nidRemoved: Bool)
    
    /// whill fire when the image captured
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage)

}

/// The CaptureSessionManager is responsible for setting up and managing the AVCaptureSession and the functions related to capturing.
 class CaptureSessionManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let videoPreviewLayer: AVCaptureVideoPreviewLayer
    let captureSession = AVCaptureSession()
    weak var delegate: RectangleDetectionDelegateProtocol?
    private var photoOutput = AVCapturePhotoOutput()
     var autoFlash = true // true is autoflash selected and false if user selected flash on or off
    var startDoNotRemoveNid = false
    private var noOfFrames = 8 // number of frames i will skip in the camera session
    var currentImage: UIImage? // every cropped image inside the Idimage will be in this variable
    private var framesCounter = 0 // count frames to skip some frames
    var numberOfFramesWithoutNid = 0
    var numberOfFrameOfTowNids = 0
    var numberOfFrameOfOneNid = 0
    var foundNID = false
    var imageView :UIImageView! // idImage will set in this variable to calculate its position
    var detectNId = DetectNID()
    var stopCaptureImages = false
     var turnOffFlashFlag = false
     var turnOffFlashFrameCounter = 0
    // MARK: Life Cycle
    
    init?(videoPreviewLayer: AVCaptureVideoPreviewLayer) { // setup camera
        self.videoPreviewLayer = videoPreviewLayer
        super.init()
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return nil
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1920x1080
        //        captureSession
        photoOutput.isHighResolutionCaptureEnabled = true
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.connections.first?.videoOrientation = .portrait
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        defer {
            device.unlockForConfiguration()
            captureSession.commitConfiguration()
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(deviceInput),
              captureSession.canAddOutput(photoOutput),
              captureSession.canAddOutput(videoOutput) else {

                  return
              }
        
        do {
            try device.lockForConfiguration()
        } catch {
 
        }
        
        device.isSubjectAreaChangeMonitoringEnabled = true
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        //
        videoPreviewLayer.session = captureSession
        //        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_ouput_queue"))
    }
    
    
    
    
    // MARK: Capture Session Life Cycle
     
     /// start capture session
    func start() {
        weak var weakSelf = self
        DispatchQueue.main.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.sessionPreset = .hd1920x1080
            strongSelf.captureSession.startRunning()
        }
    }

    func stop() { // stop capture session
        stopCaptureImages = true
        captureSession.stopRunning()
        CaptureSession.current.turnOffFlash { turnedOff in
            
        }
    }
     
    
    func capturePhoto(imagePlace:ImagePlace) {
        
        
        if imagePlace == .middle{
            
            if autoFlash{
                
                CaptureSession.current.turnOffFlash { [unowned self] turnedOff in // turn off flash in the middle frame capture
                    if turnedOff{
                        turnOffFlashFlag = true
                        
//                        delegate?.captureSessionManager(self, didCapturePicture: currentImage ?? UIImage())
                    }
                }
            }else{
                delegate?.captureSessionManager(self, didCapturePicture: currentImage ?? UIImage())
            }
        }else{
            delegate?.captureSessionManager(self, didCapturePicture: currentImage ?? UIImage())
        }
        
    }
     
     func captureMiddel(){
         if turnOffFlashFrameCounter == 4{
             delegate?.captureSessionManager(self, didCapturePicture: currentImage ?? UIImage())
             turnOffFlashFrameCounter = 0
             turnOffFlashFlag = false
         }
         
     }
     
     func printNowTime(message:String){
         let date = Date()
         let formatter = DateFormatter()
         formatter.dateFormat = "HH:mm:ss.SSSS"
         print(message,": ",formatter.string(from: date))
     }
    

    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        
        guard  let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        
        
        
//        let imageSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        
        if framesCounter % noOfFrames == 0 {
            if turnOffFlashFlag{
                turnOffFlashFrameCounter += 1
                captureMiddel()
                
            }

            let image = UIUtilities.createUIImage(from: imageBuffer,orientation: .right) ?? UIImage()
            
            DispatchQueue.main.sync { [unowned self] in
                detectNId.detectNumberOfNids(buffer: imageBuffer, image: image.cgImage!) { noOfNIDs in
                    switch noOfNIDs{
                    case 0:
                        numberOfFramesWithoutNid += 1
                        numberOfFrameOfOneNid = 0
                        numberOfFrameOfTowNids = 0
                        if startDoNotRemoveNid{
                            if numberOfFramesWithoutNid >= 5{
                                if !foundNID {
                                    delegate?.captureSessionManager(self, nidRemoved: true)
                                }
                            }
                        }
                    case 1:
                        numberOfFramesWithoutNid = 0
                        numberOfFrameOfTowNids = 0
                        numberOfFrameOfOneNid += 1
                        
                        if numberOfFrameOfOneNid == 2{
                            startDoNotRemoveNid = true
                        }
                        
                    case 2:
                        numberOfFrameOfOneNid = 0
                        numberOfFramesWithoutNid = 0
                        numberOfFrameOfTowNids += 1
                        if numberOfFrameOfTowNids == 4{
                            delegate?.captureSessionManager(self, towNidsFound: true)
                        }
                        
                    default:
                        break
                    }
                }
            }
            
            
//            if !stopCaptureImages{
            CropID.cropToPreviewLayer(idImage: imageView, videoPreviewLayer: videoPreviewLayer, originalImage: image) { [self] cropedImage in
                detectNId.detectNID(previewLayer: videoPreviewLayer, idImage:imageView,image: cropedImage.cgImage!, watermarkType: ValifyInit.shared.watermarkType) { foundNID,message  in
                    self.foundNID = foundNID
                    if !turnOffFlashFlag{
                        if foundNID{
                            delegate?.captureSessionManager(self, isNidFound: true,message:nil)
                        }else{
                            delegate?.captureSessionManager(self, isNidFound: false,message:message)
                        }
                    }
                    currentImage = cropedImage
                }
                
                delegate?.captureSessionManager(self, image: cropedImage)
            }
//        }
            
        }
        framesCounter += 1
    }
    
    
}


