//
//  CaptureSession+Focus.swift
//  WeScan
//
//  Created by Julian Schiavo on 28/11/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


/// Extension to CaptureSession that controls auto focus
extension CaptureSession {
    /// Sets the camera's exposure and focus point to the given point
    func setFocusPointToTapPoint(_ tapPoint: CGPoint) throws {
        guard let device = device else {
            let error = ImageScannerControllerError.inputDevice
            throw error
        }
        
        try device.lockForConfiguration()
        
        defer {
            device.unlockForConfiguration()
        }
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            device.focusPointOfInterest = tapPoint
            device.focusMode = .autoFocus
        }
        
        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposurePointOfInterest = tapPoint
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    /// Resets the camera's exposure and focus point to automatic
    func resetFocusToAuto() throws {
        guard let device = device else {
            let error = ImageScannerControllerError.inputDevice
            throw error
        }
        
        try device.lockForConfiguration()
        
        defer {
            device.unlockForConfiguration()
        }
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(.continuousAutoExposure) {
//            device.exposureMode = .continuousAutoExposure
        }
    }
    
    enum Esposure {
         case min, normal, max
         
         func value(device: AVCaptureDevice) -> Float {
             switch self {
             case .min:
                 return device.activeFormat.minISO
             case .normal:
                 return AVCaptureDevice.currentISO
             case .max:
                 return device.activeFormat.maxISO
             }
         }
     }

     func set(exposure: Esposure) {
         guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
         if device.isExposureModeSupported(.custom) {
             do{
                 try device.lockForConfiguration()
                 device.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: exposure.value(device: device)) { (_) in
//                     print("Done Esposure")
                 }
                 device.unlockForConfiguration()
             }
             catch{
                 print("ERROR: \(String(describing: error.localizedDescription))")
             }
         }
     }
    

}
