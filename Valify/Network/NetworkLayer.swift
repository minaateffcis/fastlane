//
//  NetworkLayer.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation
import Alamofire

typealias Handler = (_ response:Any? ,_ error:String? ,_ isSuccess:Bool?) -> Void
class NetworkLayer{
    
    class func request<T: Codable>(path : String ,baseUrl:String ,token:String?,method:Alamofire.HTTPMethod, params: [String : Any]? = nil ,headers : HTTPHeaders? = nil,encoding : ParameterEncoding = JSONEncoding.default,model: T.Type, isURLEncoding:Bool  ,completionHandler: @escaping Handler)  {
        
        if !Reachability.isConnectedToNetwork() {
            Alert.show(message: "Please check the internet connection and try again")
            return
        }
        let fullPath = "\(baseUrl)\(path)"
        
        print("fullpath \(fullPath)")
        let fullParams  = params
        var fullHeaders : HTTPHeaders = [:]
        if let headers = headers {
            fullHeaders = headers
        }
        fullHeaders["Content-Type"] = "application/json"
//        fullHeaders["Accept"] = "application/json"
        if token != nil {
            fullHeaders["Authorization"] = "Bearer \(token!)"
            
        }
//        print("Token: ",token)
        
       
        
        if isURLEncoding{
            fullHeaders["Content-Type"] = "application/x-www-form-urlencoded"
        }
//        print("path -> \(fullPath)")
        print("headers -> \(fullHeaders)")
//        print("body -> " , fullParams ?? "")
//        print("Used encoding: ",encoding)
//
        
        
        if isURLEncoding{
            
            Alamofire.request(fullPath, method: method ,parameters: fullParams,headers: fullHeaders).response { (response) in
            let decoder = JSONDecoder()
            print("code: ", response.response?.statusCode)
            
            if response.response?.statusCode == 200 {
                do{
                    let data = try decoder.decode(T.self, from: response.data! )
                    completionHandler(data,"",true)
                }catch{
                    completionHandler(nil,"",false)
                }
            }else if response.response?.statusCode == 400 {
                do{
                    let data = try decoder.decode(ErrorModel.self, from: response.data! )
                    Alert.show(message: data.message ?? "")
                    completionHandler(nil,data.message,false)
                }catch{
                    completionHandler(nil,"",false)
                }
            }
            
            // not conneted with server handle error
            if (response.error != nil) && response.response?.statusCode == nil {
                completionHandler(nil, response.error?.localizedDescription, false)
                
                return
            }
        }
        }else{
            Alamofire.request(fullPath, method: method ,parameters: fullParams, encoding: encoding,headers: fullHeaders).response { (response) in
            let decoder = JSONDecoder()
            print("code: ", response.response?.statusCode)
            
            if response.response?.statusCode == 200 {
                do{
                    let data = try decoder.decode(T.self, from: response.data! )
                    completionHandler(data,nil,true)
                }catch{
                    completionHandler(nil,nil,false)
                }
            }else {
                do{
                    let data = try decoder.decode(ErrorModel.self, from: response.data! )
//                    Alert.show(message: data.message ?? "")
                    completionHandler(nil,data.message,false)
                }catch{
                    completionHandler(nil,nil,false)
                }
            }
            
             //not conneted with server handle error
            if (response.error != nil) && response.response?.statusCode == nil {
                completionHandler(nil, response.error?.localizedDescription, false)

                return
            }
        }
        }
        
       
      
        
    }
    
}
