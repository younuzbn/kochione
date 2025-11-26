//
//  HeaderView.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


//
//  HeaderView.swift
//  FoodDeliveryApp
//
//  Created by Subin Kurian on 21/11/25.
//

import SwiftUI

struct HeaderView: View {

    @Binding var searchText: String
    @FocusState var isFocused: Bool
    @Binding var isHovered: Bool
    var showDetail: Bool

    var body: some View {
//        HStack{
//            
//            if !showDetail {
//
//                // iOS 26  GLASS EFFECT
//                if #available(iOS 26.0, *) {
//                    TextField("Search Dishes", text: $searchText)
//                        .focused($isFocused)
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 10)
//                        .glassEffect()   // Only for iOS 26
//                        .frame(width: (isHovered || isFocused) ? 250 : 170)
//                        .animation(.easeInOut(duration: 0.25), value: isHovered)
//                        .animation(.easeInOut(duration: 0.25), value: isFocused)
//
//                // iOS 15  ULTRA THIN MATERIAL
//                } else if #available(iOS 15.0, *) {
//                    TextField("Search Dishes", text: $searchText)
//                        .focused($isFocused)
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 10)
//                        .background(.ultraThinMaterial, in: Capsule())
//                        .frame(width: (isHovered || isFocused) ? 250 : 170)
//                        .animation(.easeInOut(duration: 0.25), value: isHovered)
//                        .animation(.easeInOut(duration: 0.25), value: isFocused)
//
//                // iOS 14 and below  WHITE CAPSULE
//                } else {
//                    TextField("Search", text: $searchText)
//                        .focused($isFocused)
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 10)
//                        .background(Color.white.opacity(0.6), in: Capsule())
//                        .frame(width: (isHovered || isFocused) ? 250 : 170)
//                        .animation(.easeInOut(duration: 0.25), value: isHovered)
//                        .animation(.easeInOut(duration: 0.25), value: isFocused)
//                }
//            }
//
//            
//            Spacer()
//               
//          
//
//            // MARK: Going to show the same Button from Home View
//            Button {
//                
//            } label: {
//                Image(systemName: "cart")
//                    .font(.title2)
//                    .foregroundColor(.black)
//                    .overlay(alignment: .topTrailing) {
//                        Circle()
//                            .fill(.red)
//                            .frame(width: 10, height: 10)
//                            .offset(x: 2, y: -5)
//                    }
//            }
//        }
////
//        .padding(15)
        

    }
    
}

//#Preview {
//Home()
//}

