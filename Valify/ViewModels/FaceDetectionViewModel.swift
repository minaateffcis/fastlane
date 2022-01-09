//
//  FaceDetectionViewModel.swift
//  Valify
//
//  Created by Mina Atef on 21/08/2021.
//

import Foundation
import MLKit
import RxCocoa

protocol FaceDetectionViewModel {
    var foundFace: BehaviorRelay<Bool>{ get set }
    func detectFacesOnDevice( width: CGFloat, height: CGFloat,sampleBuffer:CMSampleBuffer)
   
}

extension FaceDetectionViewModel{

    func detectFacesOnDevice( width: CGFloat, height: CGFloat,sampleBuffer:CMSampleBuffer) {
      let options = FaceDetectorOptions()
      options.landmarkMode = .none
      options.contourMode = .all
      options.classificationMode = .none
      options.performanceMode = .fast
      let faceDetector = FaceDetector.faceDetector(options: options)
      var faces: [Face]
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = UIUtilities.imageOrientation(
            fromDevicePosition: .front
        )
        visionImage.orientation = orientation
      do {
        faces = try faceDetector.results(in: visionImage)
      } catch let error {
        print("Failed to detect faces with error: \(error.localizedDescription).")
        return
      }
        
      guard !faces.isEmpty else {
        print("On-Device face detector returned no results.")
        foundFace.accept(false)
        return
      }
        foundFace.accept(true)
    }
    
   
    
}
