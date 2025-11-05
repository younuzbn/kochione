//
//  Kochi_OneApp.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI

@main
struct Kochi_OneApp: App {
    @AppStorage("hasSeenIntro", store: UserDefaults.standard) private var hasSeenIntro: Bool = false
    var body: some Scene {
        WindowGroup {
            if hasSeenIntro {
                AppEntryView()
                    
            }
            else{
                IntroView()
                   
            }
        }
    }
}


