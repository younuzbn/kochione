//
//  AboutSection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct AboutSection: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("About")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.leading, 30)
                Spacer()
            }
            
            Text(description)
                .font(.system(size: 16))
                .padding(.horizontal, 30)
        }
        .padding(.top, 60)
        .padding(.vertical, 10)
    }
}

