//
//  AppEntryView.swift
//  Kochi One
//
//  Created by Muhammed Younus on 05/11/25.
//


//
//  AppEntryView.swift
//  kochione
//
//  Created by Muhammed Younus on 20/10/25.
//


import SwiftUI

struct AppEntryView: View {
    @StateObject private var versionChecker = VersionChecker()
    @State private var showUpdateSheet = true
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var showContentView = true
    @State private var deepLinkBizId: String?

    var body: some View {
        Group {
            if !showContentView, let bizId = deepLinkBizId {
                // Show detail page directly for deep link
                NavigationStack {
                    DeepLinkDetailView(bizId: bizId, showContentView: $showContentView)
                }
            } else {
                // Show normal app content
                switch versionChecker.updateState {
                case .loading:
                    ProgressView()

                case .forceUpdate:
                    UpdateView(
                        minVersion: versionChecker.minVersion,
                        latestVersion: versionChecker.latestVersion,
                        currentVersion: versionChecker.currentVersion,
                        isForceUpdate: true
                    )

                case .optionalUpdate:
                    ContentView()
                        .fullScreenCover(isPresented: $showUpdateSheet) {
                            UpdateView(
                                minVersion: versionChecker.minVersion,
                                latestVersion: versionChecker.latestVersion,
                                currentVersion: versionChecker.currentVersion,
                                isForceUpdate: false
                            )
                        }

                case .upToDate:
                    ContentView()

                case .error:
                    Text("Something went wrong. Please try again.")
                }
            }
        }
        .onAppear {
            checkDeepLink()
        }
        .onChange(of: deepLinkManager.pendingDeepLink) { oldValue, newValue in
            checkDeepLink()
        }
    }
    
    private func checkDeepLink() {
        if let deepLink = deepLinkManager.pendingDeepLink {
            switch deepLink {
            case .restaurant(let id):
                print("🔗 AppEntryView: Found restaurant deep link with ID: \(id)")
                deepLinkBizId = id
                showContentView = false
                // Clear the pending deep link after processing
                deepLinkManager.pendingDeepLink = nil
            case .unknown:
                break
            }
        }
    }
}
