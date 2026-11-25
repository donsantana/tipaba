//
//  User.swift
//  Tipaba
//

import Foundation

struct User: Codable, Equatable, Sendable {
    var firstname: String
    var lastname: String
    var password: String
    var phoneNumber: String
    var rol: String

    init(
        firstname: String,
        lastname: String,
        password: String,
        phoneNumber: String,
        rol: String
    ) {
        self.firstname = firstname
        self.lastname = lastname
        self.password = password
        self.phoneNumber = phoneNumber
        self.rol = rol
    }
}
