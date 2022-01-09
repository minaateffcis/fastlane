//
//  MainRepository.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation
import UIKit

class MainRepository{
    class func OCRForNationalId(firstHit:Bool,image:String,idSide:WatermarkType,completion:@escaping Handler){
        var data:[String:Any] = [:]
        switch idSide {
        case .frontCapture:
             data = [
                "back_img":"",
                "bundle_key":Constant.bundle_key,
                "check_watermark": true,
                "front_img":image
            ]
        case .backCapture:
             data = [
                "back_img":image,
                "bundle_key":Constant.bundle_key,
                "front_img":""
            ]
        }
        
        let params = [
            "document_type":"egy_nid",
            "data":data,
            
        ] as [String : Any]
        if firstHit{
            AuthRepository.getToken { response, error, isSuccess in
                if isSuccess ?? false {
                    if let response = response as? OAuthModel{
                        User.saveToken(token: response.accessToken ?? "")
                        NetworkLayer.request(path: Constant.endPoint.ocr, baseUrl: Constant.baseURL, token: response.accessToken, method: .post, params: params, headers: nil, model: BaseModel<UserModel>.self, isURLEncoding: false, completionHandler: completion)
                    }
                }else{
                    Alert.show(message: error ?? "")
                }
            }
        }else{
            let token  = User.getToken()
            NetworkLayer.request(path: Constant.endPoint.ocr, baseUrl: Constant.baseURL, token: token, method: .post, params: params, headers: nil, model: BaseModel<UserModel>.self, isURLEncoding: false, completionHandler: completion)
        }
        
    }
}
