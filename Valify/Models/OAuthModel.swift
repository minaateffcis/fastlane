//
//  OAuthModel.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation

class OAuthModel:Codable{
    let accessToken:String?
    let refreshToken:String?
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}


