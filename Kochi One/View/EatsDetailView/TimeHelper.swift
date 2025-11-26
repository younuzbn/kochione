//
//  TimeHelper.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import Foundation

struct TimeHelper {
    static func convertTo12Hour(_ time24: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .init(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "hh:mm a"
        outputFormatter.locale = .init(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: time24) {
            return outputFormatter.string(from: date)
        } else {
            return "Invalid time"
        }
    }
    
    static func getTodayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).lowercased()
    }
    
    static func getTodayHours(from operatingHours: OperatingHours) -> (hours: DayHours, isOpen: Bool) {
        let today = getTodayKey()
        
        let todayHours: DayHours
        
        switch today {
        case "monday": todayHours = operatingHours.monday
        case "tuesday": todayHours = operatingHours.tuesday
        case "wednesday": todayHours = operatingHours.wednesday
        case "thursday": todayHours = operatingHours.thursday
        case "friday": todayHours = operatingHours.friday
        case "saturday": todayHours = operatingHours.saturday
        default: todayHours = operatingHours.sunday
        }
        
        let open = !todayHours.closed &&
                   isStoreOpen(opening: todayHours.open ?? "",
                               closing: todayHours.close ?? "")
        
        return (todayHours, open)
    }
    
    static func isStoreOpen(opening: String, closing: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .init(identifier: "en_US_POSIX")
        
        guard !opening.isEmpty, !closing.isEmpty,
              let openTime = formatter.date(from: opening),
              let closeTime = formatter.date(from: closing) else {
            return false
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Get hour and minute components
        let openHour = calendar.component(.hour, from: openTime)
        let openMinute = calendar.component(.minute, from: openTime)
        let closeHour = calendar.component(.hour, from: closeTime)
        let closeMinute = calendar.component(.minute, from: closeTime)
        
        // Create open time for today
        guard let todayOpen = calendar.date(
            bySettingHour: openHour,
            minute: openMinute,
            second: 0,
            of: now
        ) else {
            return false
        }
        
        // Create close time for today
        guard let todayCloseTemp = calendar.date(
            bySettingHour: closeHour,
            minute: closeMinute,
            second: 0,
            of: now
        ) else {
            return false
        }
        
        // If close time is earlier than open time, it means it closes the next day
        let closesNextDay = todayCloseTemp < todayOpen
        
        let todayClose: Date
        if closesNextDay {
            // Closing time is tomorrow (past midnight)
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                todayClose = calendar.date(
                    bySettingHour: closeHour,
                    minute: closeMinute,
                    second: 0,
                    of: tomorrow
                ) ?? now
            } else {
                todayClose = now
            }
        } else {
            // Closing time is today
            todayClose = todayCloseTemp
        }
        
        return now >= todayOpen && now <= todayClose
    }
}

