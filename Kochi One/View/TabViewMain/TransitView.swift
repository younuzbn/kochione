//
//  TransitView.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/10/25.
//

import SwiftUI
import CoreLocation

struct TransitView: View {
    @State private var selectedTransit: TransitType = .metro
    @StateObject private var metroService = MetroDataService.shared
    @StateObject private var locationService = LocationService()
    @StateObject private var metroMapState = MetroMapState.shared
    @State private var fromStation: MetroStation?
    @State private var toStation: MetroStation?
    @State private var showingFromPicker = false
    @State private var showingToPicker = false
    
    enum TransitType: String, CaseIterable {
        case metro = "Metro"
        case bus = "Bus"
//        case cab = "Cab"
//        case escooter = "E-scooter"
//        case cycle = "Cycle"
//        case ferry = "Ferry"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Transit Type Switcher
            CustomSegmentedControl(
                selection: $selectedTransit,
                options: TransitType.allCases
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            
            // Content based on selection
            Group {
                switch selectedTransit {
                case .metro:
                    MetroView(
                        metroService: metroService,
                        locationService: locationService,
                        fromStation: $fromStation,
                        toStation: $toStation,
                        showingFromPicker: $showingFromPicker,
                        showingToPicker: $showingToPicker
                    )
                case .bus:
                    BusView()
                    
                    //MARK: CAP,cycle
//                case .cab:
//                    CabView()
//                case .escooter:
//                    EScooterView()
//                case .cycle:
//                    CycleView()
//                case .ferry:
//                    FerryView()
                }
            }
            .id(selectedTransit.rawValue)
        }
        .onAppear {
            locationService.startLocationUpdates()
            // Auto-select nearest station as "from" if location is already available
            if fromStation == nil {
                selectNearestStation()
            }
            // Update map state when metro tab is active
            if selectedTransit == .metro {
                metroMapState.isMetroTabActive = true
                metroMapState.showMetroStations = true
            }
        }
        .onChange(of: locationService.currentLocation) { oldValue, newValue in
            // Auto-fill nearest station when location becomes available
            if newValue != nil && fromStation == nil {
                selectNearestStation()
            }
        }
        .onChange(of: selectedTransit) { oldValue, newValue in
            // Close any open pickers when switching
            showingFromPicker = false
            showingToPicker = false
            // Update map state - only show stations when metro tab is selected
            let isMetroActive = (newValue == .metro)
            metroMapState.showMetroStations = isMetroActive
            // Clear station selections and route when switching away from metro
            if !isMetroActive {
                metroMapState.fromStation = nil
                metroMapState.toStation = nil
                metroMapState.clearRoute()
            }
        }
        .onChange(of: fromStation) { oldValue, newValue in
            metroMapState.fromStation = newValue
        }
        .onChange(of: toStation) { oldValue, newValue in
            metroMapState.toStation = newValue
        }
    }
    
    private func selectNearestStation() {
        // Only select nearest station if user location is available
        if let userLocation = locationService.currentLocation {
            let nearby = metroService.getNearbyStations(
                userLocation: userLocation.coordinate,
                limit: 1
            )
            if let nearest = nearby.first {
                fromStation = nearest
            } else {
                // If no nearby station found, keep it as nil (will show "Select one")
                fromStation = nil
            }
        } else {
            // If location is not available, keep it as nil (will show "Select one")
            fromStation = nil
        }
    }
}

// MARK: - Metro View
struct MetroView: View {
    @ObservedObject var metroService: MetroDataService
    @ObservedObject var locationService: LocationService
    @Binding var fromStation: MetroStation?
    @Binding var toStation: MetroStation?
    @Binding var showingFromPicker: Bool
    @Binding var showingToPicker: Bool
    @State private var showingTicketBooking = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // From/To Selector Card
                RouteSelectorCard(
                    fromStation: $fromStation,
                    toStation: $toStation,
                    showingFromPicker: $showingFromPicker,
                    showingToPicker: $showingToPicker,
                    locationService: locationService,
                    metroService: metroService
                )
                .padding(.horizontal, 8)
                .padding(.top, 6)
                .padding(.bottom, 8)
                
                // Metro Timings List (only show if both stations selected)
                if let from = fromStation, let to = toStation {
                    MetroTimingsList(
                        fromStation: from,
                        toStation: to,
                        metroService: metroService,
                        showingTicketBooking: $showingTicketBooking
                    )
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                } else {
                    // Placeholder when stations not selected
                    VStack(spacing: 16) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.gray.opacity(0.4))
                        
                        Text("Select destination to see metro timings")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
            }
        }
    }
}

// MARK: - Route Selector Card
struct RouteSelectorCard: View {
    @Binding var fromStation: MetroStation?
    @Binding var toStation: MetroStation?
    @Binding var showingFromPicker: Bool
    @Binding var showingToPicker: Bool
    @ObservedObject var locationService: LocationService
    @ObservedObject var metroService: MetroDataService
    
    var sortedStations: [MetroStation] {
        metroService.stations.sorted { $0.name < $1.name }
    }
    
    // Stations with "Select one" option at the beginning
    var stationsWithDefault: [(id: String, name: String)] {
        var stations: [(id: String, name: String)] = [("", "Select one")]
        stations.append(contentsOf: sortedStations.map { (id: $0.id, name: $0.name) })
        return stations
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // From Station
            VStack(spacing: 0) {
                Button {
                    withAnimation {
                        showingFromPicker.toggle()
                        if showingFromPicker {
                            showingToPicker = false
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        // Location Icon
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("From")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            if let station = fromStation {
                                Text(station.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                if let userLocation = locationService.currentLocation {
                                    let distance = calculateDistance(
                                        from: userLocation.coordinate,
                                        to: station.coordinate
                                    )
                                    Text(distance)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("Select starting point")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: showingFromPicker ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                }
                
                // Inline Picker
                if showingFromPicker {
                    Divider()
                    
                    Picker("", selection: Binding(
                        get: { fromStation?.id ?? "" },
                        set: { newId in
                            if newId.isEmpty {
                                fromStation = nil
                            } else if let station = sortedStations.first(where: { $0.id == newId }) {
                                fromStation = station
                            }
                        }
                    )) {
                        ForEach(stationsWithDefault, id: \.id) { stationOption in
                            Text(stationOption.name)
                                .tag(stationOption.id)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
            }
            
            Divider()
                .padding(.leading, 52)
            
            // To Station
            VStack(spacing: 0) {
                Button {
                    withAnimation {
                        showingToPicker.toggle()
                        if showingToPicker {
                            showingFromPicker = false
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        // Destination Icon
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("To")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            if let station = toStation {
                                Text(station.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                            } else {
                                Text("Select destination")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: showingToPicker ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                }
                
                // Inline Picker
                if showingToPicker {
                    Divider()
                    
                    Picker("", selection: Binding(
                        get: { toStation?.id ?? "" },
                        set: { newId in
                            if newId.isEmpty {
                                toStation = nil
                            } else if let station = sortedStations.first(where: { $0.id == newId }) {
                                toStation = station
                            }
                        }
                    )) {
                        ForEach(stationsWithDefault, id: \.id) { stationOption in
                            Text(stationOption.name)
                                .tag(stationOption.id)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
            }
        }
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> String {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        let distanceInMeters = fromLoc.distance(from: toLoc)
        let distanceInKm = distanceInMeters / 1000.0
        
        if distanceInKm < 1.0 {
            return String(format: "%.0f m away", distanceInMeters)
        } else {
            return String(format: "%.2f km away", distanceInKm)
        }
    }
}

// MARK: - Station Picker View (kept for compatibility)
struct StationPickerView: View {
    let stations: [MetroStation]
    @Binding var selectedStation: MetroStation?
    @ObservedObject var locationService: LocationService
    let title: String
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredStations: [MetroStation] {
        if searchText.isEmpty {
            return stations
        }
        return stations.filter { station in
            station.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var nearbyStations: [MetroStation] {
        if let userLocation = locationService.currentLocation {
            let metroService = MetroDataService.shared
            return metroService.getNearbyStations(
                userLocation: userLocation.coordinate,
                limit: 5
            )
        }
        return []
    }
    
    var body: some View {
        NavigationView {
            List {
                // Nearby Stations Section
                if !nearbyStations.isEmpty {
                    Section("Nearby Stations") {
                        ForEach(nearbyStations) { station in
                            StationRowView(
                                station: station,
                                locationService: locationService,
                                isSelected: selectedStation?.id == station.id
                            ) {
                                selectedStation = station
                                dismiss()
                            }
                        }
                    }
                }
                
                // All Stations Section
                Section("All Stations") {
                    ForEach(filteredStations) { station in
                        StationRowView(
                            station: station,
                            locationService: locationService,
                            isSelected: selectedStation?.id == station.id
                        ) {
                            selectedStation = station
                            dismiss()
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search stations")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Station Row View
struct StationRowView: View {
    let station: MetroStation
    @ObservedObject var locationService: LocationService
    let isSelected: Bool
    let action: () -> Void
    
    var distance: String? {
        guard let userLocation = locationService.currentLocation else { return nil }
        let userLoc = CLLocation(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude
        )
        let stationLoc = CLLocation(
            latitude: station.latitude,
            longitude: station.longitude
        )
        let distanceInMeters = userLoc.distance(from: stationLoc)
        let distanceInKm = distanceInMeters / 1000.0
        
        if distanceInKm < 1.0 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            return String(format: "%.2f km", distanceInKm)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    if let distance = distance {
                        Text(distance)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Metro Timings List
struct MetroTimingsList: View {
    let fromStation: MetroStation
    let toStation: MetroStation
    @ObservedObject var metroService: MetroDataService
    @State private var expandedTripId: String? = nil
    @Binding var showingTicketBooking: Bool
    @State private var isTicketBooked = false
    
    var upcomingTrips: [(time: String, minutes: Int, trip: MetroTrip, fare: MetroFare?)] {
        // Determine direction based on station positions
        let direction = determineDirection(from: fromStation, to: toStation)
        let activeServiceId = metroService.getActiveServiceId()
        
        // Filter trips by direction and active service
        let filteredTrips = metroService.trips
            .filter { $0.direction == direction && $0.serviceId == activeServiceId }
        
        var upcoming: [(String, Int, MetroTrip, MetroFare?)] = []
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)
        let currentTimeInSeconds = currentHour * 3600 + currentMinute * 60 + currentSecond
        
        // Collect all valid trips with their times (only today's upcoming trips)
        var tripTimes: [(tripTimeInSeconds: Int, minutesUntil: Int, trip: MetroTrip, fare: MetroFare?, originalTime: String)] = []
        
        // End of day time (23:59:59)
        let endOfDayInSeconds = 23 * 3600 + 59 * 60 + 59
        
        for trip in filteredTrips {
            if let fromStopTime = trip.stopTimes.first(where: { $0.stopId == fromStation.id }),
               let toStopTime = trip.stopTimes.first(where: { $0.stopId == toStation.id }),
               fromStopTime.stopSequence < toStopTime.stopSequence {
                
                let timeComponents = fromStopTime.departureTime.components(separatedBy: ":")
                if timeComponents.count == 3 {
                    let tripHour = Int(timeComponents[0]) ?? 0
                    let tripMinute = Int(timeComponents[1]) ?? 0
                    let tripSecond = Int(timeComponents[2]) ?? 0
                    let tripTimeInSeconds = tripHour * 3600 + tripMinute * 60 + tripSecond
                    
                    // Only include trips that are today and haven't passed yet
                    // (trip time >= current time and <= end of day)
                    if tripTimeInSeconds >= currentTimeInSeconds && tripTimeInSeconds <= endOfDayInSeconds {
                        let minutesUntil = (tripTimeInSeconds - currentTimeInSeconds) / 60
                        let fare = metroService.getFare(from: fromStation.id, to: toStation.id)
                        tripTimes.append((tripTimeInSeconds, minutesUntil, trip, fare, fromStopTime.departureTime))
                    }
                }
            }
        }
        
        // Sort by time (earliest first)
        tripTimes.sort { $0.tripTimeInSeconds < $1.tripTimeInSeconds }
        
        // Show all upcoming trips for today (not just 5)
        for tripTime in tripTimes {
            let formattedTime = formatTimeToAMPM(tripTime.originalTime)
            upcoming.append((formattedTime, tripTime.minutesUntil, tripTime.trip, tripTime.fare))
        }
        
        return upcoming
    }
    
    private func formatTimeToAMPM(_ time24: String) -> String {
        let components = time24.components(separatedBy: ":")
        guard components.count >= 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return time24
        }
        
        let hour12: Int
        let period: String
        
        if hour == 0 {
            hour12 = 12
            period = "AM"
        } else if hour < 12 {
            hour12 = hour
            period = "AM"
        } else if hour == 12 {
            hour12 = 12
            period = "PM"
        } else {
            hour12 = hour - 12
            period = "PM"
        }
        
        return String(format: "%d:%02d %@", hour12, minute, period)
    }
    
    private func determineDirection(from: MetroStation, to: MetroStation) -> Int {
        // Simple heuristic: if from station is north of to station, direction is southbound (0)
        // This is a simplified check - in real app, you'd use station sequence
        let fromIndex = metroService.stations.firstIndex(where: { $0.id == from.id }) ?? 0
        let toIndex = metroService.stations.firstIndex(where: { $0.id == to.id }) ?? 0
        return fromIndex < toIndex ? 0 : 1
    }
    
    var fare: MetroFare? {
        metroService.getFare(from: fromStation.id, to: toStation.id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Route Summary Card
            RouteSummaryCard(
                fromStation: fromStation,
                toStation: toStation,
                fare: fare,
                isTicketBooked: isTicketBooked,
                onBookTicket: {
                    showingTicketBooking = true
                }
            )
            .fullScreenCover(isPresented: $showingTicketBooking) {
                TicketBookingView(
                    fromStation: fromStation,
                    toStation: toStation,
                    fare: fare,
                    isTicketBooked: isTicketBooked,
                    onBookingConfirmed: {
                        isTicketBooked = true
                    },
                    onTicketCancelled: {
                        isTicketBooked = false
                    }
                )
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // Next 5 Metro Timings
            if upcomingTrips.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.xmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.4))
                    
                    Text("No upcoming metros")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    // Heading
                    Text("Upcoming Trains")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    
                    ForEach(Array(upcomingTrips.enumerated()), id: \.offset) { index, trip in
                        MetroTimingRow(
                            time: trip.time,
                            minutes: trip.minutes,
                            fromStation: fromStation,
                            toStation: toStation,
                            fare: trip.fare,
                            trip: trip.trip,
                            metroService: metroService,
                            isExpanded: expandedTripId == trip.trip.id,
                            onTap: {
                                // Toggle expansion
                                if expandedTripId == trip.trip.id {
                                    expandedTripId = nil
                                } else {
                                    expandedTripId = trip.trip.id
                                    // Also update map
                                    calculateAndShowRoute(for: trip.trip)
                                }
                            }
                        )
                        
                        if index < upcomingTrips.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
    }
    
    private func calculateAndShowRoute(for trip: MetroTrip) {
        // Get stations between from and to using service method
        let stationsInRoute = metroService.getStationsBetween(from: fromStation, to: toStation)
        
        // Get stop times for this trip between from and to
        let fromStopTime = trip.stopTimes.first(where: { $0.stopId == fromStation.id })
        let toStopTime = trip.stopTimes.first(where: { $0.stopId == toStation.id })
        
        guard let fromStop = fromStopTime, let toStop = toStopTime else {
            return
        }
        
        // Build route coordinates from stations in route (ensures correct order)
        var routeCoords: [CLLocationCoordinate2D] = []
        for station in stationsInRoute {
            routeCoords.append(station.coordinate)
        }
        
        // Calculate current train position
        let trainPosition = calculateTrainPosition(
            trip: trip,
            fromStop: fromStop,
            toStop: toStop,
            stationsInRoute: stationsInRoute
        )
        
        // Update map state on main thread
        DispatchQueue.main.async {
            let metroMapState = MetroMapState.shared
            metroMapState.selectedTrip = trip
            metroMapState.routeCoordinates = routeCoords
            metroMapState.trainPosition = trainPosition
            metroMapState.stationsInRoute = stationsInRoute
        }
    }
    
    private func calculateTrainPosition(
        trip: MetroTrip,
        fromStop: StopTime,
        toStop: StopTime,
        stationsInRoute: [MetroStation]
    ) -> CLLocationCoordinate2D? {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)
        let currentTimeInSeconds = currentHour * 3600 + currentMinute * 60 + currentSecond
        
        // Parse departure time
        let fromTimeComponents = fromStop.departureTime.components(separatedBy: ":")
        guard fromTimeComponents.count == 3,
              let fromHour = Int(fromTimeComponents[0]),
              let fromMinute = Int(fromTimeComponents[1]),
              let fromSecond = Int(fromTimeComponents[2]) else {
            return nil
        }
        
        let fromTimeInSeconds = fromHour * 3600 + fromMinute * 60 + fromSecond
        
        // Parse arrival time
        let toTimeComponents = toStop.arrivalTime.components(separatedBy: ":")
        guard toTimeComponents.count == 3,
              let toHour = Int(toTimeComponents[0]),
              let toMinute = Int(toTimeComponents[1]),
              let toSecond = Int(toTimeComponents[2]) else {
            return nil
        }
        
        let toTimeInSeconds = toHour * 3600 + toMinute * 60 + toSecond
        
        // Check if train has started
        if currentTimeInSeconds < fromTimeInSeconds {
            return fromStation.coordinate
        }
        
        // Check if train has arrived
        if currentTimeInSeconds >= toTimeInSeconds {
            return toStation.coordinate
        }
        
        // Calculate progress (0.0 to 1.0)
        let totalDuration = toTimeInSeconds - fromTimeInSeconds
        let elapsed = currentTimeInSeconds - fromTimeInSeconds
        let progress = Double(elapsed) / Double(totalDuration)
        
        // Interpolate position between stations
        if stationsInRoute.count >= 2 {
            let segmentProgress = progress * Double(stationsInRoute.count - 1)
            let segmentIndex = Int(segmentProgress)
            let segmentT = segmentProgress - Double(segmentIndex)
            
            if segmentIndex < stationsInRoute.count - 1 {
                let fromCoord = stationsInRoute[segmentIndex].coordinate
                let toCoord = stationsInRoute[min(segmentIndex + 1, stationsInRoute.count - 1)].coordinate
                
                // Linear interpolation
                let lat = fromCoord.latitude + (toCoord.latitude - fromCoord.latitude) * segmentT
                let lon = fromCoord.longitude + (toCoord.longitude - fromCoord.longitude) * segmentT
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        
        return fromStation.coordinate
    }
}

// MARK: - Route Summary Card
struct RouteSummaryCard: View {
    let fromStation: MetroStation
    let toStation: MetroStation
    let fare: MetroFare?
    let isTicketBooked: Bool
    let onBookTicket: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Route Line
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 2)
                    .frame(height: 30)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(fromStation.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(toStation.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            if let fare = fare {
                Button {
                    onBookTicket()
                } label: {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("₹\(Int(fare.price))")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                        
                        Text(isTicketBooked ? "Show Ticket" : "Book Ticket")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorScheme == .dark ? Color.white : Color.black)
                    )
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
    }
}

// MARK: - Metro Timing Row
struct MetroTimingRow: View {
    let time: String
    let minutes: Int
    let fromStation: MetroStation
    let toStation: MetroStation
    let fare: MetroFare?
    let trip: MetroTrip
    @ObservedObject var metroService: MetroDataService
    let isExpanded: Bool
    let onTap: () -> Void
    
    var stationsInRoute: [MetroStation] {
        metroService.getStationsBetween(from: fromStation, to: toStation)
    }
    
    var numberOfStations: Int {
        stationsInRoute.count
    }
    
    var arrivalTime: String {
        guard let toStopTime = trip.stopTimes.first(where: { $0.stopId == toStation.id }) else {
            return "N/A"
        }
        return formatTimeToAMPM(toStopTime.arrivalTime)
    }
    
    func getArrivalTime(for station: MetroStation) -> String {
        guard let stopTime = trip.stopTimes.first(where: { $0.stopId == station.id }) else {
            return "N/A"
        }
        return formatTimeToAMPM(stopTime.arrivalTime)
    }
    
    var trainStatus: (departedFrom: MetroStation?, nextStation: MetroStation?) {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)
        let currentTimeInSeconds = currentHour * 3600 + currentMinute * 60 + currentSecond
        
        // Get all stop times sorted by sequence
        let sortedStopTimes = trip.stopTimes.sorted { $0.stopSequence < $1.stopSequence }
        
        var lastDepartedStation: MetroStation? = nil
        var nextStation: MetroStation? = nil
        
        // Find the last station the train has departed from
        for i in 0..<sortedStopTimes.count {
            let stopTime = sortedStopTimes[i]
            let timeComponents = stopTime.departureTime.components(separatedBy: ":")
            
            guard timeComponents.count == 3,
                  let hour = Int(timeComponents[0]),
                  let minute = Int(timeComponents[1]),
                  let second = Int(timeComponents[2]) else {
                continue
            }
            
            let departureTimeInSeconds = hour * 3600 + minute * 60 + second
            
            // If train has departed from this station
            if departureTimeInSeconds <= currentTimeInSeconds {
                if let station = metroService.stations.first(where: { $0.id == stopTime.stopId }) {
                    lastDepartedStation = station
                    
                    // Find next station
                    if i < sortedStopTimes.count - 1 {
                        let nextStopTime = sortedStopTimes[i + 1]
                        if let next = metroService.stations.first(where: { $0.id == nextStopTime.stopId }) {
                            nextStation = next
                        }
                    }
                }
            } else {
                // If we haven't reached this station yet, we've found the last departed
                break
            }
        }
        
        return (lastDepartedStation, nextStation)
    }
    
    private func formatTimeToAMPM(_ time24: String) -> String {
        let components = time24.components(separatedBy: ":")
        guard components.count == 3,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return time24
        }
        
        let hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        let ampm = hour >= 12 ? "PM" : "AM"
        return String(format: "%d:%02d %@", hour12, minute, ampm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main row content
            HStack(spacing: 12) {
                // Time Display - single line with AM/PM
                VStack(alignment: .leading, spacing: 4) {
                    // Time with AM/PM in single line
                    Text(time)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    // Remaining time to reach
                    if minutes > 0 {
                        Text("in \(minutes) min")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Now")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.green)
                    }
                    
                    // Arrival time at destination
                    Text("Arrives at destination at \(arrivalTime)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                    
                    // Train status - departed from and next station
                    if let departedFrom = trainStatus.departedFrom, let next = trainStatus.nextStation {
                        Text("Departed from \(departedFrom.name), next: \(next.name)")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.secondary)
                    } else if let departedFrom = trainStatus.departedFrom {
                        Text("Departed from \(departedFrom.name)")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not yet departed")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 220, alignment: .leading)
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            
            // Expanded content showing stations
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.leading, 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Route Stations")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                            .opacity(isExpanded ? 1 : 0)
                            .animation(.easeIn(duration: 0.2).delay(0.1), value: isExpanded)
                        
                        // Continuous line connecting all stations
                        HStack(spacing: 12) {
                            // Continuous vertical line on the left
                            ZStack(alignment: .top) {
                                if stationsInRoute.count > 1 {
                                    // Continuous line from first to last station
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    stationColor(for: stationsInRoute[0], at: 0).opacity(0.6),
                                                    stationColor(for: stationsInRoute[stationsInRoute.count - 1], at: stationsInRoute.count - 1).opacity(0.6)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: 2)
                                        .frame(height: CGFloat(stationsInRoute.count - 1) * 48)
                                        .offset(y: 6) // Offset to align with circle centers
                                        .opacity(isExpanded ? 1 : 0)
                                        .animation(.easeIn(duration: 0.3), value: isExpanded)
                                }
                                
                                // Station circles positioned on the line
                                VStack(spacing: 0) {
                                    ForEach(Array(stationsInRoute.enumerated()), id: \.element.id) { index, station in
                                        Circle()
                                            .fill(stationColor(for: station, at: index))
                                            .frame(width: 12, height: 12)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(.systemBackground), lineWidth: 2)
                                            )
                                            .opacity(isExpanded ? 1 : 0)
                                            .scaleEffect(isExpanded ? 1 : 0.5)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7).delay(isExpanded ? Double(index) * 0.05 + 0.1 : 0), value: isExpanded)
                                        
                                        if index < stationsInRoute.count - 1 {
                                            Spacer()
                                                .frame(height: 36)
                                        }
                                    }
                                }
                            }
                            .frame(width: 12, alignment: .leading)
                            
                            // Station names - all aligned consistently
                            VStack(spacing: 0) {
                                ForEach(Array(stationsInRoute.enumerated()), id: \.element.id) { index, station in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(station.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.primary)
                                            .opacity(isExpanded ? 1 : 0)
                                            .offset(x: isExpanded ? 0 : -10)
                                            .animation(.easeIn(duration: 0.25).delay(isExpanded ? Double(index) * 0.05 + 0.15 : 0), value: isExpanded)
                                        
                                        Group {
                                            if index == 0 {
                                                Text("Starting Point")
                                                    .font(.system(size: 12, weight: .regular))
                                                    .foregroundStyle(.blue)
                                            } else if index == stationsInRoute.count - 1 {
                                                Text("Destination")
                                                    .font(.system(size: 12, weight: .regular))
                                                    .foregroundStyle(.red)
                                            } else {
                                                Text("Arrives at \(getArrivalTime(for: station))")
                                                    .font(.system(size: 12, weight: .regular))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .opacity(isExpanded ? 1 : 0)
                                        .offset(x: isExpanded ? 0 : -10)
                                        .animation(.easeIn(duration: 0.25).delay(isExpanded ? Double(index) * 0.05 + 0.2 : 0), value: isExpanded)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .frame(height: 48, alignment: .leading)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
    
    private func stationColor(for station: MetroStation, at index: Int) -> Color {
        if index == 0 {
            return .blue // Starting point
        } else if index == stationsInRoute.count - 1 {
            return .red // Destination
        } else {
            return .green // Intermediate stations
        }
    }
}

// MARK: - Custom Segmented Control
struct CustomSegmentedControl<T: Hashable & RawRepresentable<String>>: View {
    @Binding var selection: T
    let options: [T]
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    // Get icon for each transit type
    private func icon(for option: T) -> String {
        let rawValue = option.rawValue.lowercased()
        switch rawValue {
        case "metro":
            return "tram.fill"
        case "bus":
            return "bus.fill"
//        case "cab":
//            return "car.fill"
//        case "e-scooter":
//            return "bolt.car.fill"
//        case "cycle":
//            return "bicycle"
//        case "ferry":
//            return "sailboat.fill"
        default:
            return "circle.fill"
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = option
                        }
                    } label: {
                        ZStack {
                            // Selected background with pill shape - black in light mode, white in dark mode
                            if selection == option {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? Color.white : Color.black)
                                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .matchedGeometryEffect(id: "selectedTab", in: animation)
                            }
                            
                            // Content: Icon + Text for selected, Icon only for unselected
                            HStack(spacing: 6) {
                                Image(systemName: icon(for: option))
                                    .font(.system(size: 16, weight: selection == option ? .semibold : .medium))
                                    .foregroundStyle(selection == option ? (colorScheme == .dark ? .black : .white) : .primary)
                                
                                if selection == option {
                                    Text(option.rawValue)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                                }
                            }
                            .padding(.horizontal, selection == option ? 18 : 12)
                            .padding(.vertical, 10)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Bus View
struct BusView: View {
    var body: some View {
        ComingSoonView(
            icon: "bus.fill",
            title: "Coming Soon",
            message: "Bus services will be available soon"
        )
    }
}

 //MARK: - Cab View
struct CabView: View {
    var body: some View {
        ComingSoonView(
            icon: "car.fill",
            title: "Coming Soon",
            message: "Cab booking will be available soon"
        )
    }
}

// MARK: - E-scooter View
struct EScooterView: View {
    var body: some View {
        ComingSoonView(
            icon: "bolt.car.fill",
            title: "Coming Soon",
            message: "E-scooter rental will be available soon"
        )
    }
}

// MARK: - Cycle View
struct CycleView: View {
    var body: some View {
        ComingSoonView(
            icon: "bicycle",
            title: "Coming Soon",
            message: "Cycle rental will be available soon"
        )
    }
}

// MARK: - Ferry View
struct FerryView: View {
    var body: some View {
        ComingSoonView(
            icon: "sailboat.fill",
            title: "Coming Soon",
            message: "Ferry services will be available soon"
        )
    }
}

// MARK: - Coming Soon View
struct ComingSoonView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.gray.opacity(0.5))
                
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Ticket Booking View
struct TicketBookingView: View {
    let fromStation: MetroStation?
    let toStation: MetroStation?
    let fare: MetroFare?
    let isTicketBooked: Bool
    let onBookingConfirmed: () -> Void
    let onTicketCancelled: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmation = false
    @State private var showTicket = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    init(fromStation: MetroStation?, toStation: MetroStation?, fare: MetroFare?, isTicketBooked: Bool = false, onBookingConfirmed: @escaping () -> Void, onTicketCancelled: @escaping () -> Void) {
        self.fromStation = fromStation
        self.toStation = toStation
        self.fare = fare
        self.isTicketBooked = isTicketBooked
        self.onBookingConfirmed = onBookingConfirmed
        self.onTicketCancelled = onTicketCancelled
        _showTicket = State(initialValue: isTicketBooked)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if showTicket {
                    // Ticket View - Fixed Height
                    VStack(spacing: 0) {
                        // Top Section - Ticket Information
                        VStack(spacing: 16) {
                            // Header
                            VStack(spacing: 8) {
                                Text("KOCHI METRO")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                if let fromStation = fromStation, let toStation = toStation {
                                    Text("\(fromStation.name) → \(toStation.name)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Divider()
                            
                            // Ticket Details
                            HStack(spacing: 30) {
                                // Ticket ID
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Ticket ID")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.secondary)
                                    
                                    Text(UUID().uuidString.prefix(8).uppercased())
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.primary)
                                }
                                
                                // Fare
                                if let fare = fare {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Fare")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.secondary)
                                        
                                        Text("₹\(Int(fare.price))")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(.blue)
                                    }
                                }
                                
                                Spacer()
                                
                                // Date & Time
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.primary)
                                    
                                    Text(Date().formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        
                        Spacer()
                        
                        // QR Code - Full Width
                        Image("ticket")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                        
                        Spacer()
                        
                        // Bottom Section - Action Buttons
                        VStack(spacing: 12) {
                            Button {
                                // Share ticket
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Ticket")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                            }
                            
                            Button {
                                // Cancel ticket
                                onTicketCancelled()
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Cancel Ticket")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red)
                                )
                            }
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .background(Color(.systemBackground))
                    }
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
                } else {
                    // Booking Form - Redesigned
                    VStack(spacing: 0) {
                        // Top Section - Route Summary
                        VStack(spacing: 20) {
                            // Header
                            VStack(spacing: 8) {
                                Image(systemName: "tram.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.blue)
                                
                                Text("Confirm Booking")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.top, 30)
                            
                            // Route Card
                            if let fromStation = fromStation, let toStation = toStation {
                                VStack(spacing: 0) {
                                    // Route Line Visual
                                    HStack(spacing: 0) {
                                        // From Station
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.blue)
                                                    .frame(width: 24, height: 24)
                                                
                                                Image(systemName: "mappin.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(.white)
                                            }
                                            
                                            Text(fromStation.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(.primary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        // Arrow
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 8)
                                        
                                        // To Station
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 24, height: 24)
                                                
                                                Image(systemName: "mappin.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(.white)
                                            }
                                            
                                            Text(toStation.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(.primary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .padding(.vertical, 24)
                                    .padding(.horizontal, 20)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            // Fare Card
                            if let fare = fare {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Total Fare")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.secondary)
                                        
                                        Text("₹\(Int(fare.price))")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.blue.opacity(0.6))
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Bottom Section - Confirm Button
                        VStack(spacing: 12) {
                            Button {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showConfirmation = true
                                }
                                
                                // Show ticket after animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showTicket = true
                                        onBookingConfirmed()
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Confirm Booking")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.blue)
                                )
                            }
                            
                            Text("By confirming, you agree to the terms and conditions")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .background(Color(.systemBackground))
                    }
                    .frame(maxHeight: .infinity)
                    .overlay {
                        // Confirmation Animation
                        if showConfirmation {
                            ZStack {
                                Color.black.opacity(0.7)
                                    .ignoresSafeArea()
                                
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 100, height: 100)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 50, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    .scaleEffect(scale)
                                    .opacity(opacity)
                                    
                                    Text("Booking Confirmed!")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                        .opacity(opacity)
                                }
                            }
                            .transition(.opacity)
                            .onAppear {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                    scale = 1.0
                                    opacity = 1.0
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !showTicket {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    TransitView()
}
