//
//  CameraFoucus.swift
//  Valify
//
//  Created by Mina Atef on 08/11/2021.
//

import Foundation
import UIKit

class CameraFocus{
    static func setFocusPoint(focusPoint:CGPoint){
        do {
//            print("focus point:", focusPoint)
            try CaptureSession.current.setFocusPointToTapPoint(focusPoint)
        } catch {
            Alert.show(message: "Focus Error Occured")
        }
    }
}

