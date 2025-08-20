//
//  Info.swift
//  TRRev
//
//  Created by pranay vohra on 20/08/25.
//

import Foundation
struct Info: Codable {

    var name: String
    var nameUpper: String 
    var phoneNo: String
    var whatsappNo: String
    var countryCode: String
    var email: String
    var gender: String
    var age: String
    var ageUnit: String
    
    enum CodingKeys: String, CodingKey {
     
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
}

extension Info{
    static var empty: Info{
        Info( name: "",nameUpper: "", phoneNo: "", whatsappNo: "", countryCode: "IN", email: "", gender: "",age: "", ageUnit: "Y")
    }
}



