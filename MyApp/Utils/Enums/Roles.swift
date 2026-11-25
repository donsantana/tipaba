//
//  Roles.swift
//  Tipaba
//
//  Created by Done Santana on 11/24/26.
//

import Foundation

enum Roles: Int, Codable, CaseIterable {
    case parent
    case clinician
    case supervisor

    var stringValue: String {
        switch self {
        case .parent: "Parent"
        case .clinician: "Clinician"
        case .supervisor: "Supervisor"
        }
    }
}
