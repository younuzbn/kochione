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

    var body: some View {
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
