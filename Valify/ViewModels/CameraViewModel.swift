//
//  CameraViewModel.swift
//  Valify
//
//  Created by Mina Atef on 21/08/2021.
//

import Foundation
import AVFoundation
import RxCocoa


class CameraViewModel{
    
    var captureSession:BehaviorRelay<AVCaptureSession> = BehaviorRelay(value: AVCaptureSession())
    var sessionQueue :BehaviorRelay<DispatchQueue> = BehaviorRelay(value: DispatchQueue(label: Constant.sessionQueueLabel))
    var previewOverlayImage : BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage())
    var cameraDevice :AVCaptureDevice?
    
    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func startSession() {
        weak var weakSelf = self
        sessionQueue.value.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.value.sessionPreset = .hd1920x1080
            strongSelf.captureSession.value.startRunning()
        }
    }
    
    func stopSession() {
        weak var weakSelf = self
        sessionQueue.value.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            strongSelf.captureSession.value.stopRunning()
        }
    }
    func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInDualCamera,.builtInWideAngleCamera,.builtInTrueDepthCamera],
                mediaType: .video,
                position: .back
            )
            let device =  discoverySession.devices.first { $0.position == position }
            try? device?.lockForConfiguration()
//            try? device?.setTorchModeOn(level: 1.0)
            device?.isSubjectAreaChangeMonitoringEnabled = true
            device?.focusMode = .continuousAutoFocus
            device?.exposureMode = .continuousAutoExposure
            device?.unlockForConfiguration()
            return device
        }
        return nil
    }
    
    

    
    func setUpCaptureSessionOutput(delegate:AVCaptureVideoDataOutputSampleBufferDelegate) {
        
        sessionQueue.value.async {
            
            self.captureSession.value.beginConfiguration()
            self.captureSession.value.sessionPreset = AVCaptureSession.Preset.medium
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
            output.setSampleBufferDelegate(delegate , queue: outputQueue)
            guard self.captureSession.value.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            self.captureSession.value.addOutput(output)
            self.captureSession.value.commitConfiguration()
            
            
            
//            self.openTorch()
            
//            let avDevice = AVCaptureDevice.default(for: AVMediaType.video)
//            try avDevice?.lockForConfiguration()
//            avDevice?.focusMode = .continuousAutoFocus
//            avDevice?.setTorchModeOn(level: 1.0)
//            avDevice?.unlockForConfiguration()
//            device.focusMode = .continuousAutoFocus
//            device.exposureMode = .continuousAutoExposure
           
        }
    }
    
    
    
    func setTorch(){
//        let cameraPosition: AVCaptureDevice.Position = .back
//        guard let device = self.captureDevice(forPosition: cameraPosition) else {
//            print("Failed to get capture device for camera position: \(cameraPosition)")
//            return
//        }
        try? cameraDevice?.lockForConfiguration()
        try? cameraDevice?.setTorchModeOn(level: 1.0)
        cameraDevice?.isSubjectAreaChangeMonitoringEnabled = true
        cameraDevice?.focusMode = .continuousAutoFocus
        cameraDevice?.exposureMode = .continuousAutoExposure
        cameraDevice?.unlockForConfiguration()
    }
    
    func turnOffTourch(completion: (_ success: Bool) -> Void){
        try? cameraDevice?.lockForConfiguration()
        cameraDevice?.torchMode = .off
        cameraDevice?.unlockForConfiguration()
        completion(true)
    }
    
    func setUpCaptureSessionInput() {
        sessionQueue.value.async { [unowned self] in
            
            let cameraPosition: AVCaptureDevice.Position = .back
            
            guard let device = self.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            cameraDevice = device
            do {
                
//
                self.captureSession.value.beginConfiguration()
                
                let currentInputs = self.captureSession.value.inputs
                for input in currentInputs {
                    self.captureSession.value.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: cameraDevice!)
                guard self.captureSession.value.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                
                self.captureSession.value.addInput(input)
                self.captureSession.value.commitConfiguration()
//                self.setTorch()
                
               
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    func updatePreviewOverlayViewWithLastFrame(lastFrame:CMSampleBuffer?) {
        DispatchQueue.main.sync {
            guard let lastFrame = lastFrame,
                  let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
            else {
                return
            }
            updatePreviewOverlayViewWithImageBuffer(imageBuffer)
        }
    }
    
    func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
        guard let imageBuffer = imageBuffer else {
            return
        }
//        setTorch()
        let orientation: UIImage.Orientation =  .right
        let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation) ?? UIImage()
//        image.fra
        previewOverlayImage.accept(image)
    }
    

    
    
    
    
}


