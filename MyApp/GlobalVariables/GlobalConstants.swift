//
//  GlobalConstants.swift
//  Tipaba
//
//  Created by Done Santana on 10/25/26.
//

import Foundation
import UIKit

struct GlobalConstants {
    static let apiKey: String = "6f6739f5d5ef4f1fa45f32e24aeb73fa5"
    static var appleId =  "6758315030"
    static var bundleId = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    static var appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "0.0"
    static let cloudKitID = "iCloud.com.bocanasa.Tipaba"
}
