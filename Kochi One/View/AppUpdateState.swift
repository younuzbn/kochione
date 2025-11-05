//
//  AppUpdateState.swift
//  Kochi One
//
//  Created by Muhammed Younus on 05/11/25.
//


//
//  AppUpdateState.swift
//  kochione
//
//  Created by Muhammed Younus on 20/10/25.
//


import Foundation
internal import Combine
import UIKit

enum AppUpdateState {
    case upToDate
    case optionalUpdate
    case forceUpdate
    case loading
    case error
}

class VersionChecker: ObservableObject {
    @Published var updateState: AppUpdateState = .loading
    @Published var minVersion: String = ""
    @Published var latestVersion: String = ""
    @Published var currentVersion: String = ""
    @Published var deviceID: String = ""

    private let versionURL = URL(string: "https://firestore.googleapis.com/v1/projects/kochioneversioncontrol/databases/(default)/documents/appConfig/ios")!

    init() {
        fetchVersionInfo()
    }

    private func fetchVersionInfo() {
        URLSession.shared.dataTask(with: versionURL) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let fields = json["fields"] as? [String: Any],
                  let minVersion = (fields["minVersion"] as? [String: String])?["stringValue"],
                  let deviceID = UIDevice.current.identifierForVendor?.uuidString,
                  let latestVersion = (fields["latestVersion"] as? [String: String])?["stringValue"] else {
                
                DispatchQueue.main.async {
                    self.updateState = .error
                }
                return
            }

            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
            
            print("""
            ✅ Version details fetched successfully:
            - Minimum required: \(minVersion)
            - Latest available: \(latestVersion)
            - Current app: \(currentVersion)
            - Divice id: \(deviceID)
            """)

            DispatchQueue.main.async {
                self.minVersion = minVersion
                self.latestVersion = latestVersion
                self.currentVersion = currentVersion
                
                if currentVersion.compare(minVersion, options: .numeric) == .orderedAscending {
                    self.updateState = .forceUpdate
                } else if currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending {
                    self.updateState = .optionalUpdate
                } else {
                    self.updateState = .upToDate
                }
            }
        }.resume()
    }
}
