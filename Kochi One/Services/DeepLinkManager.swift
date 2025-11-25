//
//  DeepLinkManager.swift
//  Kochi One
//
//  Created on 01/10/2025.
//

import Foundation
import SwiftUI
internal import Combine

enum DeepLinkType: Equatable {
    case restaurant(id: String)
    case unknown
    
    var description: String {
        switch self {
        case .restaurant(let id):
            return "restaurant(id: \(id))"
        case .unknown:
            return "unknown"
        }
    }
    
    static func == (lhs: DeepLinkType, rhs: DeepLinkType) -> Bool {
        switch (lhs, rhs) {
        case (.restaurant(let lhsId), .restaurant(let rhsId)):
            return lhsId == rhsId
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}

class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var pendingDeepLink: DeepLinkType?
    
    private init() {}
    
    // Parse URL and return deep link type
    func parseURL(_ url: URL) -> DeepLinkType {
        print("🔗 Parsing deep link URL: \(url.absoluteString)")
        print("📋 URL scheme: \(url.scheme ?? "nil")")
        print("📋 URL host: \(url.host ?? "nil")")
        print("📋 URL path: \(url.path)")
        print("📋 URL query: \(url.query ?? "nil")")
        
        guard url.scheme == "kochione" else {
            print("❌ URL scheme mismatch. Expected 'kochione', got '\(url.scheme ?? "nil")'")
            return .unknown
        }
        
        let host = url.host ?? ""
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        print("📋 Parsed host: \(host)")
        print("📋 Path components: \(pathComponents)")
        
        switch host {
        case "restaurant":
            // Extract restaurant biz_id from query parameter (preferred) or id (legacy support)
            if let bizId = url.queryParameters?["biz_id"] {
                print("✅ Extracted restaurant biz_id: \(bizId)")
                return .restaurant(id: bizId)
            } else if let id = url.queryParameters?["id"] ?? pathComponents.first {
                // Legacy support: if id is provided, use it (assuming it's biz_id)
                print("✅ Extracted restaurant ID (legacy): \(id)")
                return .restaurant(id: id)
            } else {
                print("❌ Could not extract restaurant ID from URL")
            }
        default:
            print("❌ Unknown host: \(host)")
            break
        }
        
        return .unknown
    }
    
    // Handle deep link
    func handleDeepLink(_ url: URL) {
        print("🎯 Handling deep link: \(url.absoluteString)")
        let deepLink = parseURL(url)
        if case .unknown = deepLink {
            print("❌ Deep link is unknown, not setting pendingDeepLink")
            return
        }
        print("✅ Setting pendingDeepLink: \(deepLink)")
        pendingDeepLink = deepLink
    }
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var params: [String: String] = [:]
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}

