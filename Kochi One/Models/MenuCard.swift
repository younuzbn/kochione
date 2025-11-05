//
//  MenuCard.swift
//  Kochi One
//
//  Created by APPLE on 06/10/2025.
//


//
//  MockModel.swift
//  StickyHeaderList
//
//  Created by Balaji Venkatesh on 10/09/25.
//

import SwiftUI

/// Dummy Model
struct MenuCard: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var items: [MenuItem] = (1...5).compactMap({ _ in .init() })
}

struct MenuItem: Identifiable {
    var id: String = UUID().uuidString
}

/// Mock Card View
struct DummyCardView: View {
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cookies")
                    .font(.title.bold())
                
                Text("Lorem Ipsum is simply dummy text of the printing")
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
                
                Text("$15.98")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.1))
                .frame(width: 100, height: 100)
        }
        .redacted(reason: .placeholder)
        .padding(10)
        .padding(.leading, 10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 30))
        .padding(.horizontal, 15)
    }
}
