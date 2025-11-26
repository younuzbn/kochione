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
        VStack {
            HStack {
                Image("Location")
                Text("\(restaurant.address.city),\(restaurant.address.state),\(restaurant.address.state),\(restaurant.address.zipCode)")
                Spacer()
            }
            
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundStyle(.gray)
                Text("\(restaurant.contact.phone)")
                Spacer()
            }
        }
        .padding(.top, 10)
    }
}

