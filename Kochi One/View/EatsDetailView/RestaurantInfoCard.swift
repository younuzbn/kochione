//
//  RestaurantInfoCard.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct RestaurantInfoCard: View {
    let restaurant: Restaurant
    let distance: String
    let todayData: (hours: DayHours, isOpen: Bool)
    let convertTo12Hour: (String) -> String
    @Binding var showCallDialog: Bool
    @Binding var showMapPicker: Bool
    @Binding var showEmailDialog: Bool
    @Binding var showWebsiteDialog: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with logo and basic info
            HStack(alignment: .top, spacing: 15) {
                // Logo Image
                if let logoURL = restaurant.logo?.url, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 70, height: 70)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        case .failure:
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 70, height: 70)
                                .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                }
                
                // Name and Type
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    if let restaurantType = restaurant.restaurantType, !restaurantType.isEmpty {
                        Text(restaurantType)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    // Rating if available
                    if restaurant.rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 15)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Info section
            VStack(alignment: .leading, spacing: 12) {
                // Address
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "mappin")
                        .foregroundStyle(.blue)
                        .font(.system(size: 14))
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(restaurant.address.street)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                        Text("\(restaurant.address.city), \(restaurant.address.state)")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Distance and Status
                HStack(spacing: 15) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.north.line.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14))
                        Text(distance)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    // Status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(todayData.isOpen ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        if todayData.isOpen {
                            Text("Open")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.green)
                            Text("until \(convertTo12Hour(todayData.hours.close ?? ""))")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Closed")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.red)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Action buttons
            HStack {
                Spacer()
                
                // Call Button
                Button {
                    showCallDialog = true
                } label: {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                }
                .confirmationDialog("Call \(restaurant.name)?", isPresented: $showCallDialog, titleVisibility: .visible) {
                    Button("Call") {
                        let phoneNumber = restaurant.contact.phone
                        guard !phoneNumber.isEmpty else {
                            print("Phone number is empty")
                            return
                        }
                        
                        let cleanedNumber = phoneNumber
                            .replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: "-", with: "")
                            .replacingOccurrences(of: "(", with: "")
                            .replacingOccurrences(of: ")", with: "")
                            .replacingOccurrences(of: ".", with: "")
                        
                        if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                            if UIApplication.shared.canOpenURL(phoneURL) {
                                UIApplication.shared.open(phoneURL)
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(restaurant.contact.phone.isEmpty ? "No phone number available" : restaurant.contact.phone)
                }
                
                Spacer()
                
                // Navigation Button
                Button {
                    let availableApps = MapApp.availableApps()
                    if availableApps.count == 1, let app = availableApps.first {
                        if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
                            UIApplication.shared.open(url)
                        }
                    } else {
                        showMapPicker = true
                    }
                } label: {
                    Image(systemName: "location.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                }
                .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
                    ForEach(MapApp.availableApps()) { app in
                        Button(app.rawValue) {
                            if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
                
                Spacer()
                
                // Email Button
                Button {
                    showEmailDialog = true
                } label: {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                }
                .confirmationDialog("Email \(restaurant.name)?", isPresented: $showEmailDialog, titleVisibility: .visible) {
                    Button("Email") {
                        let email = restaurant.contact.email
                        guard !email.isEmpty else {
                            print("Email is empty")
                            return
                        }
                        
                        if let emailURL = URL(string: "mailto:\(email)") {
                            if UIApplication.shared.canOpenURL(emailURL) {
                                UIApplication.shared.open(emailURL)
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(restaurant.contact.email.isEmpty ? "No email available" : restaurant.contact.email)
                }
                
                Spacer()
                
                // Website Button
                Button {
                    showWebsiteDialog = true
                } label: {
                    Image(systemName: "safari")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                }
                .confirmationDialog("Open Website?", isPresented: $showWebsiteDialog, titleVisibility: .visible) {
                    if let website = restaurant.contact.website, !website.isEmpty {
                        Button("Open Website") {
                            let urlString = website.hasPrefix("http") ? website : "https://\(website)"
                            if let url = URL(string: urlString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    if let website = restaurant.contact.website, !website.isEmpty {
                        Text(website)
                    } else {
                        Text("No website available")
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 15)
        }
        .frame(width: UIScreen.main.bounds.width - 40)
        .background()
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .offset(y: 100)
    }
}

