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
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
            )
            return discoverySession.devices.first { $0.position == position }
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
        }
    }
    
    func setUpCaptureSessionInput() {
        sessionQueue.value.async {
            
            let cameraPosition: AVCaptureDevice.Position = .front
            guard let device = self.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                self.captureSession.value.beginConfiguration()
                let currentInputs = self.captureSession.value.inputs
                for input in currentInputs {
                    self.captureSession.value.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.value.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                self.captureSession.value.addInput(input)
                self.captureSession.value.commitConfiguration()
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
        let orientation: UIImage.Orientation =  .leftMirrored
        let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation) ?? UIImage()
        previewOverlayImage.accept(image)
    }
    
    
    
    
}


