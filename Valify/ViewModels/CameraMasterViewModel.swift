//
//  CameraMasterViewModel.swift
//  Valify
//
//  Created by Mina Atef on 21/08/2021.
//

import Foundation
import AVFoundation
import RxCocoa

class CameraMasterViewModel:CameraViewModel, FaceDetectionViewModel{
    var foundFace: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var capturedImage : PublishRelay<UIImage> = PublishRelay()
    var makeErrorAlert: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var canTakePhoto: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    func captureOutput(sampleBuffer:CMSampleBuffer){
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer.")
            return
        }
        capture(sampleBuffer: sampleBuffer)
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        updatePreviewOverlayViewWithLastFrame(lastFrame: sampleBuffer)
        detectFacesOnDevice(width: imageWidth, height: imageHeight, sampleBuffer: sampleBuffer)
    }
    
    
    
    func capture(sampleBuffer:CMSampleBuffer){
        if canTakePhoto.value {
            if foundFace.value{
                let capturedImage = getImageFromSampleBuffer(buffer: sampleBuffer)!
                self.capturedImage.accept(capturedImage)
            }else{
                makeErrorAlert.accept(true)
            }
            canTakePhoto.accept(false)
        }
    }
}
