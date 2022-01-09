//
//  OCRViewModel.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol OCRViewModel {
    var firstHit: BehaviorRelay<Bool>{ get set }
    func getDataFromImage(image:UIImage,idSide:WatermarkType,firstHit:Bool,imagePlace:ImagePlace)
}
class OCRData{
    static var OCRDataArr: PublishRelay<UserModel> = PublishRelay()
    static var counter = 0
    static var OCRArray = [UserModel]()
    static var responseCount = 4
    static var errorMessages = [String]()
    static var error: PublishRelay<Bool> = PublishRelay()
    static func getWatermarkPlace(imagePlace:ImagePlace) -> String{
        switch imagePlace {
        case .top:
            return "Top"
        case .middle:
            return "Middle"
        case .bottom:
            return "Bottom"
        case .topMiddle:
            return "Top Middle"
        case .bottomMiddle:
            return "Bottom Middle"
        }
        
    }
    
    static func clearStaticData(){
        OCRDataArr = PublishRelay()
        counter = 0
        OCRArray = [UserModel]()
        responseCount = 4
        errorMessages = [String]()
        error = PublishRelay()
    }
}
enum IdSide{
    case front
    case back
}

extension OCRViewModel{
    
    func getDataFromImage(image:UIImage,idSide:WatermarkType,firstHit:Bool,imagePlace:ImagePlace){
        if firstHit{
            OCRData.counter = 0
            OCRData.OCRArray = []
        }
        DispatchQueue.global(qos: .userInteractive).async {
            MainRepository.OCRForNationalId(firstHit: firstHit, image: image.base64(format: .jpeg(1)) ?? "", idSide: idSide) { response, error, isSuccess in
                if let data = response as? BaseModel<UserModel>{
                    if data.result != nil{
                        data.result?.scannedImage = image
                        data.result?.watermarkResponse?.score = watermarkScoreToText(score:data.result?.watermarkResponse?.score)
                        data.result?.watermarkPlace = OCRData.getWatermarkPlace(imagePlace:imagePlace)
                        OCRData.OCRArray.append(data.result!)
                    }
                    
                }
                OCRData.counter += 1
                if error != nil{
                    OCRData.errorMessages.append(error ?? "")
                }
                
                if OCRData.counter == OCRData.responseCount{
                    if OCRData.OCRArray.count == 0 {
                        OCRData.error.accept(true)
                    }
                    for data in OCRData.OCRArray {
                        OCRData.OCRDataArr.accept(data)
                        OCRData.counter = 0
                        OCRData.OCRArray = []
                    }
                }
            }
        }
    }
    
    func watermarkScoreToText(score:String?) -> String{
        guard let score = score else{
            return "NULL"
        }
        for (index, char) in score.enumerated() {
            print("index = \(index), character = \(char)")
            if index == 4 && char == "1"{
                return "Date"
            }else if index == 7 && char == "1"{
                return "Eagle"
            }
        }
        return "NULL"
    }
    
    
    
}
