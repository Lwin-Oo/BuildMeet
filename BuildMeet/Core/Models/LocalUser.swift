//
//  LocalUser.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import Foundation

struct LocalUser: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var project: String
    var status: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}


