//
//  CaptureSession+Flash.swift
//  WeScan
//
//  Created by Julian Schiavo on 28/11/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

/// Extension to CaptureSession to manage the device flashlight
extension CaptureSession {
    /// The possible states that the current device's flashlight can be in
    enum FlashState {
        case on
        case off
        case unavailable
        case unknown
    }
    
    /// Toggles the current device's flashlight on or off.
    func toggleFlash() -> FlashState {
        guard let device = device, device.isTorchAvailable else { return .unavailable }
        
        do {
            try device.lockForConfiguration()
        } catch {
            return .unknown
        }
        
        defer {
            device.unlockForConfiguration()
        }
        
        if device.torchMode == .on {
            device.torchMode = .off
            return .off
        } else if device.torchMode == .off {
            device.torchMode = .on
            return .on
        }
        
        return .unknown
    }
    
    func openFlash(){
//        print("Open flash fire")
        guard let device = device, device.isTorchAvailable else { return }
        do {
            try device.lockForConfiguration()
        } catch {
            return
        }
        
        defer {
            device.unlockForConfiguration()
        }
        
        device.torchMode = .on
    }
    
    func turnOffFlash(completion:@escaping (Bool) -> Void){
        guard let device = device, device.isTorchAvailable else { return }
        do {
            try device.lockForConfiguration()
        } catch {
            return
        }
        
        defer {
            device.unlockForConfiguration()
        }
        
        device.torchMode = .off
        completion(true)
    }
    
    func turnOffFlashWithDelay(completion:@escaping (Bool) -> Void){
//        print("Turn Off flash  fire")
        guard let device = device, device.isTorchAvailable else { return }
        do {
            try device.lockForConfiguration()
        } catch {
            return
        }
        
        defer {
            device.unlockForConfiguration()
        }
        
        device.torchMode = .off
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//            print("Turn Off flash return")
            completion(true)
        }
        
    }
}
