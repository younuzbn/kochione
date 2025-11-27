//
//  ContactInfoSection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct ContactInfoSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Title
            Text("Contact")
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 20)
            
            // Address
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    if !restaurant.address.street.isEmpty {
                        Text(restaurant.address.street)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.primary)
                    }
                    
                    Text("\(restaurant.address.city), \(restaurant.address.state) \(restaurant.address.zipCode)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.bottom, 16)
            
            // Contact Details
            VStack(spacing: 12) {
                // Phone
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    
                    Text(restaurant.contact.phone)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                
                // Email (if available)
                if !restaurant.contact.email.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        
                        Text(restaurant.contact.email)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}

