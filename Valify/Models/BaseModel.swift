//
//  BaseModel.swift
//  Valify
//
//  Created by Mina Atef on 19/10/2021.
//

import Foundation
class BaseModel<T:Codable>:Codable{
    var trials_remaining:Int?
    var transaction_id:String?
    var result :T?
//    enum CodingKeys: String, CodingKey {
//        case trialRemaining = "transaction_id"
//        case transactionId = "trials_remaining"
//        case result
//    }
}

class ErrorModel:Codable{
    var message:String?
}
