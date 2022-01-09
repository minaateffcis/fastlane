//
//  Constants.swift
//  Valify
//
//  Created by Mina Atef on 21/08/2021.
//

import Foundation

enum Server{
    case Stage
    case Dev
}

class Constant{
    
    
    static let originalScale = 1.0
    static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
    static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
    static let PhotoViewController = "PhotoViewController"
    static let camerViewController = "CameraViewController"
    static let waterMarkNavigation = "WaterMarkNavigation"
    static let dataFromIDVC = "DataFromIDVC"
    static let previewCapturedImagesVC = "PreviewCapturedImages"
    static let storyboardName = "Storyboard"
    
    static var baseURL = "https://valifystage.com"
    static var username = "mina_atef"
    static var password = "sXoh2bc2UVaYXv&"
    static var client_id = "wjpvvj2MrknTR1thVXxUmuztFv68tAK6gDposB4r"
    static var client_secret = "zngRtEuS8qioREYk3m2Oi1Ai9UBiqbkpYq6tniSqreFJF4OvVgAvR4ee4qPyk3VKqnnroXVzoFP8PWpOodWyHPEAXjYuhO4psY7svmMYaCTKiqaZB9DRlkvPC4Vf70IH"
    static var bundle_key = "629bc9e6110e4fcbbe78b1bc4bdd8d36"
   static var startVC = "StartVC"
    struct endPoint{
        static let oauth = "/api/o/token/"
        static let ocr = "/api/v1/ocr/"
    }
    
    
    
    #if DEBUGSTATGING
    static var baseURL = "https://valifystage.com"
    static var password = "sXoh2bc2UVaYXv&"
    static var client_id = "wjpvvj2MrknTR1thVXxUmuztFv68tAK6gDposB4r"
    static var client_secret = "zngRtEuS8qioREYk3m2Oi1Ai9UBiqbkpYq6tniSqreFJF4OvVgAvR4ee4qPyk3VKqnnroXVzoFP8PWpOodWyHPEAXjYuhO4psY7svmMYaCTKiqaZB9DRlkvPC4Vf70IH"
    static var bundle_key = "629bc9e6110e4fcbbe78b1bc4bdd8d36"
    #else
   
    #endif
    
    static func serverType(server: Server){
        switch server{
        case .Dev:
            
            baseURL = "https://yfilav.com"
            password = "v3E46F3Utp"
            client_id = "p4f3VjNPLyZbveyoqbcUph1C8QgS1JfqkslB6IkJ"
            client_secret = "hUT5gRZC4qxhBOS3ZkwLdIEOGgEDpPaynPgLeaFJBfNOvgVLRLYyou9ykcfj0nPzYbMXV83ywcPiqVzDkPDMTdOHV6BxQKlN9HFho22GXX2Ip9j0qxvqgbMPlnjyaARC"
            bundle_key = "5e488b5a4ca942d49992822e88cca2b5"
        case .Stage:
            baseURL = "https://valifystage.com"
            password = "sXoh2bc2UVaYXv&"
            client_id = "wjpvvj2MrknTR1thVXxUmuztFv68tAK6gDposB4r"
            client_secret = "zngRtEuS8qioREYk3m2Oi1Ai9UBiqbkpYq6tniSqreFJF4OvVgAvR4ee4qPyk3VKqnnroXVzoFP8PWpOodWyHPEAXjYuhO4psY7svmMYaCTKiqaZB9DRlkvPC4Vf70IH"
            bundle_key = "629bc9e6110e4fcbbe78b1bc4bdd8d36"
        }
    }
    
}
