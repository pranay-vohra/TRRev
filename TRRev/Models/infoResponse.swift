//
//  infoResponse.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import Foundation
struct InfoResponse: Codable {
    let id: String
    let name: String
    let nameUpper: String
    let phoneNo: String
    let whatsappNo: String
    let countryCode: String
    let email: String
    let gender: String
    let age: String
    let ageUnit: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case nameUpper = "NameUpper"
        case phoneNo = "PhoneNo"
        case whatsappNo = "WhatsappNo"
        case countryCode = "CountryCode"
        case email = "Email"
        case gender = "Gender"
        case age = "Age"
        case ageUnit = "AgeUnit"
    }
    

    func toInfo() -> Info {
        return Info(
            name: name,
            nameUpper: nameUpper,
            phoneNo: phoneNo,
            whatsappNo: whatsappNo,
            countryCode: countryCode,
            email: email,
            gender: gender,
            age: age,
            ageUnit: ageUnit
        )
    }
}


struct ODataResponse: Codable {
    let d: InfoResponse
}

