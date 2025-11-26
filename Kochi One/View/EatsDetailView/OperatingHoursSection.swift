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
        VStack(alignment: .leading) {
            HStack {
                if todayData.isOpen {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.green)
                        .bold()
                        .font(.system(size: 14))
                    Text("Open")
                        .foregroundColor(.green)
                        .bold()
                        .font(.system(size: 14))
                    Text(" Today closes at: \(convertTo12Hour(todayData.hours.close ?? ""))")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                } else {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.red)
                        .font(.system(size: 20))
                    Text("Closed")
                        .foregroundColor(.red)
                        .bold()
                        .font(.system(size: 14))
                }
                Spacer()
            }
            
            ForEach(days, id: \.0) { day, hours in
                HStack {
                    Text(day.capitalized)
                        .frame(width: 120, alignment: .leading)
                    
                    if hours.closed {
                        Text("Closed")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        Text("\(convertTo12Hour(hours.open ?? "-")) - \(convertTo12Hour(hours.close ?? "-"))")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.top, 10)
    }
}

