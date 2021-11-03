//
//  WiFiNames.swift
//  SweeprNative
//
//  Created by Pawel Hofman on 01/09/2021.
//  Copyright © 2021 Sweepr Technologies Limited. All rights reserved.
//

import Foundation

enum WiFiName: String {
    case unknown
    case simulator

    var ssid: String {
        switch self {
        case .simulator: return "Freak House"
        default: return "unknown"
        }
    }

    var bssid: String {
        switch self {
        case .simulator: return ""
        default: return "unknown"
        }
    }
}
