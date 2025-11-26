//
//  ActionButtonsRow.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct ActionButtonsRow: View {
    let restaurant: Restaurant
    @Binding var showCallDialog: Bool
    @Binding var showMapPicker: Bool
    @Binding var showEmailDialog: Bool
    @Binding var showWebsiteDialog: Bool
    
    var body: some View {
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
        .padding(.top, 8)
    }
}

