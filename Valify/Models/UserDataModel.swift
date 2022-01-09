//
//  UserDataModel.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation
import UIKit


class UserModel:Codable{

    init(){}

    
    var firstName:String?
    var fullName:String?
    var street:String?
    var area:String?
    var frontNid:String?
    var serialNumber:String?
    var backNid:String?
    var expiryDate:String?
    var releaseDate:String?
    var dateOfBirth:String?
    var watermarkResponse:WatermarkResponse?
    var watermarkPlace: String?
    var scannedImage:UIImage?
    var gender:String?
    var profession:String?
    var religion:String?
    var husbandName:String?
    var maritalStatus:String?
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case fullName = "full_name"
        case street
        case area
        case frontNid = "front_nid"
        case serialNumber = "serial_number"
        case backNid = "back_nid"
        case expiryDate = "expiry_date"
        case releaseDate = "release_date"
        case dateOfBirth = "date_of_birth"
        case gender = "gender"
        case profession = "profession"
        case religion = "religion"
        case husbandName = "husband_name"
        case maritalStatus = "marital_status"
        case watermarkResponse = "watermark_response"
    }
}

class WatermarkResponse:Codable{
    var score: String?
    var label:String?
}

class User{
    static func saveToken(token:String) {
        KeychainWrapper.standard.set(token, forKey: "Token")
    }
    
    static func getToken() -> String?{
        if let token = KeychainWrapper.standard.string(forKey: "Token") {
            return token
        }else{
            return ""
        }
    }
}
