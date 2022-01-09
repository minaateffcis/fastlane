//
//  DetectioTextViewModel.swift
//  Valify
//
//  Created by Mina Atef on 31/10/2021.
//

import Foundation
import Vision
import Firebase
import UIKit

protocol  DetectingTextViewModel{
    func recognizeText(image: CGImage, complition: @escaping (_ isDone:Bool?) -> Void)
}


extension DetectingTextViewModel{
    @available(iOS 13.0, *)
    func recognizeText(image:UIImage, complition: @escaping (_ isDone:Bool?) -> Void){
        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "hi"]
        let textRecognizer = vision.onDeviceTextRecognizer()
        
//        let textRecognizer = vision.cloudTextRecognizer(options: options)
        let visionImage = VisionImage(image: image)

        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else { return }
            let resultText = result.text
            print("MLKit : " + resultText)
            complition(true)
        }
        complition(false)
    }
    
    @available(iOS 13.0, *)
    func recognizeText(image: CGImage, complition: @escaping (_ isDone:Bool?) -> Void)  {
        
        var entireRecognizedText = ""
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            guard error == nil else { return  }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            if observations.count > 2{
                complition(true)
            }else{
                complition(false)
            }
            let maximumRecognitionCandidates = 1
//            print("observations: ",observations)
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }

                entireRecognizedText = "\(candidate.string)"
//                print("TEXT: ",entireRecognizedText)
                

            }
        }
        recognizeTextRequest.recognitionLanguages = ["en-US"]
        recognizeTextRequest.recognitionLevel = .fast
        let uiImage = UIImage(cgImage: image)
//        for image in images {
        
        let requestHandler = VNImageRequestHandler(cgImage: uiImage.rotate(radians: .pi/2).cgImage!, options: [:])
            
            try? requestHandler.perform([recognizeTextRequest])
//        }
        
       
    }
}
