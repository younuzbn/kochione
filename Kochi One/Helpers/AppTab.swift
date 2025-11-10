//
//  AppTab.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//


//
//  BottomBarView.swift
//  MapsBottomBar
//
//  Created by Balaji Venkatesh on 22/06/25.
//

import SwiftUI



/// Tab Enum
enum AppTab: String, CaseIterable {
    case explore = "Explore"
    case eats = "Eats"
    case play = "Play"
    case fitness = "Fitness"
    case transit = "Transit"
    
    enum CustomDetent {
        case small
        case medium
        case large
    }
    
    var symbolImage: String {
        switch self {
        case .explore:
            return "map.fill"
        case .eats:
            return "fork.knife"
        case .play:
            return "gamecontroller.fill"
        case .fitness:
            return "figure.run.treadmill"
        case .transit:
            return "tram.fill"
        }
    }
}






extension View {
    var isiOS26: Bool {
        if #available(iOS 26, *) {
            return true
        } else {
            return false
        }
    }
}


