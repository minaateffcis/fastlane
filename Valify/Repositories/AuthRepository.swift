//
//  AuthRepository.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation

class AuthRepository{
    
    static func getToken(completion:@escaping Handler){
        let params = [
            "username":Constant.username,
            "password":Constant.password,
            "client_id":Constant.client_id,
            "client_secret":Constant.client_secret,
            "grant_type":"password"
        ]
        NetworkLayer.request( path: Constant.endPoint.oauth, baseUrl: Constant.baseURL, token: nil, method: .post, params: params, headers: nil, model: OAuthModel.self, isURLEncoding: true, completionHandler: completion)
    }
    
}

