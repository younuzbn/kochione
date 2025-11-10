//
//  EatsMapState.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import Foundation
internal import Combine

class EatsMapState: ObservableObject {
    static let shared = EatsMapState()
    
    @Published var selectedCategory: String = "All"
    
    private init() {}
}

