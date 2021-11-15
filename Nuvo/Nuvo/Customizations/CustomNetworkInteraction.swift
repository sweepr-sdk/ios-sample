//
//  ClientSDKImplementation.swift
//  SweeprNative
//
//  Created by Kaushik Venkataraman on 31/08/2021.
//  Copyright © 2021 Sweepr Technologies Limited. All rights reserved.
//

import Foundation
import Sweepr
import SweeprMobile

/**
 * Example interactor, that allows to overwrite SSID and list of devices inside the current network.
 * It could be used to test some behaviors or for simulator runs.
 */
public class CustomNetworkInteraction: NSObject {
    
    private let ssid: String
    private let bssid: String
    private let devices: [SweeprDevice]?

    public init (ssid: String, bssid: String, devices: [SweeprDevice]? = nil) {
        self.ssid = ssid
        self.bssid = bssid
        self.devices = devices
    }

    internal convenience init (wifi: WiFiName, devices: [SweeprDevice]? = nil) {
        self.init(ssid: wifi.ssid, bssid: wifi.bssid, devices: devices)
    }
}

extension CustomNetworkInteraction: SweeprInteractorDelegate {

    public var networkDescriptor: SweeprNetworkingDescriptor? {
        return self
    }

    public func getAllDevices(completion: @escaping ([SweeprDevice]?, NSError?) -> Void) {
        completion(self.devices,nil)
    }

    public func handleGenericActionStep(forAction actionName: String, resultKey: String, args: [String : Any]?, completion: @escaping ([String: Any]?, NSError?) -> Void) {
        completion(nil, nil)
    }

    public func handleScreenAction(name actionName: String, args: String?, completion: @escaping (CustomActionStatus, NSError?) -> Void) {
        completion(.success, nil)
    }
}

extension CustomNetworkInteraction: SweeprNetworkingDescriptor {
    public func fetchSSID(continuation: @escaping NetworkingDescriptorCallback) {
        continuation(ssid,.ok)
    }

    public func fetchBSSID(continuation: @escaping NetworkingDescriptorCallback) {
        continuation(bssid,.ok)
    }

    public func fetchRouterIpAddress(continuation: @escaping NetworkingDescriptorCallback) {
        continuation(nil,.ok)
    }

    public func fetchRouterMacAddress(continuation: @escaping NetworkingDescriptorCallback) {
        continuation(nil,.ok)
    }
}
