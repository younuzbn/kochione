//
//  MetroDataService.swift
//  Kochi One
//
//  Created by Muhammed Younus on 07/11/25.
//

import Foundation
import CoreLocation
internal import Combine

// MARK: - Metro Station Model
struct MetroStation: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let zoneId: String
    var nameMalayalam: String?
    var nameHindi: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Equatable conformance - compare by id
    static func == (lhs: MetroStation, rhs: MetroStation) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Metro Trip Model
struct MetroTrip: Identifiable {
    let id: String
    let routeId: String
    let serviceId: String // WK = Weekday, WE = Weekend
    let direction: Int // 0 = Southbound (Aluva → Tripunithura), 1 = Northbound
    let shapeId: String
    let stopTimes: [StopTime]
}

// MARK: - Stop Time Model
struct StopTime: Identifiable {
    let id: String
    let tripId: String
    let stopId: String
    let stopSequence: Int
    let arrivalTime: String
    let departureTime: String
    let distanceTraveled: Double
}

// MARK: - Metro Fare Model
struct MetroFare: Identifiable {
    let id: String
    let price: Double
    let description: String
}

// MARK: - Service Calendar Model
struct ServiceCalendar {
    let serviceId: String
    let monday: Bool
    let tuesday: Bool
    let wednesday: Bool
    let thursday: Bool
    let friday: Bool
    let saturday: Bool
    let sunday: Bool
    let startDate: String
    let endDate: String
    
    var isWeekday: Bool {
        return monday || tuesday || wednesday || thursday || friday || saturday
    }
    
    var isWeekend: Bool {
        return sunday
    }
}

// MARK: - Fare Rule Model
struct FareRule {
    let originId: String
    let destinationId: String
    let fareId: String
}

// MARK: - Metro Data Service
class MetroDataService: ObservableObject {
    @Published var stations: [MetroStation] = []
    @Published var trips: [MetroTrip] = []
    @Published var fares: [MetroFare] = []
    
    private var serviceCalendars: [String: ServiceCalendar] = [:]
    private var fareRules: [FareRule] = []
    private var tripInfo: [String: (routeId: String, serviceId: String, direction: Int, shapeId: String)] = [:]
    
    static let shared = MetroDataService()
    
    private init() {
        loadData()
    }
    
    // MARK: - Load Data
    func loadData() {
        loadStations()
        loadFares()
        loadCalendar()
        loadTripsInfo()
        loadFareRules()
        loadTranslations()
        loadTrips()
    }
    
    // MARK: - Load Stations
    private func loadStations() {
        // Try multiple paths to find the file
        var url: URL?
        
        // Try with subdirectory first
        url = Bundle.main.url(forResource: "stops", withExtension: "txt", subdirectory: "KMRLOpenData")
        
        // If not found, try without subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: "stops", withExtension: "txt")
        }
        
        // If still not found, try in KMRLOpenData folder directly
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let filePath = (bundlePath as NSString).appendingPathComponent("KMRLOpenData/stops.txt")
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let fileURL = url,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            // Fallback to hardcoded stations if file not found
            loadHardcodedStations()
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        var stationsList: [MetroStation] = []
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue } // Skip header
            
            let components = line.components(separatedBy: ",")
            if components.count >= 4 {
                let stopId = components[0].trimmingCharacters(in: .whitespaces)
                let lat = Double(components[1].trimmingCharacters(in: .whitespaces)) ?? 0.0
                let lon = Double(components[2].trimmingCharacters(in: .whitespaces)) ?? 0.0
                let name = components[3].trimmingCharacters(in: .whitespaces)
                let zoneId = components.count > 6 ? components[6].trimmingCharacters(in: .whitespaces) : stopId
                
                stationsList.append(MetroStation(
                    id: stopId,
                    name: name,
                    latitude: lat,
                    longitude: lon,
                    zoneId: zoneId
                ))
            }
        }
        
        self.stations = stationsList
    }
    
    // MARK: - Load Fares
    private func loadFares() {
        // Try multiple paths to find the file
        var url: URL?
        
        url = Bundle.main.url(forResource: "fare_attributes", withExtension: "txt", subdirectory: "KMRLOpenData")
        
        if url == nil {
            url = Bundle.main.url(forResource: "fare_attributes", withExtension: "txt")
        }
        
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let filePath = (bundlePath as NSString).appendingPathComponent("KMRLOpenData/fare_attributes.txt")
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let fileURL = url,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            loadHardcodedFares()
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        var faresList: [MetroFare] = []
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            if components.count >= 2 {
                let fareId = components[0].trimmingCharacters(in: .whitespaces)
                let price = Double(components[1].trimmingCharacters(in: .whitespaces)) ?? 0.0
                
                let description = getFareDescription(fareId: fareId)
                faresList.append(MetroFare(id: fareId, price: price, description: description))
            }
        }
        
        self.fares = faresList.sorted { $0.price > $1.price }
    }
    
    // MARK: - Load Trips
    private func loadTrips() {
        // Try multiple paths to find the file
        var url: URL?
        
        url = Bundle.main.url(forResource: "stop_times", withExtension: "txt", subdirectory: "KMRLOpenData")
        
        if url == nil {
            url = Bundle.main.url(forResource: "stop_times", withExtension: "txt")
        }
        
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let filePath = (bundlePath as NSString).appendingPathComponent("KMRLOpenData/stop_times.txt")
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let fileURL = url,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        var tripDict: [String: [StopTime]] = [:]
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            if components.count >= 7 {
                let tripId = components[0].trimmingCharacters(in: .whitespaces)
                let stopSequence = Int(components[1].trimmingCharacters(in: .whitespaces)) ?? 0
                let stopId = components[2].trimmingCharacters(in: .whitespaces)
                let arrivalTime = components[3].trimmingCharacters(in: .whitespaces)
                let departureTime = components[4].trimmingCharacters(in: .whitespaces)
                let distance = Double(components[6].trimmingCharacters(in: .whitespaces)) ?? 0.0
                
                let stopTime = StopTime(
                    id: "\(tripId)_\(stopSequence)",
                    tripId: tripId,
                    stopId: stopId,
                    stopSequence: stopSequence,
                    arrivalTime: arrivalTime,
                    departureTime: departureTime,
                    distanceTraveled: distance
                )
                
                if tripDict[tripId] == nil {
                    tripDict[tripId] = []
                }
                tripDict[tripId]?.append(stopTime)
            }
        }
        
        // Convert to MetroTrip objects using tripInfo
        var tripsList: [MetroTrip] = []
        for (tripId, stopTimes) in tripDict {
            let sortedStopTimes = stopTimes.sorted { $0.stopSequence < $1.stopSequence }
            
            // Get trip info from trips.txt data
            if let tripInfo = tripInfo[tripId] {
                tripsList.append(MetroTrip(
                    id: tripId,
                    routeId: tripInfo.routeId,
                    serviceId: tripInfo.serviceId,
                    direction: tripInfo.direction,
                    shapeId: tripInfo.shapeId,
                    stopTimes: sortedStopTimes
                ))
            } else {
                // Fallback if trip info not found
                let direction = tripId.contains("_0") || (sortedStopTimes.first?.stopId == "ALVA") ? 0 : 1
                let serviceId = tripId.hasPrefix("WK") ? "WK" : tripId.hasPrefix("WE") ? "WE" : "WK"
                tripsList.append(MetroTrip(
                    id: tripId,
                    routeId: "R1",
                    serviceId: serviceId,
                    direction: direction,
                    shapeId: direction == 0 ? "R1_0" : "R1_1",
                    stopTimes: sortedStopTimes
                ))
            }
        }
        
        self.trips = tripsList.sorted { $0.id < $1.id }
    }
    
    // MARK: - Load Trips Info
    private func loadTripsInfo() {
        var url: URL?
        
        url = Bundle.main.url(forResource: "trips", withExtension: "txt", subdirectory: "KMRLOpenData")
        if url == nil {
            url = Bundle.main.url(forResource: "trips", withExtension: "txt")
        }
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let filePath = (bundlePath as NSString).appendingPathComponent("KMRLOpenData/trips.txt")
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let fileURL = url,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            if components.count >= 5 {
                let routeId = components[0].trimmingCharacters(in: .whitespaces)
                let serviceId = components[1].trimmingCharacters(in: .whitespaces)
                let tripId = components[2].trimmingCharacters(in: .whitespaces)
                let direction = Int(components[3].trimmingCharacters(in: .whitespaces)) ?? 0
                let shapeId = components[4].trimmingCharacters(in: .whitespaces)
                
                tripInfo[tripId] = (routeId: routeId, serviceId: serviceId, direction: direction, shapeId: shapeId)
            }
        }
    }
    
    // MARK: - Load Calendar
    private func loadCalendar() {
        var url: URL?
        
        url = Bundle.main.url(forResource: "calendar", withExtension: "txt", subdirectory: "KMRLOpenData")
        if url == nil {
            url = Bundle.main.url(forResource: "calendar", withExtension: "txt")
        }
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let filePath = (bundlePath as NSString).appendingPathComponent("KMRLOpenData/calendar.txt")
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let fileURL = url,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            if components.count >= 10 {
                let serviceId = components[0].trimmingCharacters(in: .whitespaces)
                let monday = Int(components[1].trimmingCharacters(in: .whitespaces)) == 1
                let tuesday = Int(components[2].trimmingCharacters(in: .whitespaces)) == 1
                let wednesday = Int(components[3].trimmingCharacters(in: .whitespaces)) == 1
                let thursday = Int(components[4].trimmingCharacters(in: .whitespaces)) == 1
                let friday = Int(components[5].trimmingCharacters(in: .whitespaces)) == 1
                let saturday = Int(components[6].trimmingCharacters(in: .whitespaces)) == 1
                let sunday = Int(components[7].trimmingCharacters(in: .whitespaces)) == 1
                let startDate = components[8].trimmingCharacters(in: .whitespaces)
                let endDate = components[9].trimmingCharacters(in: .whitespaces)
                
                serviceCalendars[serviceId] = ServiceCalendar(
                    serviceId: serviceId,
                    monday: monday,
                    tuesday: tuesday,
                    wednesday: wednesday,
                    thursday: thursday,
                    friday: friday,
                    saturday: saturday,
                    sunday: sunday,
                    startDate: startDate,
                    endDate: endDate
                )
            }
        }
    }
    
    // MARK: - Load Fare Rules
    private func loadFareRules() {
        var url: URL?
        
        url = Bundle.main.url(forResource: "fare_rules", withExtension: "txt", subdirectory: "KMRLOpenData")
        if url == nil {
            url = Bundle.main.url(forResource: "fare_rules", withExtension: "txt")
        }
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let filePath = (bundlePath as NSString).appendingPathComponent("KMRLOpenData/fare_rules.txt")
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let fileURL = url,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        var rulesList: [FareRule] = []
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            if components.count >= 3 {
                let originId = components[0].trimmingCharacters(in: .whitespaces)
                let destinationId = components[1].trimmingCharacters(in: .whitespaces)
                let fareId = components[2].trimmingCharacters(in: .whitespaces)
                
                rulesList.append(FareRule(
                    originId: originId,
                    destinationId: destinationId,
                    fareId: fareId
                ))
            }
        }
        
        self.fareRules = rulesList
    }
    
    // MARK: - Load Translations
    private func loadTranslations() {
        var url: URL?
        
        url = Bundle.main.url(forResource: "translations", withExtension: "txt", subdirectory: "KMRLOpenData")
        if url == nil {
            url = Bundle.main.url(forResource: "translations", withExtension: "txt")
        }
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let filePath = (bundlePath as NSString).appendingPathComponent("KMRLOpenData/translations.txt")
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let fileURL = url,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        var translations: [String: (malayalam: String?, hindi: String?)] = [:]
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }
            
            let components = line.components(separatedBy: ",")
            if components.count >= 5 {
                let recordId = components[4].trimmingCharacters(in: .whitespaces)
                let language = components[2].trimmingCharacters(in: .whitespaces)
                let translation = components[3].trimmingCharacters(in: .whitespaces)
                
                if translations[recordId] == nil {
                    translations[recordId] = (malayalam: nil, hindi: nil)
                }
                
                if language == "ml" {
                    translations[recordId]?.malayalam = translation
                } else if language == "hi" {
                    translations[recordId]?.hindi = translation
                }
            }
        }
        
        // Update stations with translations
        stations = stations.map { station in
            var updatedStation = station
            if let translation = translations[station.id] {
                updatedStation.nameMalayalam = translation.malayalam
                updatedStation.nameHindi = translation.hindi
            }
            return updatedStation
        }
    }
    
    // MARK: - Helper Methods
    private func getFareDescription(fareId: String) -> String {
        switch fareId {
        case "F1": return "Longest Distance (Aluva ↔ Tripunithura)"
        case "F2": return "Long Distance"
        case "F3": return "Medium Distance"
        case "F4": return "Short-Medium Distance"
        case "F5": return "Short Distance"
        case "F6": return "Same Station/Very Short"
        default: return "Standard Fare"
        }
    }
    
    // MARK: - Get Next Metro
    func getNextMetro(for stationId: String, direction: Int = 0) -> (trip: MetroTrip?, time: String, minutes: Int)? {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)
        let currentTimeInSeconds = currentHour * 3600 + currentMinute * 60 + currentSecond
        
        // Get active service ID (WK for weekdays, WE for weekends)
        let activeServiceId = getActiveServiceId()
        
        // Filter trips by direction and active service
        let filteredTrips = trips.filter { 
            $0.direction == direction && $0.serviceId == activeServiceId
        }
        
        // Find next trip for this station
        for trip in filteredTrips {
            if let stopTime = trip.stopTimes.first(where: { $0.stopId == stationId }) {
                let timeComponents = stopTime.departureTime.components(separatedBy: ":")
                if timeComponents.count == 3 {
                    let tripHour = Int(timeComponents[0]) ?? 0
                    let tripMinute = Int(timeComponents[1]) ?? 0
                    let tripSecond = Int(timeComponents[2]) ?? 0
                    let tripTimeInSeconds = tripHour * 3600 + tripMinute * 60 + tripSecond
                    
                    // Check if trip is in the future today
                    if tripTimeInSeconds > currentTimeInSeconds {
                        let minutesUntil = (tripTimeInSeconds - currentTimeInSeconds) / 60
                        return (trip, stopTime.departureTime, minutesUntil)
                    }
                }
            }
        }
        
        // If no trip found today, return first trip of tomorrow
        if let firstTrip = filteredTrips.first,
           let firstStopTime = firstTrip.stopTimes.first(where: { $0.stopId == stationId }) {
            return (firstTrip, firstStopTime.departureTime, 0)
        }
        
        return nil
    }
    
    // MARK: - Get Nearby Stations
    func getNearbyStations(userLocation: CLLocationCoordinate2D, limit: Int = 5) -> [MetroStation] {
        let userLocationObj = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        return stations.map { station in
            let stationLocation = CLLocation(latitude: station.latitude, longitude: station.longitude)
            let distance = userLocationObj.distance(from: stationLocation)
            return (station: station, distance: distance)
        }
        .sorted { $0.distance < $1.distance }
        .prefix(limit)
        .map { $0.station }
    }
    
    // MARK: - Get Station by ID
    func getStation(by id: String) -> MetroStation? {
        return stations.first { $0.id == id }
    }
    
    // MARK: - Get Route Name
    func getRouteName(for direction: Int) -> String {
        if direction == 0 {
            return "Aluva → Tripunithura"
        } else {
            return "Tripunithura → Aluva"
        }
    }
    
    // MARK: - Get Fare Between Stations
    func getFare(from originId: String, to destinationId: String) -> MetroFare? {
        if let rule = fareRules.first(where: { $0.originId == originId && $0.destinationId == destinationId }) {
            return fares.first { $0.id == rule.fareId }
        }
        return nil
    }
    
    // MARK: - Is Weekday Service
    func isWeekdayService(serviceId: String) -> Bool {
        return serviceCalendars[serviceId]?.isWeekday ?? true
    }
    
    // MARK: - Is Weekend Service
    func isWeekendService(serviceId: String) -> Bool {
        return serviceCalendars[serviceId]?.isWeekend ?? false
    }
    
    // MARK: - Get Active Service ID
    func getActiveServiceId() -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Sunday = 1, Monday = 2, etc.
        if weekday == 1 { // Sunday
            return "WE"
        } else {
            return "WK"
        }
    }
    
    // MARK: - Get Stations Between Two Stations
    func getStationsBetween(from: MetroStation, to: MetroStation) -> [MetroStation] {
        guard let fromIndex = stations.firstIndex(where: { $0.id == from.id }),
              let toIndex = stations.firstIndex(where: { $0.id == to.id }) else {
            return []
        }
        
        // Return stations in the direction from -> to
        if fromIndex <= toIndex {
            // Forward direction: from comes before to in the array
            return Array(stations[fromIndex...toIndex])
        } else {
            // Reverse direction: from comes after to in the array, so reverse the order
            return Array(stations[toIndex...fromIndex]).reversed()
        }
    }
    
    // MARK: - Hardcoded Fallback Data
    private func loadHardcodedStations() {
        self.stations = [
            MetroStation(id: "ALVA", name: "Aluva", latitude: 10.1099, longitude: 76.3495, zoneId: "ALVA"),
            MetroStation(id: "VYTA", name: "Vyttila", latitude: 9.9675, longitude: 76.3204, zoneId: "VYTA"),
            MetroStation(id: "TPHT", name: "Tripunithura", latitude: 9.9508, longitude: 76.3518, zoneId: "TPHT"),
            MetroStation(id: "KALR", name: "Kaloor", latitude: 9.9943, longitude: 76.2914, zoneId: "KALR"),
            MetroStation(id: "MGRD", name: "MG Road", latitude: 9.9834, longitude: 76.2823, zoneId: "MGRD"),
            MetroStation(id: "EDAP", name: "Edapally", latitude: 10.0251, longitude: 76.3083, zoneId: "EDAP"),
            MetroStation(id: "CCUV", name: "Cochin University", latitude: 10.0467, longitude: 76.3182, zoneId: "CCUV"),
            MetroStation(id: "KLMT", name: "Kalamassery", latitude: 10.0586, longitude: 76.322, zoneId: "KLMT")
        ]
    }
    
    private func loadHardcodedFares() {
        self.fares = [
            MetroFare(id: "F1", price: 60.0, description: "Longest Distance (Aluva ↔ Tripunithura)"),
            MetroFare(id: "F2", price: 50.0, description: "Long Distance"),
            MetroFare(id: "F3", price: 40.0, description: "Medium Distance"),
            MetroFare(id: "F4", price: 30.0, description: "Short-Medium Distance"),
            MetroFare(id: "F5", price: 20.0, description: "Short Distance"),
            MetroFare(id: "F6", price: 10.0, description: "Same Station/Very Short")
        ]
    }
}

