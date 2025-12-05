//
//  DeviceIDManager.swift
//  Kochi One
//
//  Created on 27/11/25.
//

import Foundation

class DeviceIDManager {
    static let shared = DeviceIDManager()
    
    private let deviceIdKey = "user_device_id"
    
    var deviceId: String {
        if let savedId = UserDefaults.standard.string(forKey: deviceIdKey) {
            return savedId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: deviceIdKey)
            return newId
        }
    }
}

