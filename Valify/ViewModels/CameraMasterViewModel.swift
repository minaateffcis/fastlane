//
//  CameraMasterViewModel.swift
//  Valify
//
//  Created by Mina Atef on 21/08/2021.
//

import Foundation
import AVFoundation
import RxCocoa

class CameraMasterViewModel:CameraViewModel,OCRViewModel{
 
    
    var firstHit: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var foundFace: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var capturedImage : PublishRelay<UIImage> = PublishRelay()
    var makeErrorAlert: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var canTakePhoto: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var i = 1
    func captureOutput(sampleBuffer:CMSampleBuffer){
        capture(sampleBuffer: sampleBuffer)
        updatePreviewOverlayViewWithLastFrame(lastFrame: sampleBuffer)
//        detectFacesOnDevice(width: imageWidth, height: imageHeight, sampleBuffer: sampleBuffer)
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
