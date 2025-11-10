//
//  MetroMapState.swift
//  Kochi One
//
//  Created by Muhammed Younus on 07/11/25.
//

import Foundation
import CoreLocation
internal import Combine

// MARK: - Metro Map State
class MetroMapState: ObservableObject {
    @Published var showMetroStations: Bool = false
    @Published var fromStation: MetroStation?
    @Published var toStation: MetroStation?
    @Published var isMetroTabActive: Bool = false
    @Published var selectedTrip: MetroTrip?
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var trainPosition: CLLocationCoordinate2D?
    @Published var stationsInRoute: [MetroStation] = []
    
    static let shared = MetroMapState()
    
    private init() {}
    
    func clearRoute() {
        selectedTrip = nil
        routeCoordinates = []
        trainPosition = nil
        stationsInRoute = []
    }
}

