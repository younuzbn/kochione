//
//  Indicators.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


//
//  Indicators.swift
//  FoodDeliveryApp
//
//  Created by Subin Kurian on 21/11/25.
//


import SwiftUI

struct Indicators: View {

    var count: Int             
    @Binding var currentIndex: Int
    var animation: Namespace.ID

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(Color("blue"))
                    .frame(
                        width: currentIndex == index ? 10 : 6,
                        height: currentIndex == index ? 10 : 6
                    )
                    .padding(4)
                    .background {
                        if currentIndex == index {
                            Circle()
                                .stroke(Color("blue"), lineWidth: 1)
                                .matchedGeometryEffect(id: "INDICATOR", in: animation)
                        }
                    }
            }
        }
        .animation(.easeInOut, value: currentIndex)
    }
}
