//
//  CustomControl.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/11/25.
//


//
//  CustomControl.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


import SwiftUI

struct MenuCustomControl: View {
    @Binding var selection: String
    let options: [String]
    
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: ICONS
    private func icon(for option: String) -> String {
        switch option.lowercased() {
        case "fast food": return "fork.knife"
        case "soft drinks": return "cup.and.saucer.fill"
        case "starters": return "wineglass.fill"
        case "desserts": return "birthday.cake.fill"
        case "main course": return "car.fill"
        default: return "circle.fill"
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selection = option
                        }
                    } label: {
                        HStack(spacing: 6) {
                            
                            // ICON
                            Image(systemName: icon(for: option))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(
                                    selection == option
                                    ? (colorScheme == .dark ? .black : .white)
                                    : .primary
                                )
                            
                            // SELECTED → SHOW LABEL
                            if selection == option {
                                Text(option.capitalized)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, selection == option ? 16 : 12)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selection == option {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.black)
                                        .matchedGeometryEffect(id: "tab", in: animation)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical,5)
            .background(
                Capsule()
                    .offset(x:5)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
    }
}
