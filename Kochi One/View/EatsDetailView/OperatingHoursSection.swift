//
//  OperatingHoursSection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct OperatingHoursSection: View {
    let days: [(String, DayHours)]
    let todayData: (hours: DayHours, isOpen: Bool)
    let convertTo12Hour: (String) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Title
            Text("Hours")
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 20)
            
            // Today's Status
            HStack(spacing: 8) {
                Circle()
                    .fill(todayData.isOpen ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(todayData.isOpen ? "Open" : "Closed")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(todayData.isOpen ? .green : .red)
                
                if todayData.isOpen, let closeTime = todayData.hours.close {
                    Text("• Closes at \(convertTo12Hour(closeTime))")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.bottom, 16)
            
            // Days List
            VStack(spacing: 12) {
                ForEach(days, id: \.0) { day, hours in
                    HStack {
                        Text(day)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if hours.closed {
                            Text("Closed")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(convertTo12Hour(hours.open ?? "-")) - \(convertTo12Hour(hours.close ?? "-"))")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }
}

